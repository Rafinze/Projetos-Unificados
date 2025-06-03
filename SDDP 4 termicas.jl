using SDDP, Gurobi

function subproblem_builder(subproblem::Model, node::Int)
    max_termo =[10,15,20,15]
    nT = 4
    vol_max = 65
    demanda = 50
    volume_inicial = 45
    custo_termo = [8,12,15,18]

    # State variables
    @variable(subproblem, 0 <= V <= vol_max, SDDP.State, initial_value = volume_inicial)

    # Control variables    
    @variables(subproblem, 
        begin
            H >=0
            0 <= T[i=1:nT] <= max_termo[i]
        end
    )

    # Random variables
    @variable(subproblem, Chuva)
    Ω = [0, 0]
    P = [1/2, 1/2]
    SDDP.parameterize(subproblem, Ω, P) do ω # recebe três argumentos: o ambiente a ser analizado(subproblem), um vetor contendo o espaço amostral (Ω) e um vetor de probabilidades (P). SDDP.parameterize só pode ser chamado uma vez
        return JuMP.fix(Chuva, ω) #utilizamos para definir o valor da variável "chuva" com os valores gerados de ω
    end

    # Constraints
    @constraint(subproblem, restricao_demanda, sum(T[i] for i in 1:nT) + H == demanda)
    @constraint(subproblem, V.out == V.in - H + Chuva)


    # Objective
    @stageobjective(subproblem, sum(custo_termo[i] * T[i] for i in 1:nT))

    return subproblem
 end


 model = SDDP.LinearPolicyGraph(
    subproblem_builder;
    stages = 2,
    sense = :Min,
    lower_bound = 0.0,
    optimizer = Gurobi.Optimizer,
)

    

# Treinamento do modelo
SDDP.train(model; iteration_limit = 100)

rule = SDDP.DecisionRule(model; node = 1)

solution = SDDP.evaluate(
    rule;
    incoming_state = Dict(:V => 45.0),
    noise = 0.0,
    controls_to_record = [:H, :T],
)

# Simulação do modelo
simulations = SDDP.simulate(
    model,
    100,
    [:V, :H, :T],
)

# outgoing_volume = map(simulations[1]) do node
#     return node[:V].out
# end

# thermal_generation = map(simulations[1]) do node
#     return node[:T]
# end

# Processamento dos resultados das simulações (construção de um intervalo de esperaça do custo)
objectives = map(simulations) do simulation 
    return sum(stage[:stage_objective] for stage in simulation)
end

μ, ci = SDDP.confidence_interval(objectives) 
println("Confidence interval: ", μ, " ± ", ci)
println("Lower bound: ", SDDP.calculate_bound(model))


# #obtem o dual da restrição de demanda 
# simulations = SDDP.simulate(
#     model,
#     1,  ## Perform a single simulation
#     custom_recorders = Dict{Symbol,Function}(
#         :price => (sp::JuMP.Model) -> JuMP.dual(sp[:restricao_demanda]),
#     ),
# )

# prices = map(simulations[1]) do node
#     return node[:price]
# end


# # avaliando o valor da função em diferentes pontos 
# Vol = SDDP.ValueFunction(model; node = 1)
# cost, price = SDDP.evaluate(Vol, Dict("V" => 10))
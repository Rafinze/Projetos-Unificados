using JuMP, Gurobi, Plots, HiGHS 

# Dados
c = [8, 12, 15, 18]
v0 = 40
ptMax = [10, 15, 20, 15]
mes = 2
NT = 4
NH = 1
demanda = 50

function primeiro_mes(num_cortes, fm2, λ, vs, c, demanda, NH, NT, ptMax, v0)
    modelo = Model(HiGHS.Optimizer)
    
    @variable(modelo, 0 <= T[1, j = 1:NT] <= ptMax[j])
    @variable(modelo, 0 <= H[1, 1])
    @variable(modelo, 0 <= V[1, 1])
    @variable(modelo, Z >= 0)
    
    @constraint(modelo, sum(T[1, j] for j in 1:NT) + sum(H[1, 1]) == demanda)
    @constraint(modelo, V[1, 1] == v0 - H[1, 1])
    
    for i ∈ 1:num_cortes
        @constraint(modelo, Z >= (fm2[i] + (λ[i]) * (V[1, 1] - vs[i])))
        print("V1 star: ",vs)
    end

    
    @objective(modelo, Min, sum(c[j] * T[1, j] for j = 1:NT) + Z)
    
    optimize!(modelo)
    return value(V[1, 1]), objective_value(modelo), value(Z)
end


function segundo_mes(CH, NT, NH, v1, c, demanda, ptMax)
    modelo = Model(HiGHS.Optimizer)
    
    @variable(modelo, 0 <= T₂[j = 1:NT] <= ptMax[j])
    @variable(modelo, H₂[1:NH] >= 0)
    @variable(modelo, V₂[1:NH] >= 0)
    
    @constraint(modelo, sum(T₂[j] for j in 1:NT) + H₂[1] == demanda)
    global rest = @constraint(modelo, V₂[1] == v1 - H₂[1] + CH)
    
    @objective(modelo, Min, sum(c[j] * T₂[j] for j = 1:NT))
    
    optimize!(modelo)
    return dual(rest), objective_value(modelo)
end

function resolve_problema_todo(c, demanda, NH, NT, ptMax, mes, v0)
    fm2_cont = -100.0 
    Z = 5.0
    vs = Float64[]
    fm2 = Float64[]
    λ = Float64[]
    
    CH = 0.0
    num_cortes = 0
    
    while fm2_cont - Z != 0
        saidas1 = primeiro_mes(num_cortes, fm2, λ, vs, c, demanda, NH, NT, ptMax, v0)
        push!(vs, saidas1[1])
         Z = saidas1[3]
        println("Saídas do Primeiro Mês:")
        println("Volume Final: ", saidas1[1])
        println("Custo Total: ", saidas1[2])
        println("Z : ", saidas1[3])
        println()

        saidas2 = segundo_mes(CH, NT, NH, vs[num_cortes + 1], c, demanda, ptMax)
        
        println("Saídas do Segundo Mês:")
        println("Lagrange Multipliers (λ): ", saidas2[1])
        println("Custo Total: ", saidas2[2])
        println()
        
        push!(λ, saidas2[1])
        push!(fm2, saidas2[2])
        fm2_cont = saidas2[2]
        num_cortes += 1
        # println("Pressione Enter para continuar")
        # readline()
        # println("Continuando o código")

    end
    
    return Z, fm2, vs, λ
end

saidas3 = resolve_problema_todo(c, demanda, NH, NT, ptMax, mes, v0)
println("Resultado Final:")
println("Z: ", saidas3[1])
println("fm2: ", saidas3[2])
println("vs: ", saidas3[3])
println("λ: ", saidas3[4])
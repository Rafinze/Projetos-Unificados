using JuMP, Gurobi, CSV, DataFrames, Plots
function otimizar_modelo(anos::Int, NAj::Int)
   

    df_ch = CSV.read("C:/Users/bruno/Desktop/IC/Dados/Dados_Kenny/CenariosAfluencias.csv",DataFrame)
    df_demanda = CSV.read("C:/Users/bruno/Desktop/IC/Dados/Tabelas IC - Demanda.csv",DataFrame)
    demanda_meses = df_demanda.Demanda
    data_hidro= CSV.read("C:/Users/bruno/Desktop/IC/Dados/Hidro - Hidro.csv",DataFrame)
    vol_inicial = data_hidro.VolInicial
    V₀ = values(vol_inicial)
    
    # Dados do problema
    NT = 8
    NH = 7
    c = [136, 87, 140, 929, 473,54,169,594]
    ρ = [0.12723, 0.16576,0.6372,0.09313,0.16826,0.38833,0.40992]
    d = values(demanda_meses)
    vmax = [100000, 110000, 120000, 130000, 140000, 150000,180000]
    qhMax =[66220071, 211289078,16644477,1069001959,826397182,999935762,751135249] 
    phMax = [8274256, 326887, 10065465,100887562,142238577,388302034,307908318]
    ptMax = [1927, 523, 1493, 880, 1257, 2632, 1257, 2014]
    meses_no_ano = 5

    mes = meses_no_ano*anos
    CH = zeros(mes,NH,NAj)
    def = 764382
    NCM = zeros(mes)
    for z ∈ 1:(mes)
        NCM[z] = NAj^(z-1)
    end
    NCM = Int.(NCM)

    for k = 1:NAj
        for j = 1:NH
            for i = 1:meses_no_ano
            CH[i,j,k] = df_ch[j + (k-1)*7,i+2] 
            end
        end
    end

    qt_mon = [0,1,0,2,1,1,1]
    qs_mon = [0 0 0 0 0 0 0 ; 1 0 0 0 0 0 0; 0 0 0 0 0 0 0; 2 3 0 0 0 0 0; 4 0 0 0 0 0 0; 5 0 0 0 0 0 0; 6 0 0 0 0 0 0]

    matriz_demanda = zeros(mes)
    for i in 0:anos-1
        matriz_demanda[i*meses_no_ano+1:(i+1)*meses_no_ano] = d[1:meses_no_ano]
    end

    modelo = Model(Gurobi.Optimizer)

    @variable(modelo, 0 <= T[i=1:mes, j=1:NT, a=1:NCM[i]] <= ptMax[j])
    @variable(modelo, 0 <= H[i=1:mes, j=1:NH, a=1:NCM[i]] <= qhMax[j])
    @variable(modelo, 0 <= V[i=1:mes, j=1:NH, a=1:NCM[i]] <= vmax[j])
    @variable(modelo, 0 <= S[i=1:mes, j=1:NH, a=1:NCM[i]])
    @variable(modelo, 0 <= pd[1:mes])

    @objective(modelo, Min, sum(sum(1/NCM[i] * (sum(c[j] * T[i,j,a] + pd[i]*def for a = 1:NCM[i])) for i = 1:mes) for j = 1:NT))

    for j ∈ 1:NH
        @constraint(modelo, V[1,j,1] .== V₀[j] .- H[1,j,1] .- S[1,j,1] .+ CH[1,j,1])
        if   qt_mon[j] != 0 
            @constraint(modelo, V[1,j,1] .== V₀[j] .- H[1,j,1]  .-S[1,j,1] .+ CH[1,j,1] .+ sum(H[1, qs_mon[j,l], 1] + S[1, qs_mon[j,l], 1] for l in 1:qt_mon[j]))
        end
    end

    for j ∈ 1:NH
        for i ∈ 2:mes 
            local cont = 0
            if qt_mon[j] == 0 
                for a ∈ 1:NCM[i-1]
                    for r ∈ 1:NAj
                        cont += 1
                        @constraint(modelo, V[i, j, cont] .== V[i-1, j, a] .- H[i, j, cont] .- S[i, j, cont] .+ CH[i, j, r]) #problema está em numero de cenarios por mes, substituindo está ok
                    end
                end
            else
                for a ∈ 1:NCM[i-1]
                    for r ∈ 1:NAj
                        cont += 1 
                        @constraint(modelo, V[i,j,cont] .== V[i-1, j , a] .- H[i, j, cont] .+ CH[i, j, r] .- S[i,j,cont].+sum(H[i, qs_mon[j,l] , cont] + S[i , qs_mon[j,l], cont] for l in 1:qt_mon[j]))
                    end
                end
            end
        end
    end


    # Restrições de Demanda
    for j = 1:mes
        @constraint(modelo, sum(T[j, i, a] + pd[j] for i = 1:NT, a = 1:NCM[j]) + sum(ρ[i] * H[j, i, a]  for i = 1:NH, a = 1:NCM[j]) == matriz_demanda[j])
    end
    tempo_inicio = time()
    optimize!(modelo)

    tempo_fim = time()
    tempo_total = tempo_fim - tempo_inicio

    return tempo_total, objective_value(modelo), num_variables(modelo), mes
end

anos = 1
NAj = 2

function roda_modelo(qtd_anos::Int, qtd_cen::Int)
    df_resultados_total = DataFrame(Tempo_de_Execucao = Float64[], Solucao_otima = Float64[], Num_Variaveis = Int[], NAj = Int[], Meses = Int[])
    
    for anos in 1:qtd_anos
        for NAj in 1:qtd_cen
            resultado = otimizar_modelo(anos, NAj)
            push!(df_resultados_total, (resultado[1], resultado[2], resultado[3], NAj, resultado[4]))
        end
    end
   
    
    #CSV.write("resultados_modelo_otimizado32.csv", df_resultados_total)
    
    # # #gráfico de tempo vs quantidade de meses
    #plot( df_resultados_total[:, :Meses], df_resultados_total[:, :Tempo_de_Execucao])
    # savefig("tempo_vs_meses1.png")
    
   #gráfico de tempo vs quantidade de cenarios
    # plot( df_resultados_total[:, :NAj], df_resultados_total[:, :Tempo_de_Execucao], )
    # savefig("tempo_vs_cenarios1.png")
    
#   #gráfico de tempo  vs quantidade de variáveis
    plot(df_resultados_total[:, :NAj],df_resultados_total[:, :Num_Variaveis],  xlabel=  "Cenários",   ylabel= "Número de variáveis", xguidefont = font("Times New Roman", 12), yguidefont = font("Times New Roman", 12))
    savefig("tempo_vs_variaveis18.png")
  
    # plot(df_resultados_total[:, :Tempo_de_Execucao],df_resultados_total[:, :Meses], xlabel!("\\text{Tempo(s)}"),ylabel!("\\text{Meses}"))
    # savefig("tempo_meses.png")

    # plot(df_resultados_total[:, :Tempo_de_Execucao],df_resultados_total[:,:Solucao_otima])
    # savefig("custo_tempo.png")
end

# Chame a função para executar o modelo
roda_modelo(anos, NAj)

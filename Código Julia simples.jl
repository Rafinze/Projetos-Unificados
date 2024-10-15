using HiGHS
using JuMP

# 1 usina para n meses (utilizando n = 3)

# Dados do problema
demanda = [10000 , 10000 , 10000]
volume_inicial = 1300
custo_termo = 100
vol_max = 150000
N = 3 # se for mudar os meses tem que mudar os valores dos vetores também

#Capacidade máxima
T = 10000
H = 10000 

 #energia produzida em cada mes
hidro = [1000 , 900, 1100]
termo = [1200, 1300, 980]

# criação do objeto
modelo = Model(HiGHS.Optimizer)

# Variáveis de decisão
@variable(modelo, 0 <= termo[1:N] <= T)
@variable(modelo, 0 <= hidro[1:N] <= H)

# Variáveis de volume para representar o volume no início de cada mês
@variable(modelo, 0 <= volume[1:N] <= vol_max)

# Variáveis de volume anterior para representar o volume no início de cada mês anterior
@variable(modelo, 0 <= volume_anterior[1:N] <= vol_max)

# Define o volume anterior para o primeiro mês
@constraint(modelo, volume_anterior[1] == volume_inicial)

# Relacione o volume anterior com o volume atual para os proximos meses 
for i in 2:N
    @constraint(modelo, volume_anterior[i] == volume[i - 1])
end

# Restrições
for i in 1:N
    if i == 1
        # Volume inicial no primeiro mês
        @constraint(modelo, volume[i] == volume_inicial - hidro[i])
    else
        # Restrição de volume para os meses subsequentes
        @constraint(modelo, volume[i] == volume_anterior[i] - hidro[i])
    end
    @constraint(modelo, volume[i] >= 0)
end

# Restrição de demanda para N meses
for i in 1:N
    @constraint(modelo, termo[i] + hidro[i] == demanda[i])
end

# Função objetivo
@objective(modelo, Min, custo_termo * sum(termo))

# Resolvendo o problema
optimize!(modelo)

#---------------------------------------------------------------------Verifica a solução-----------------------------------------------------------------------------#

if termination_status(modelo) == MOI.OPTIMAL
    println("Uso de usinas termoelétricas por mês:")
    for i in 1:N
        println("Mês $i: ", value(termo[i]))
    end

    println("Uso de usinas hidroelétricas por mês:")
    for i in 1:N
        println("Mês $i: ", value(hidro[i]))
    end

    println("Valor ótimo da função objetivo: ", objective_value(modelo))
else
    println("O modelo não encontrou uma solução ótima.")
end

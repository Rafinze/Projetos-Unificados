####################################
# Modelagem com n usinas e n meses #
#   Rafael Pires Moreira Silva     #
####################################

using CSV
using HiGHS
using JuMP
using DataFrames 

#------------------------------------------------------------------------Dados---------------------------------------------------------------------------------------#

chuva_data = CSV.read("C:/Users/bruno/Desktop/IC/Dados/dados_demanda - chuva_meses.csv", DataFrame)
volume_inicial = [110, 120, 90, 130, 100]
custo_termo = [100]
vol_max = [1300, 1400, 1100, 1500, 1200]
Meses = 2
num_usinas_hidro = 5 #quantidade de hidro
n_termos = 1 #quantidade de termos
T = [1500] # Capacidade máxima das usinas termoelétricas
capacidade_hidro = [800, 900, 600, 1000, 700]  # Capacidade das 5 usinas hidroelétricas 
modelo = Model(HiGHS.Optimizer) #Criação do objeto do modelo

demanda = zeros(Meses)
for i in 1:Meses
    demanda[i] = 1000
end

m_aux = Matrix(chuva_data)
M_chuva_data=m_aux[:,2:num_usinas_hidro+1]
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#



#--------------------------------------------------------------------------Variáveis---------------------------------------------------------------------------------#
@variable(modelo, 0 <= termo[1:Meses, i = 1:n_termos] <= T[i]) # Variável de decisão para as usinas termoelétricas
@variable(modelo, 0 <= hidro[1:Meses, i = 1:num_usinas_hidro] <= capacidade_hidro[i]) # Variável de decisão para as usinas hidroelétricas
@variable(modelo, 0 <= volume[1:Meses,i = 1:num_usinas_hidro] <= vol_max[i]) #Varável de decisão para os volumes dos reservatórios
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------Restrições---------------------------------------------------------------------------------#

# Restrições para o volume
for mes in 1:Meses
    if mes == 1
        # O volume de cada reservatorio de cada usina após o uso das hidroelétricas
        @constraint(modelo, volume[mes, :] .== volume_inicial .- hidro[mes, :])
    end
end


for mes in 2:Meses
        # Restrição de volume para os próximos meses em cada usina considerando chuva e defluência
        for usina in 1:num_usinas_hidro
                @constraint(modelo, volume[mes, usina] .== volume[mes-1, usina]#=volume mes anterior =#+ M_chuva_data[mes,usina]#=chuva de cada mes e em cada usina=# - hidro[mes, usina]#=gasto de agua em cada mes em cada usina =#)
        end
end

# Restrição de demanda para N meses
for mes in 1:Meses
    @constraint(modelo, sum(termo[mes,usina] for usina=1:n_termos) + sum(hidro[mes,usina] for usina in 1:num_usinas_hidro) == demanda[mes] )
end

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#




#-----------------------------------------------------------------------Função objetivo------------------------------------------------------------------------------#
@objective(modelo, Min, sum(sum(custo_termo[usina]*termo[mes, usina] for usina = 1:n_termos) for mes = 1:Meses))
optimize!(modelo)
print(modelo)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#



#---------------------------------------------------------------------Verifica a solução-----------------------------------------------------------------------------#
if termination_status(modelo) == MOI.OPTIMAL
    println("Uso de usinas termoelétricas por mês:")
    for i in 1:Meses
        println("Mês $i: ", [value(termo[i,j]) for j in 1:n_termos])
    end
    println("Uso de usinas hidroelétricas por mês:")
    for i in 1:Meses
        println("Mês $i: ", [value(hidro[i, j]) for j in 1:num_usinas_hidro])
    end

    println("Valor ótimo da função objetivo: ", objective_value(modelo))
else
    println("O modelo não encontrou uma solução ótima.")
end
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#
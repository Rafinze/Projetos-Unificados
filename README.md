
# Projetos Unificados de Otimização Energética

Este repositório é uma coleção de projetos e estudos desenvolvidos em **Julia**, com foco na otimização de sistemas de energia. Os modelos abordam principalmente problemas de despacho hidrotérmico, utilizando técnicas como a Programação Dinâmica Dual Estocástica (SDDP).

## 🚀 Tecnologias Utilizadas
* **[Julia](https://julialang.org/)**: Linguagem de programação de alta performance para computação técnica.
* **[SDDP.jl](https://github.com/JuliaStochOpt/SDDP.jl)**: Biblioteca para implementação de algoritmos Stochastic dual dynamic programming em Julia.

## 📂 Estrutura do Repositório

O repositório está organizado em pastas de projetos e arquivos de script individuais.

### Modelos e Projetos (Pastas)

| Projeto | Descrição |
| :--- | :--- |
| `SDDP_4_usinas` | Modelo de otimização com 4 usinas hidrelétricas utilizando SDDP, para um primeiro teste do pacote SDDP. |
| `SDDP_Exemplo` | Um modelo de exemplo para demonstrar o uso do SDDP. |
| `SDDP_Functions` |  Um módulo com funções auxiliares para os modelos SDDP. |
| `4 hidros sddp 2` | Outra versão ou abordagem de um modelo com 4 usinas hidrelétricas. |
| `tentativa 4 hidros`| Uma pasta de desenvolvimento ou teste para o modelo de 4 hidrelétricas. |
| `Codigo N meses` | Modelo para otimização de um horizonte de N meses. |
| `Codigo com 2 meses automatizado` | Versão automatizada do modelo para um horizonte de 2 meses. |
| `modelo_base_sem_SDDP` | Um modelo de referência ou base que não utiliza a metodologia SDDP, para ter com o que comparar. |



### Scripts Individuais (Arquivos)

| Arquivo | Descrição |
| :--- | :--- |
| `Código Lagrange` | Implementação manual da abordagem do problema com a utilização do dual, para um horizonte de planejamento de n meses. |
| `SDDP 4 hidros.jl` | Script principal para o modelo SDDP com 4 usinas hidrelétricas. |
| `SDDP 4 termicas.jl` | Script principal para um modelo SDDP com 4 usinas termelétricas. |
| `Abordagem dinâmica para 2 meses.jl` | Implementação de uma abordagem de programação dinâmica para um horizonte de 2 meses. |
| `Modelo com resolução direta mais avançado.jl`| Um modelo de otimização mais complexo, talvez com resolução determinística. |
| `Código base.jl` | Um script inicial ou de base para os estudos. |
| `Código Julia simples.jl` | Um script simples para testes ou demonstrações iniciais em Julia. |


## 🛠️ Como Utilizar

Para executar os projetos, você precisará ter o [Julia](https://julialang.org/downloads/) instalado em seu sistema.

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/Rafinze/Projetos-Unificados.git](https://github.com/Rafinze/Projetos-Unificados.git)
    ```

2.  **Navegue até a pasta do projeto desejado:**
    ```bash
    cd Projetos-Unificados/SDDP_4_usinas
    ```

3.  **Execute o script Julia:**
    (Este é um exemplo, o comando pode variar)
    ```bash
    julia nome_do_script.jl
    ```

## 🤝 Como Contribuir

Contribuições são bem-vindas! Se você tiver sugestões de melhorias, correções de bugs ou novos modelos, sinta-se à vontade para:

1.  Fazer um **Fork** deste repositório.
2.  Criar uma nova **Branch** (`git checkout -b feature/sua-feature`).
3.  Fazer **Commit** das suas alterações (`git commit -m 'Adiciona nova feature'`).
4.  Fazer **Push** para a Branch (`git push origin feature/sua-feature`).
5.  Abrir um **Pull Request**.

## 📄 Licença

Este projeto não possui uma licença definida.

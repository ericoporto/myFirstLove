Codename-LT
================

os TO-DOs do projeto para o final

[ ] adicionar uma variavel pra contar os radios e somar 1 pra cada radio coletado (print console se debug ativado)

[ ] adicionar uma ui pra desenhar o número de radios coletados não usados

[ ] adicionar um trigger pra se nao estiver em diálogo e se radio>1, fazer radio -1 e chamar cutscene

[ ] adicionar uma função pra matar os agentes num raio

[ ] mudar a força no shader pra dar efeitos soh num período referente aos tiros

[ ] mover o raio de alcance do agente para ficar no meio de onde ele está olhando: criar uma função q recebe a direção do agente, a posição do agente e o raio do circulo e diz o centro do círculo

[ ] ajustar o raio do circulo de acordo e guardar o centro do circulo no agente

[ ] usar as informações guardadas no agente pra desenhar corretamente o circulo na tela de debug

[ ] adicionar, via tiled, uma direção inicial para o agente

[ ] adicionar um movimento de patrulha 'anda dois tile, volta dois tile' no agente, tendo ele dois estados, patrulhando e perseguindo.

[ ] fazer que quando o agente toca o player, aparece alguma mensagem de 'perdeu playboy' e resetar o player na posição inicial do level (acho que é só setLevel(last_level) !!!)

[ ] adicionar um estado de fim e conectar ele nos créditos

[ ] adicionar janelas nos mapas para a origem dos tiros de sniper fazer sentido

[ ] adicionar uma camada de tiles e desenhar mais coisas nos mapas.



boilerplate code from various sources for [Löve](http://www.love2d.org) with typical stuff needed for game jams like [ludum dare](http://www.ludumdare.com/compo/)

Uses the following:
* [hump](https://github.com/vrld/hump) for vectors, gamestates, timers, tweens
* [SLAM](https://github.com/vrld/Stuff/tree/master/slam) for better sound control
* Proxies: on demand resource loading

Thanks go to [VRLD](https://github.com/vrld/)
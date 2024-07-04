#INCLUDE "PROTHEUS.CH"
/* Este fonte terá as funções de x3_cbox do PLS */
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRWEBPRE
Retorna os novos status de protocolo da TISS 
@author Karine Riquena Limp
@since 12/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSSTATISS()
Local cRet := "1=Recebido;2=Em análise;3=Liberado para pagamento;4=Encerrado sem pagamento;5=Analisado e aguardando liberação para o pagamento;6=Pagamento efetuado;7=Não localizado;8=Aguardando informação complementar"
Return cRet

Function PLSGUTISS()
Local cRet := "1=Autorizado;2=Em análise;3=Negado;4=Aguardando justificativa técnica do solicitante;5=Aguardando documentação do prestador;6=Solicitação cancelada;7=Autorizado parcialmente"
Return cRet
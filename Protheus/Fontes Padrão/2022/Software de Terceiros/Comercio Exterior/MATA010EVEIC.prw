#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'
#include 'MATA010EVEIC.ch'

/*{Protheus.doc} MATA010EVEIC
Eventos padrão do Produto, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Rotina :Criada para executar Exclusão de tabela NVE associada ao produto dentro do SIGAEIC
Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Nilson César
@since 20/06/2018
@version P12.1.17
*/
CLASS MATA010EVEIC FROM FWModelEvent

	DATA lIntEIC
	DATA nOpc
	DATA cCodProduto
	DATA cCodGrupo
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010EVEIC

::lIntEIC		:= (cModulo == "EIC")
EasyNVEChk(.F.)

Return

METHOD InTTS(oModel, cID) CLASS MATA010EVEIC

Local lRet 	:= .T.
Local cError 	:= ""
::nOpc 		  := oModel:getOperation()
::cCodProduto := oModel:GetValue("SB1MASTER", "B1_COD")
::nOpc 		  := oModel:getOperation()
	
If ::lIntEIC	

	If ::nOpc == MODEL_OPERATION_UPDATE
		//Atualiza a tabela EIM - Classificação N.V.A.E (SIGAEIC)
		If ExistFunc('EasyNVEChk') .And. EasyNVEChk()
         MsgRun( STR0002 + CHr(13) + Chr(10) + STR0003 , STR0001 , {|| EasyValNVE("MATA010") } ) // "Aguarde enquanto a tabela N.V.E associada ao item com a n.c.m anterior é excluída... "
		EndIf
	EndIf

EndIf

Return lRet

METHOD ModelPosVld(oModel) CLASS MATA010EVEIC
Local lRet := .T.

	::nOpc := oModel:getOperation()
		
Return lRet
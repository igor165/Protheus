#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#define _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} MATA010DMS
Eventos padrão para o Produto quando MV_VEICULO igual a "S" - Modulos DMS
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17
 
/*/
CLASS MATA010DMS FROM FWModelEvent
	
	DATA cCodProduto
	DATA cCodGrupo
	DATA cCodIte
	DATA cCodGrpAnt
	DATA nOpc

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD InTTS()
	METHOD ModelPosVld()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010DMS

Return

/*/{Protheus.doc} Activate
Metodo executado no Activate das Telas

@type metodo
 
@author Andre Luis Almeida
@since 29/03/2018
@version P12.1.17
/*/
METHOD Activate(oModel) CLASS MATA010DMS

::nOpc := oModel:GetOperation()

If ::nOpc == MODEL_OPERATION_UPDATE // ALTERACAO
	::cCodGrpAnt := oModel:GetValue("SB1MASTER", "B1_GRUPO") // Quando ALTERAR - salvar Grupo Anterior
EndIf

Return

/*/{Protheus.doc} ModelPosVld
Metodo executado na pós validação do modelo, antes de realizar a gravação

@type metodo
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA010DMS
Local lRet := .T.
Local cMsg := ""
	
	::cCodProduto := oModel:GetValue("SB1MASTER", "B1_COD")
	::cCodGrupo   := oModel:GetValue("SB1MASTER", "B1_GRUPO")
	::cCodIte     := oModel:GetValue("SB1MASTER", "B1_CODITE")

	If ::nOpc == MODEL_OPERATION_INSERT .or. ::nOpc == MODEL_OPERATION_UPDATE

		If ::nOpc == MODEL_OPERATION_INSERT .and. !Empty(::cCodIte) // CODITE digitado
			lRet := ExistChav( "SB1" , ::cCodGrupo + ::cCodIte , 7 , .F. ) // NÃO permitir mesmo Grupo + CodIte ( SB1 indice 7 )
			If !lRet
				cMsg := _CRLF + RetTitle("B1_GRUPO")  + ::cCodGrupo
				cMsg += _CRLF + RetTitle("B1_CODITE") + ::cCodIte
				Help(" ",1,"JAGRAVEI",,cMsg,3,1) //Já existe Cod Item cadastrado! Verifique o campo B1_CODITE através do módulo SIGAVEI.
			EndIf
		Else // B1_CODITE não foi digitado
			If Empty(::cCodIte) 
				If strzero(nModulo,2) $ "11/14/41/" // Validar somente para os Modulos: 11-Veiculos, 14-Oficina e 41-Auto-Peças
					Help(" ",1,"OBRIGAT2",,RetTitle("B1_CODITE"),4,1)
					lRet := .f.
				Else
					oModel:SetValue( "SB1MASTER" , "B1_CODITE" , ::cCodProduto ) // Carregar com o mesmo conteudo do B1_COD
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Metodo executado logo após a gravação completa do modelo, mas dentro da transação

@type metodo
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17 
/*/
METHOD InTTS(oModel,cModelId) CLASS MATA010DMS

Local oVmi
Local oVmiPars
Local nCntFor    := 0
Local aFilis     := {}
Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial logada trabalha
Local cBkpFilAnt := cFilAnt

	If ::nOpc == MODEL_OPERATION_UPDATE // ALTERACAO

		If ::cCodGrpAnt != ::cCodGrupo // Se grupo foi modificado roda rotina de alteracao de grupo
			FGX_ALTGRU( ::cCodProduto , ::cCodIte , ::cCodGrpAnt , ::cCodGrupo )
		EndIf
		If ExistFunc('OFAGVmi') .and. ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi     := OFAGVmi():New()
			oVmiPars := OFAGVmiParametros():New()
			aFilis   := oVmiPars:filiais()
			For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
				cFilAnt := aFilis[nCntFor]
				cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial posicionada trabalha
				If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
					If oVmiPars:FilialValida(cFilAnt)
						oVMi:Trigger({;
							{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
							{'ORIGEM', "MATA010DMS_InTTS_ALT"       },;
							{'PECAS' , {::cCodProduto              }} ;
						})
					EndIf
				EndIf
			Next
			cFilAnt := cBkpFilAnt
		EndIf

	ElseIf ::nOpc == MODEL_OPERATION_INSERT // INCLUSAO

		If ExistFunc('OFAGVmi') .and. ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi     := OFAGVmi():New()
			oVmiPars := OFAGVmiParametros():New()
			aFilis   := oVmiPars:filiais()
			For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
				cFilAnt := aFilis[nCntFor]
				cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial posicionada trabalha
				If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
					If oVmiPars:FilialValida(cFilAnt)
						oVMi:Trigger({;
							{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
							{'ORIGEM', "MATA010DMS_InTTS_INC"       },;
							{'PECAS' , {::cCodProduto              }} ;
						})
					EndIf
				EndIf
			Next
			cFilAnt := cBkpFilAnt
		EndIf

	EndIf

Return
#include "CRMN540.CH"
#Include 'Protheus.ch'


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMN540GTT()

Rotina responsável por retornar a data e hora de registros do umov.Me na AIO

@param	  cIDUnic    - código único da atividade uMov.Me 
          cTipoDados - Tipo do dado que deverá ser retornado "1" = Data , "2" = Hora
          cTipoAtiv  -  Tipo da Atividade que deverá ser buscada pode ser "1" = Check-in, 
          "2" = Check-out, "3" = Cancelado
		 
@return  xRet - retorno desejada conforme o parâmetro (cTipoDados) passado.

@author   Victor Bitencourt
@since    04/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------------------------
Function CRMN540GTT(cIDUnic,cTipoDados,cTipoAtiv)

Local aArea     := GetArea()
Local aAreaAIO  := AIO->(GetArea())
Local xRet		  := Nil

Default cIDUnic    := ""
Default cTipoDados := ""
Default cTipoAtiv  := ""

AIO->(DbSetOrder(3))	//AIO_FILIAL+AIO_TIPO+AIO_IDAGE

If !Empty(cIDUnic)

	If AIO->(DbSeek(xFilial("AIO")+cTipoAtiv+cIDUnic))
	
		If cTipoDados == "1"
			xRet := AIO->AIO_DATA
		ElseIf cTipoDados == "2"
			xRet := Rtrim(AIO->AIO_HORA)
		EndIf
	EndIf	
EndIf	

RestArea(aAreaAIO)
RestArea(aArea)

Return xRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMN540ENT()

rotina responsável por retornar a descrição do registro passado

@param	  cAlias - alias do registro
          cChave - chave do registro
		 
@return  cRet - descrição do registro 

@author   Victor Bitencourt
@since    04/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------------------------
Function CRMN540ENT(cAlias,cChave)

Local aArea     := GetArea()
Local cRet		  := ""

Default cAlias  := ""
Default cChave  := ""

If !Empty(cAlias) .AND. !Empty(cChave)

	Do Case 
		Case cAlias == "SA1"
			 cRet := Posicione(cAlias,1,xFilial(cAlias)+cChave,"A1_NOME")
		Case cAlias == "SUS"
			 cRet := Posicione(cAlias,1,xFilial(cAlias)+cChave,"US_NOME")
		Case cAlias == "ACH"
			 cRet := Posicione(cAlias,1,xFilial(cAlias)+cChave,"ACH_RAZAO")
	EndCase	

EndIf	

RestArea(aArea)

Return cRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMN540GCD()

Rotina para gerar Código unico para gravação do registro na tabela

@param	  cEntidade - indica para qual entidade será gerado o código 
		 
@return  cCodProx -> código gerado

@author   Victor Bitencourt
@since    04/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------------------------
Function CRMN540GCD(cEntidade)

Local aArea 	  := GetArea()
Local aAreaEnt  := (cEntidade)->(GetArea())
Local cCodProx  := ""

DbSelectArea("SX5")               
DbSetOrder(1)

DbSelectArea(cEntidade)
DbSetOrder(1)

If SX5->(DbSeek(xFilial("SX5")+STR0058))//"UV"
	cCodProx := Soma1(SX5->X5_CHAVE)
	If !((cEntidade)->(DbSeek(xFilial(cEntidade)+cCodProx)))
		RecLock("SX5",.F.)
			SX5->X5_CHAVE := cCodProx
		SX5->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaEnt)
RestArea(aArea)

Return cCodProx


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMN540VIG()

Rotina responsavel carregar a imagem integrada.

@param	   cUrl - URL da imagem integrada 
		 
@return   Nenhum

@author   Victor Bitencourt
@since    04/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------------------------
Function CRMN540VIG(cUrl)

Local oDlg		    := Nil
Local oTIBrowser  := Nil
Local aSize 	    := MsAdvSize()

Default cUrl := ""

// Atualiza as corrdenadas da Janela MAIN
oMainWnd:CoorsUpdate()
nMyWidth  := oMainWnd:nClientWidth - 10
nMyHeight := oMainWnd:nClientHeight - 30

If !Empty(cUrl)

	DEFINE DIALOG oDlg TITLE "Imagem" From aSize[7],00 To nMyHeight,nMyWidth PIXEL	

	oTIBrowser := TIBrowser():New(07,07,nMyHeight-220, nMyWidth-820,cUrl,oDlg)
	oTIBrowser:GoHome()
	
	ACTIVATE DIALOG oDlg CENTERED 

Else

	MsgAlert(STR0001)	//"Não foi integrada nenhuma imagem para esse registro."

EndIf

Return

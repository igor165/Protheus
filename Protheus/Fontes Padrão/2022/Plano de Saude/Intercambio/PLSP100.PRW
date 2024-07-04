#Include "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P100CheImp
Checa se arquivo ja foi importado

@author    PLS TEAM
@since     13/04/2005
/*/
//------------------------------------------------------------------------------------------
Function P100CheImp(cNomArq)
   Local cSql := ""
   Local lRet := .T.

   cSql := " SELECT 1 FROM "+RetSQLName("BA1")
   cSql += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"'"
   cSql += " AND BA1_ARQEDI = '"+cNomArq+"'"
   cSql += " AND D_E_L_E_T_ = ' ' "

   PLSQuery(cSql,"QCARQ")
   If !QCARQ->(Eof())
       MsgInfo('Arquivo já IMPORTADO!')
	   lRet := .F.
   EndIf
   
   QCARQ->(DbCloseArea())
   
   DbSelectArea("DE9")	


Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A100Prod
Trata Produto e versao

@author  Alexander
@version P12
@since   13/04/2005
/*/
//-------------------------------------------------------------------
Function A100Prod(cEntrada)       

    Local cRet	:= ""
                              
    If SubString(cEntrada,Len(cEntrada),1) == '1'
       cRet := SubString(cEntrada,1,4) //Produto
    Else 
       cRet := SubString(cEntrada,5,3)	//Versao
    EndIf     
    
Return cRet 
              

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBT6A100
Traz os produtos de um sub-contrato no filtro BT6100

@author  Renan Sakai
@version P12
@since   13/04/2005
/*/
//-------------------------------------------------------------------
Function PLSBT6A100()
Local cCodPro := ""
Local lRet := .F.

BT6->(DbSetOrder(1))//BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
If BT6->(MsSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) ))
	While BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) == BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB) .And. !BT6->(Eof()) 
		cCodPro += BT6->(BT6_CODPRO+BT6_VERSAO)+"|"
		BT6->(DbSkip())
	EndDo

	If BI3->BI3_CODINT == BT6->BT6_CODINT .and. BI3->(BI3_CODIGO+BI3_VERSAO) $ cCodPro
		lRet := .T.
	EndIf
EndIf	

Return lRet
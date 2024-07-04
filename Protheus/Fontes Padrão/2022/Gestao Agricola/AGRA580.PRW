#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA580.ch"

/*/{Protheus.doc} AGRA580
//Função para criação das views com as informações de qualidade de grãos/ algodão
@author marina.muller/ silvana.torres
@since 05/07/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA580()
    Local lRet := .T.
    
	If MsgYesNo(STR0001) //"Deseja criar as views com informações de qualidade de grãos/ algodão?"
	   //função para criação da view informações qualidade de grãos
	   lRet := AGRA580NJK()
	   
	   If lRet
	    	lRet := AGRA580DX7() //função para criação da view de informações de qualidade de algodão
	    	
	    	If .NOT. lRet
	    		ApMsgAlert(STR0005 + "V_QUALIDADE_ALGODAO") //"Houve erro na criação da view: "
	    	EndIf
	    Else
	    	ApMsgAlert(STR0005 + "V_QUALIDADE_GRAOS") //"Houve erro na criação da view: "
	    EndIf
	EndIf
	
	If lRet
	   ApMsgAlert(STR0004) //"Foram criadas as views V_QUALIDADE_GRAOS e V_QUALIDADE_ALGODAO."
	EndIf	
	
Return 

/*/{Protheus.doc} AGRA580NJK
Função que cria a VIEW V_QUALIDADE_GRAOS
@author marina.muller
@since 07/07/2018
@version 1.0

@type function
/*/
Static Function AGRA580NJK()
	Local aArea      := GetArea()
	Local lRet 		 := .T.
	Local nSqlRet    := 0
	Local cQuery     := ""
	
	__DWIsDebug := "1"

    //se existir view no banco dropa para depois recriar 
    If DWCanOpenView("V_QUALIDADE_GRAOS")
       cQuery := " DROP VIEW V_QUALIDADE_GRAOS "
       nSqlRet := DWSQLExec(cQuery)
       cQuery := ""
    EndIf   
    
    //se não tiver erros
    If nSqlRet == 0
	    //cria a view no banco de dados
		cQuery :=  " CREATE VIEW V_QUALIDADE_GRAOS AS "
        cQuery +=  " SELECT NJK.NJK_FILIAL, NJK.NJK_CODROM, NJK.NJK_ITEM, NJJ.NJJ_CODSAF, NJJ.NJJ_CODPRO, " 
        cQuery +=  "        SB1.B1_DESC, NJJ.NJJ_TABELA, NNI.NNI_DESCRI, NJK.NJK_CODDES, NNH.NNH_DESCRI,  " 
        cQuery +=  "        NJK.NJK_TPCLAS, NJK.NJK_BASDES, NJK.NJK_OBRGT, NJK.NJK_PERDES, NJK.NJK_READES," 
        cQuery +=  "        NJK.NJK_QTDDES, NJK.NJK_DESRES, NJK.NJK_RESINF "  
		cQuery +=  "   FROM " + RetSqlName('NJK')+ " NJK          "
		cQuery +=  "  INNER JOIN " + RetSqlName('NJJ')+ " NJJ     " 
		cQuery +=  "     ON NJK.NJK_FILIAL = NJJ.NJJ_FILIAL "
		cQuery +=  "    AND NJK.NJK_CODROM = NJJ.NJJ_CODROM "
		cQuery +=  "    AND NJK.D_E_L_E_T_ = '' "
		cQuery +=  "    AND NJJ.D_E_L_E_T_ = '' "
		cQuery +=  "  INNER JOIN " + RetSqlName('SB1')+ " SB1 "
		cQuery +=  "     ON SB1.B1_COD     = NJJ.NJJ_CODPRO "      
		cQuery +=  "    AND SB1.D_E_L_E_T_ = '' " 
		cQuery +=  "  INNER JOIN " + RetSqlName('NNI')+ " NNI     "
		cQuery +=  "    ON NNI.NNI_CODIGO = NJJ.NJJ_TABELA  "
		cQuery +=  "   AND NNI.D_E_L_E_T_ = ''  "    
		cQuery +=  " INNER JOIN " + RetSqlName('NNH')+ " NNH "
		cQuery +=  "    ON NNH.NNH_CODIGO = NJK.NJK_CODDES  "
		cQuery +=  "   AND NNH.D_E_L_E_T_ = ''  " 
		
		nSqlRet := DWSQLExec(cQuery)
		
		If nSqlRet <> 0
			lRet := .F.
		EndIf
	//se tiver erros
	Else
	    ApMsgAlert(STR0002 + "V_QUALIDADE_GRAOS" + STR0003) //"Não foi possível criar a view //no banco de dados." 
	EndIf	

	RestArea(aArea)
	
Return lRet 

/*/{Protheus.doc} AGRA580DX7
Função que cria a VIEW V_QUALIDADE_ALGODAO que trás os dados de HVI dos fardinhos
@author silvana.torres
@since 07/07/2018
@version undefined

@type function
/*/
Static Function AGRA580DX7()
	Local aArea      := GetArea()
	Local lRet 		 := .T.
	Local nSqlRet    := 0
	Local cQuery     := ""

    //se existir view no banco dropa para depois recriar 
    If DWCanOpenView("V_QUALIDADE_ALGODAO")
       cQuery := " DROP VIEW V_QUALIDADE_ALGODAO "
       nSqlRet := DWSQLExec(cQuery)
       cQuery := ""
    EndIf   
    
    //se não tiver erros 
    If nSqlRet == 0
	    //cria a view no banco de dados
		cQuery := " CREATE VIEW V_QUALIDADE_ALGODAO AS "
		cQuery += " SELECT DX7.*, DXI_PSBRUT, DXI_PSLIQU, DXI_CLACOM, DXI_CLAVIS, DXI_BLOCO, DXI_PRDTOR, DXI_LJPRO, DXI_FAZ, DXI_FARDAO, DXI_CODVAR, 	"
		cQuery += "        DXI_CODCNJ, DXI_PRENSA, DXI_COSTEL, DXI_DATA, DXI_HORA, DXI_CODRES, DXI_ITERES, DXI_ROMSAI, DXI_CODUNB, DXI_CODTUR			"
		cQuery += "   FROM " + RetSqlName('DXI')+ " DXI	" 
		cQuery += "        INNER JOIN " + RetSqlName('DX7') + " DX7 ON "
		cQuery += "   	   DXI_FILIAL = DX7_FILIAL 	AND "
		cQuery += "	   	   DXI_SAFRA  = DX7_SAFRA 	AND "
		cQuery += "	   	   DXI_ETIQ   = DX7_ETIQ  		"
		cQuery +=  " WHERE DXI.D_E_L_E_T_	= ''    AND "
		cQuery +=  "       DX7.D_E_L_E_T_	= ''     	"
		
		nSqlRet := DWSQLExec(cQuery)
		
		If nSqlRet <> 0
			lRet := .F.
		EndIf
	//se tiver erros
	Else
	    ApMsgAlert(STR0002 + "V_QUALIDADE_ALGODAO" + STR0003) //"Não foi possível criar a view //no banco de dados." 
	EndIf	

	RestArea(aArea)
	
Return lRet 


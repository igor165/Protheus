#include 'protheus.ch'
#include 'parmtype.ch'

function AGRDELDS(pParChk)
	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cQuery 	:= ''
	Local LRet	 	:= .T.
	Local nx	 	:= 0
	Local oView     := FWViewActive()
	Local oModel    := oView:GetModel()
	Local oModelGX5	:= oModel:GetModel("GFE519BGX5")
	Local cDriver   := TCGetDB()
	Local cSp       := "||"
	
	Private aDocExc := {}

	//Busca DAK relacionada ao romaneio
	dbSelectArea("GWV")
	GWV->( dbSetOrder(4) )
	If GWV->( MSSeek(xFilial("GWV") +  pParChk[2] ))
		aAdd( aDocExc,  SubStr( GWV->GWV_NRROM, 1, TamSX3("DAK_COD")[1] ) )
		aAdd( aDocExc,  SubStr( GWV->GWV_NRROM, TamSX3("DAK_COD")[1] + 1, TamSX3("DAK_SEQCAR")[1] ) )
	EndIF
	
	//Se encontrou documentos de saída relacionados, será necessário eliminar
	If !Empty(aDocExc)
		lRet := .F.
		
		//Exclusão Doc. Saída
		MATA521B()
				
		//Verificar se registros foram eliminados
		cAliasQry := GetNextAlias()
		cQuery := " SELECT F2_FILIAL, F2_CARGA, F2_SEQCAR"
		cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "'"
		cQuery += "   AND SF2.F2_CARGA = '" + aDocExc[1] + "'"
		cQuery += "   AND SF2.F2_SEQCAR = '" + aDocExc[2] + "'"
		cQuery += "   AND SF2.D_E_L_E_T_ <> '*' "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
		If (cAliasQry)->(Eof())
			lRet := .T.
		EndIf
		(cAliasQry)->(dbCloseArea())
		
		//Zera o check-list do ponto de controle
		If lRet 
		    //Elimina o Registro da NJ5 e NJ6 quando SC9 for deletado
		    If cDriver == "MSSQL"
		       cSp := "+"
		    EndIf

			cQuery    := ""
			cAliasQry := GetNextAlias()
			cQuery := "select (NJ6_FILIAL " + cSp + " NJ6_CODCAR " + cSp + " NJ6_SEQCAR " + cSp + " NJ6_NUMPV " + cSp + ; 
		              " NJ6_ITEM " + cSp + " NJ6_SEQUEN " + cSp + " NJ6_PRODUT ) NJ6_CHAVE, " + ;
                      " (NJ6_FILIAL " + cSp + " NJ6_NUMPV " + cSp + " NJ6_ITEM " + cSp + " NJ6_SEQUEN " + cSp + " NJ6_PRODUT ) NJ5_CHAVE " + ;		              
		              "from " + RetSqlName("NJ6") + " NJ6 " + ;
		              "where NJ6_FILIAL = '" +xFilial("NJ6") + "' " +;
		              "and NJ6_CODCAR = '" + aDocExc[1] + "' " +;
		              "and NJ6_SEQCAR = '" + aDocExc[2] + "' " +;
		              "and D_E_L_E_T_ <> '*' "
		
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			(cAliasQry)->(dbGoTop())
			While !(cAliasQry)->(Eof())
			    cChaveNJ6 := (cAliasQry)->NJ6_CHAVE 
			    IF Select("NJ6") = 0
			       DbSelectArea("NJ6")
			    EndIf
			    
			    NJ6->(DbGoTop())
			    If NJ6->(DbSeek( cChaveNJ6 ))
	               RecLock("NJ6", .F.)
	               dbDelete()
	               MsUnLock()		
			    EndIF

			    cChaveNJ5 := (cAliasQry)->NJ5_CHAVE 
			    IF Select("NJ5") = 0
			    	DbSelectArea("NJ5")
			    EndIf
			    
			    NJ5->(DbGoTop())
			    If NJ5->(DbSeek( cChaveNJ5 ))
	               RecLock("NJ5", .F.)
	               dbDelete()
	               MsUnLock()		
			    EndIF
			    
			    (cAliasQry)->(dbSkip())
			EndDo
			
			IF Select("NJ6") > 0
			   NJ6->(dbclosearea())
			EndIf
			
			IF Select("NJ5") > 0
			   NJ5->(dbclosearea())
			EndIF
			
			IF Select(cAliasQry) > 0
			   (cAliasQry)->(dbCloseArea())
			EndIf		    

			For nX := 1 To oModelGX5:Length()
		        oModelGX5:GoLine( nX )
		        If oModelGX5:GetValue("GX5_CDPERG") != pParChk[5]
		        If !oModelGX5:IsDeleted()
		            oModelGX5:SetValue("GX5_RESPOS","2")
		           Endif
		        Endif
		    Next
		EndIf
	EndIf
	
	RestArea(aAreaAtu)

return lRet
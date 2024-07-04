#Include "protheus.ch"
#Include "totvs.ch"
#Include "FWMVCDEF.CH"

#xcommand aKill [<aArray>] => TM76LibArr(<aArray>)
#xcommand oKill [<oObj>]   => FreeObj(<oObj>);<oObj> := Nil

Static lTMF76Tre := ExistBlock("TMF76Tre")// Manipulação do Resultado do KM
Static lTMF12Rot := ExistBlock("TMF12Rot")	//-- Manipulação e validação do Roteiro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsF10Qry1³ Autor ³ Leandro paulino      ³ Data ³11.04.2016	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca os trechos do roteiro.						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsF10Qry1()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TmsF10Qry1(oMdlGrid, cRota, lByAlias,nFolder,cSerTms, aRetpag,aRetpagOri,cFilVge,cViagem)
Local oTempTable		:= NIL
Local cQuery 			:= ''
Local aRet				:= {}
Local cAliasT    		:= GetNextAlias()
Local aCampos			:= {}
Local cTabTmp			:= ''
Local oStructDJF     := oMdlGrid:GetStruct()
Local aCamposDJF     := aClone(oStructDJF:GetFields())
Local nPosDocs       := 0
Local nCount			:= 0

Default oMdlGrid 		:= Nil
Default cRota			:= ''
Default lByAlias		:= .T.
Default nFolder 		:= 1
Default cSerTms		:= '1'
Default aRetPag		:= {}
Default aRetpagOri	:= {}
Default cFilVge      := ""
Default cViagem      := ""

If ValType (nFolder) <> 'N'
	nFolder := Val(nFolder)
EndIf

nPosDocs := aScan( aCamposDJF , { |x| x[MODEL_FIELD_IDFIELD] == "DJF_DOCS" }) 

oTempTable := TmsF10Qry2(aCampos,nFolder,cSerTms, aRetpag, aRetpagOri,cFilVge,cViagem)

cTabTmp:= oTempTable:GetRealName()

If !Empty(cTabTmp)

	cQuery := " SELECT DISTINCT CASE WHEN TMP_RATEIO = '1' "
	cQuery += "						THEN 	'BR_VERDE'  "
	cQuery += "						WHEN TMP_RATEIO = '2' "
	cQuery += "						THEN 	'BR_AZUL'  "
	cQuery += "					ELSE 'BR_AMARELO' "
	cQuery += "					END DJF_LEGRAT,"
	
	cQuery += "					CASE WHEN TMP_DOCGER = '1' "
	cQuery += "						THEN 	'BR_VERDE'  "
	cQuery += "						WHEN TMP_DOCGER = '2' "
	cQuery += "						THEN 	'BR_AZUL'  "
	cQuery += "					ELSE 'BR_AMARELO' "
	cQuery += "					END DJF_LEGDOC,"
	
	cQuery += "					CASE WHEN TMP_VALTRE = '1' "
	cQuery += "						THEN 	'BR_VERDE'  "
	cQuery += "						WHEN TMP_VALTRE = '2' "
	cQuery += "						THEN 	'BR_AZUL'  "
	cQuery += "					ELSE 'BR_AMARELO' "
	cQuery += "					END DJF_LEGVAL,"
	
	cQuery += " 					TMP_FILORI DJF_FILORI, TMP_VIAGEM DJF_VIAGEM,  TMP_RATEIO DJF_RATEIO, TMP_DOCGER DJF_DOCGER	, TMP_VALTRE DJF_VALTRE	, TMP_TIPOPE DJF_TIPOPE , TMP_DATPRV DJF_DATPRE, TMP_HORPRV DJF_HORPRE, "
	cQuery += " 					TMP_CLIENT DJF_CLIENT, TMP_LOJA DJF_LOJA		,TMP_SEQEND DJF_SEQEND , TMP_CLIDEV DJF_CLIDEV	, TMP_LOJDEV DJF_LOJDEV , TMP_NCONTR DJF_NCONTR, TMP_DATEMI DJF_DATEMI, "
	cQuery += " 					TMP_RECNO DJF_RECNO 	, TMP_CLIDDO DJF_CLIDDO	, TMP_LOJDDO DJF_LOJDDO	, SA1.A1_NOME DJF_NOME, TMP_TIPOKM	DJF_TIPOKM, TMP_IDLIN DJF_IDLIN ,TMP_ROTA  DJF_ROTA ,TMP_DATDTW DJF_DATDTW , TMP_HORDTW DJF_HORDTW , 0 R_E_C_N_O_ ," 
		
	If "ORACLE" $ Upper(TCGetDB())  
   		cQuery += "   UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(TMP_DOCS, 4000,1)) DJF_DOCS ,  "
	ElseIf "POSTGRES" $ Upper(TCGetDB()) 
		cQuery += "   CAST( ENCODE( TMP_DOCS, 'escape' ) AS VARCHAR(8000))  DJF_DOCS , "
	Else
	    cQuery += "   CONVERT(VARCHAR(8000),CONVERT(BINARY(8000)  ,TMP_DOCS)) As DJF_DOCS ,  "
	EndIf
	
	cQuery += "					CASE WHEN 	TMP_KM = 0 THEN  "
	cQuery += "						CASE WHEN 	DDO.DDO_KM IS NOT NULL "
	cQuery += "							THEN 	DDO.DDO_KM  "
	cQuery += "						ELSE 0  "
	cQuery += "	        			END		"
	cQuery += "	        		ELSE TMP_KM   "
	cQuery += "					END DJF_KM,"
		
	cQuery += "					CASE WHEN 	DUL.DUL_END IS NOT NULL "
	cQuery += "						THEN 	DUL.DUL_END  "
	cQuery += "					ELSE SA1.A1_END"
	cQuery += "					END DJF_END,"
	
	cQuery += "					CASE WHEN 	DUL.DUL_BAIRRO IS NOT NULL" 
	cQuery += "						THEN 	DUL.DUL_BAIRRO  "
	cQuery += "					ELSE SA1.A1_BAIRRO" 
	cQuery += "					END DJF_BAIRRO,"
	
	cQuery += "					CASE WHEN 	DUL.DUL_MUN IS NOT NULL "
	cQuery += "						THEN 	DUL.DUL_MUN  "
	cQuery += "					ELSE SA1.A1_MUN"
	cQuery += "					END DJF_MUN,"
	
	cQuery += "					CASE WHEN 	DUL.DUL_EST IS NOT NULL "
	cQuery += "						THEN 	DUL.DUL_EST  "
	cQuery += "					ELSE SA1.A1_EST"
	cQuery += "					END DJF_EST, TMPX.TMP_ORDROT"
	cQuery += " FROM        " + cTabTmp + " TMPX "
	
	cQuery += " INNER JOIN  " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON 		SA1.A1_FILIAL = '" + FwxFilial('SA1')	+ "' "
	cQuery += " AND 		SA1.A1_COD 	= TMPX.TMP_CLIENT	" 
	cQuery += " AND 		SA1.A1_LOJA 	= TMPX.TMP_LOJA  	"
	cQuery += " AND 		SA1.D_E_L_E_T_ = ' '				"
	
	cQuery += " LEFT JOIN 	" + RetSQlName("DUL") + " DUL "
	cQuery += " ON 		DUL.DUL_FILIAL = '" + FwxFilial('DUL') + "' " 
	cQuery += " AND 		DUL.DUL_CODCLI = TMPX.TMP_CLIENT"
	cQuery += " AND 		DUL.DUL_LOJCLI = TMPX.TMP_LOJA 	"
	cQuery += " AND 		DUL.DUL_SEQEND = TMPX.TMP_SEQEND "
	cQuery += " AND		DUL.D_E_L_E_T_ = ' '			"
		
	cQuery += " LEFT JOIN " + RetSqlName("DDO") + " DDO "
	cQuery += " ON 		DDO.DDO_FILIAL 	= '" + Fwxfilial("DDO") + "' " 	 
	cQuery += " AND 		DDO_CLIDE  	    = TMPX.TMP_CLIDE  "  
	cQuery += " AND 		DDO_LOJDE 		= TMPX.TMP_LOJDE  "
	cQuery += " AND 		DDO_SEQDE 		= TMPX.TMP_SEQDE  "
	cQuery += " AND 		DDO_CLIATE 		= TMPX.TMP_CLIATE "
	cQuery += " AND 		DDO_LOJATE 		= TMPX.TMP_LOJATE "
	cQuery += " AND 		DDO_SEQATE      = TMPX.TMP_SEQATE "
	cQuery += " AND 		DDO_CODCLI 		= TMPX.TMP_CLIDDO "
	cQuery += " AND 		DDO_LOJCLI 		= TMPX.TMP_LOJDDO "
	cQuery += " AND		DDO.D_E_L_E_T_ 	= ' '             "
	cQuery += " ORDER BY    TMPX.TMP_ORDROT "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.T.,.T.)
	TcSetField(cAliasT,"DJF_DATPRE","D",8,0)
	TcSetField(cAliasT,"DJF_DATDTW","D",8,0)
	
	If lByAlias 
		// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
		aRet := FWLoadByAlias( oMdlGrid , cAliasT , NIL , Nil , Nil , .t. ) 
	EndIf
	
	(cAliasT)->(DbGoTop())
	
	nCount := 1
	
	// Atualiza o Campo Memo 
	While (cAliasT)->(!Eof())
		
		aRet[nCount][2][nPosDocs] := (cAliasT)->DJF_DOCS
		
		(cAliasT)->(dbSkip())
		 nCount += 1
		 
	EndDo
	
	
	(cAliasT)->(DbCloseArea())
			
EndIf

oTempTable:Delete()

Return aRet

/*--------------------------------------------------------------------------------------------------------
{Protheus.doc} TmsF10Qry2
			Converte Vetor Em Tabela No Banco De Dados
@author  	Leandro Paulino
@version 	Versao P12
@since		28/Abr/2016
@return 	Nil
@obs .
//------------------------------------------------------------------------------------------------------*/
Function TmsF10Qry2( aCampos, nFolder, cSerTms, aRetpag, aRetpagOri ,cFilVge,cViagem )

Local aArea		:= GetArea()
Local n1		:= 0
Local n2		:= 0
Local nI		:= 0
Local aStruTab	:= {}
Local cDrive	:= __LocalDrive
Local cTab1		:= 'DJF'
Local ctab2		:= 'DDO'
Local cTab3 	:= 'DT5'
Local aDados	:= {}
Local nPos 		:= 0
Local oTempTable:= NIL
Local aRetUsu 	:= {}
Local aFldDJF 	:= {}
Local aFldDDO 	:= {}
Local aFldDT5 	:= {}


Default aCampos    := {}
Default nFolder    := 1
Default cSerTms    := '1'
Default aRetPag    := {}
Default aRetpagOri := {}
Default cFilVge    := ""
Default cViagem    := ""

If nFolder == 1
	aDados:= Tmsf10MntR(aRetPag,Iif(Len(aRetpagOri)>0,aRetpagOri[nFolder],{}),cSerTms,,,cFilVge,cViagem ) //--Função que montará o array do roteiro da viagem
Else
	aDados:= Tmsf10MntR(aRetPag,Iif(Len(aRetpagOri)>0,aRetpagOri[nFolder],{}),cSerTms,nFolder,,cFilVge,cViagem ) //--Função que montará o array do roteiro da viagem
EndIf

//-- Permite a validação e manipulação dos dados do roteiro
If lTMF12Rot
	aRetUsu := ExecBlock("TMF12Rot",.F.,.F.,{1,aDados,nFolder,})	//-- Acao (1-Na carga do grid / 2-Na validação da model)
																	//-- Vetor com os dados do roteiro (Somente na carga do grid)
																	//-- Folder
																	//-- Model (Somente na validação da model)
	If ValType(aRetUsu) != "A" .Or. Len(aRetUsu) != 2
		aDados := aRetUsu[2]
	Endif
EndIf
nFolder++	
	
//-- Verifica o drive de criacao do temporario ( Altera RDD )
If TcSrvType() <> "AS/400"
	cDrive := __cRDD
EndIf
	
//-- Define Estrutura Da Tabela	
aFldDJF := ApBuildHeader(cTab1)
For nI := 1 To Len(aFldDJF)
	If AllTrim(aFldDJF[nI][2]) $ "DJF_CLIENT|DJF_LOJA|DJF_SEQUEN|DJF_TIPOPE|DJF_FILORI|DJF_VIAGEM|DJF_KM|DJF_IDLIN|DJF_ROTA|"
		aAdd( aStruTab, { StrTran(aFldDJF[nI][2],cTab1,"TMP") , aFldDJF[nI][8] , aFldDJF[nI][4] , aFldDJF[nI][5] })
	EndIf
Next

aFldDDO := ApBuildHeader(cTab2)
For nI := 1 To Len(aFldDDO)
	If  AllTrim(aFldDDO[nI][2]) $ "DDO_CLIDE|DDO_LOJDE|DDO_SEQDE|DDO_CLIATE|DDO_LOJATE|DDO_SEQATE|DDO_CODCLI|DDO_LOJCLI|"	
		If 	(aFldDDO[nI][2]) <> "DDO_CODCLI" .And. 	(aFldDDO[nI][2]) <> "DDO_LOJCLI" 
			aAdd( aStruTab, { StrTran(aFldDDO[nI][2],cTab2,"TMP") , aFldDDO[nI][8] , aFldDDO[nI][4] , aFldDDO[nI][5] })
		ElseIf aFldDDO[nI][2] == "DDO_CODCLI"				
			aAdd( aStruTab, { "TMP_CLIDDO" , aFldDDO[nI][8] , aFldDDO[nI][4] , aFldDDO[nI][5] })
		Else
			aAdd( aStruTab, { "TMP_LOJDDO" , aFldDDO[nI][8] , aFldDDO[nI][4] , aFldDDO[nI][5] })
		EndIf
		
	EndIf	
Next

aFldDT5 := ApBuildHeader(cTab3)
For nI := 1 To Len(aFldDT5)
	If  AllTrim(aFldDT5[nI][2]) $ "DT5_DATPRV|DT5_HORPRV|DT5_SEQEND|DT5_CLIDEV|DT5_LOJDEV|DT5_NCONTR"
		aAdd( aStruTab, { StrTran(aFldDT5[nI][2],cTab3,"TMP") , aFldDT5[nI][8] , aFldDT5[nI][4] , aFldDT5[nI][5] })
	EndIf
Next

aSize(aFldDJF, 0)
aFldDJF := Nil

aSize(aFldDDO, 0)
aFldDDO := Nil

aSize(aFldDT5, 0)
aFldDT5 := Nil

//--Inclusao de campos que nao existem no SX3
aAdd( aStruTab, { "TMP_RATEIO" , 'C' , 1 , 0 })		
aAdd( aStruTab, { "TMP_DOCGER" , 'C' , 1 , 0 })
aAdd( aStruTab, { "TMP_VALTRE" , 'C' , 1 , 0 })
aAdd( aStruTab, { "TMP_RECNO " , 'N' ,10 , 0 })
aAdd( aStruTab, { "TMP_DATEMI" , 'C' ,8  , 0 })
aAdd( aStruTab, { "TMP_TIPOKM" , 'C' ,1  , 0 })
aAdd( aStruTab, { "TMP_ORDROT" , 'N' ,3  , 0 })
aAdd( aStruTab, { "TMP_DOCS"   , 'M' ,10 , 0 })
aAdd( aStruTab, { "TMP_DATDTW" , 'D' ,8  , 0 })	
aAdd( aStruTab, { "TMP_HORDTW" , 'C' ,4  , 0 })	


//------------------------------------------------------------------------------ 
//--  INICIO - Bloco De Criacao Dos Arquivos Temporarios No Banco De Dados 
//------------------------------------------------------------------------------	
oTempTable := FWTemporaryTable():New("TMPX")
oTempTable:SetFields( aStruTab )
oTempTable:AddIndex("01", {"TMP_RATEIO","TMP_DOCGER"} )
oTempTable:Create()

//------------------------------------------------------------------------------ 
//--   FIM   - Bloco De Criacao Dos Arquivos Temporarios No Banco De Dados 
//------------------------------------------------------------------------------	

//-- Inicializa Controle De Sequence
Begin Sequence

	//-- Verifica Se Criou Tabela
	If Select("TMPX") <= 0
		Break
	EndIf

	
	//-- Verifica Tamanho Do Vetor
	If Len( aDados ) == 0
		Break
	EndIf

	For n1 := 1 To Len(aDados)
	
			
		//-- Trava Para Gravação
		RecLock( "TMPX" , .t. )
		
				
		aCampos := aDados[ n1 ]
		For n2 := 1 To Len( aCampos )
		
			nPos := aScan( aStruTab , { |x| Alltrim(x[1]) == (aCampos[n2][1])}) 
			If nPos > 0
				//-- Efetua Macro Substituição
				If aStruTab[nPos,2] == "C" 
					&( "TMPX" + "->" + aCampos[n2][1]) := aCampos[n2][2]
				ElseIf aStruTab[nPos,2]== "D" 
					&( "TMPX" + "->" + aCampos[n2][1]) := StoD(aCampos[n2][2])
				ElseIf aStruTab[nPos,2] == "N" 
					&( "TMPX" + "->" + aCampos[n2][1]) := Val(aCampos[n2][2])
				ElseIf aStruTab[nPos,2] == "M"
					&( "TMPX" + "->" + aCampos[n2][1]) := aCampos[n2][2]
				EndIf

			EndIf

		Next n2
		
		//-- Destrava Registro
		TMPX->(MsUnlock())
		
	Next n1
	

//-- Finaliza Controle De Sequence
End Sequence

// Fecha Arquivo Temporario
If Select( "TMPX" ) > 0
	TMPX->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return( oTempTable )

/*--------------------------------------------------------------------------------------------------------
{Protheus.doc} TMSF10MntR
			Monta array do roteiro da viagem de acordo com as informações dos agendamentos marcados
@author  	Leandro Paulino
@version 	Versao P12
@since		28/Abr/2016
@return 	Nil
@obs .
//------------------------------------------------------------------------------------------------------*/

Function TMSF10MntR(aRetNew,aRetOri, cSerTms, nFolder, aRetBkp,cFilVge,cViagem )

Local aRetAll		:= {}
Local aRetAllOri	:= {}
Local aRetBkpOri	:= {}
Local aCampos		:= {}
Local nCntPag 	:= 0
Local nTamRetPag	:= 0
Local nTamAllPag	:= 0
Local nTamRet		:= 0
Local nCntAll		:= 0
Local cContrat	:= ''
Local aAreaSM0 	:= SM0->(GetArea())
Local aAreaDUE 	:= DUE->(GetArea())
Local aAreaDT6	:= DT6->(GetArea())
Local aAreaDTC	:= DTC->(GetArea())
Local aAreaDDC	:= DDC->(GetArea())
Local aAreaDDA	:= DDA->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local cCodCli 	:= ''
Local cLojCli 	:= ''
Local cCliDev		:= ''
Local cLojDev 	:= ''
Local cCliDevFil	:= '' //--Variavel que sera utilizada para informar o codigo do devedor do frete na linha da filial
Local cLojDevFil	:= '' //--Variavel que sera utilizada para informar a loja do devedor do frete na linha da filial
Local cHoraPrv	:= ''
Local cDataPrv	:= ''
Local cOpeCTC		:= ''
Local cSeqEnd		:= ''
Local cRateio		:= '' //--Se o documento possui rateio ('1'=SIM;'2'Não)
Local cDocGer		:= '' //--Se o já foi gerado o Ct-e. ('1'=SIM;'2'Não)
Local cValTre		:= '' //--Se  possui codigo de negociação e serviço. ('1'=SIM;'2'Não)
Local cFilDoc		:= ''
Local cDoc			:= ''
Local cSerie		:= ''
Local cLotNfc		:= ''
Local aDoctos		:= {}
Local lIncTrecho	:= .T.
Local cTipOper	:= ''
Local cDataEmi	:= ''  
Local aRetDDO		:= {}
Local cCliDDO		:= ''
Local cLojDDO		:= ''
Local cTipoKM	 	:= ""
Local cCliGen       := SuperGetMV("MV_CLIGEN",.F., "") // Recebe o cliente generico
Local cLojGen       := ""
Local cChave		:= ""
Local cTabela 	:= ""
Local cLinDoc		:= ""
Local nIniFor		:= 0
Local nPasta		:= 0

Default aRetNew	:= {}
Default aRetOri	:= {}
Default cSerTms	:= '1'	
Default nFolder	:= 1
Default cFilVge	:= ""
Default cViagem 	:= ""

aRetAll	:= AClone(aRetNew)
aRetAllOri	:= AClone(aRetOri)

DUE->(dbSetOrder(1))
DT6->(dbSetOrder(2))

// Busca o Cliente Generico            
SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial('SA1') + cCliGen))
	cCliGen := SA1->A1_COD
	cLojGen := SA1->A1_LOJA
EndIf
If nFolder > 1
	If Len(aRetAllOri) > 0
		// Verifica a aba correspondente as novas linhas 
		
		If (nPasta := aScan(aRetAll,{ |x|  x[2] == aRetAllOri[1] .AND. x[3] == aRetAllOri[2]  } )) > 0
			nIniFor := 1 
			nTamAllPag := 1
			aRetAll := aRetAll[nPasta]	
		EndIf
		
		aRetBkpOri := aRetAllOri[5]
	Else
		nTamAllPag := 1
		nIniFor := 1	
		aRetAll := aRetAll[nFolder-1]
	EndIf
	
Else
	If Len(aRetAllOri) > 0
		nIniFor := 1 
		nTamAllPag := Len(aRetAll)
		aRetBkpOri := aRetAllOri[5]
	Else
		nTamAllPag := Len(aRetAll)
		nIniFor := 1
	EndIf
EndIf

If Len(aRetBkpOri) > 0
	
	// Varre os pontos do cliente devedor
	For nCntAll := 1 To Len(aRetBkpOri)
		
		// Busca a Linha dos docs 
		cLinDoc := ""
		cLinDoc := F10BusDocs(aRetBkpOri[nCntAll][1],aRetBkpOri[nCntAll][2],aRetBkpOri[nCntAll][5],aRetBkpOri[nCntAll][6],aRetBkpOri[nCntAll][10],aRetBkpOri[nCntAll][11],aRetBkpOri[nCntAll][12])
		
		//--Preenche array aCampos com os dados da DJF
		Aadd(aCampos,{DTos(aRetBkpOri[nCntAll][17]),;			// Data de Previção
						aRetBkpOri[nCntAll][18],;				// Hora de Previsão
						aRetBkpOri[nCntAll][10],;				// Cliente
						aRetBkpOri[nCntAll][11],;				// Loja
						aRetBkpOri[nCntAll][12],;				// Sequencia de Endereço
						aRetBkpOri[nCntAll][5],;					// Cliente devedor
						aRetBkpOri[nCntAll][6],;					// Loja do Cliente devedor
						aRetBkpOri[nCntAll][13],;				// Se possui Rateio
						aRetBkpOri[nCntAll][14],;				// Se o documento já foi gerado
						aRetBkpOri[nCntAll][16],;				// Tipo da Operação
						aRetBkpOri[nCntAll][8],;					// Numero do Contrato
						aRetBkpOri[nCntAll][15],;				// Se valoriza o trecho
						"",;										// Data de Emissão
						"0",;										// Recno
						aRetBkpOri[nCntAll][5],;					// Cliente DDO
						aRetBkpOri[nCntAll][6],;					// Loja do Cliente DDO
						aRetBkpOri[nCntAll][19],;				// Tipo de KM
						aRetBkpOri[nCntAll][9],;  				// Sequencia   
						CValToChar(aRetBkpOri[nCntAll][7]),;  	// KM
						cLinDoc,;									// Documentos do ponto
						aRetBkpOri[nCntAll][20],;			   // Id unico da Linha
						aRetBkpOri[nCntAll][3],;              // Rota
						DTos(aRetBkpOri[nCntAll][21]),;             // Data de Passagem DTW
						aRetBkpOri[nCntAll][22]})             // Hora de Passagem DTW
						 
	Next nCntAll	
EndIf

//--Monta Array para inserir a data e hora para posteriormente ordenar o array de acordo com essas informações
If nTamAllpag > 0

	For nCntAll := nIniFor To nTamAllpag
		
		If nFolder == 1
			aRetBkp := aClone(aRetAll[nCntAll,4])
			cTipoKM := "1" 
		Else
			cContrat 	:= aRetAll[1]
			cCliDevFil := cCliDev := aRetAll[2]
			cLojDevFil := cLojDev := aRetAll[3]
			aRetBkp := aClone(aRetAll[4])
			cTipoKM := aRetAll[5]
		EndIf	
		//--preenchimento das variaveis que farão o controle de qual quilometragem será considerado para cada Folder (Cliente Genérico ou Cliente Devedor)
		If Len (aRetDDO:= Taf12TipKM (cTipoKM , cCliDev, cLojDev)) > 0
			cCliDDO := aRetDDO[2]
			cLojDDO := aRetDDO[3]
		EndIf
		
		nTamRetpag := Len(aRetBkp)
		 
		For nCntPag := 1 To nTamRetpag 
		
			cRateio	:= aRetBkp[nCntPag,3]
			cDocGer	:= aRetBkp[nCntPag,4]
			cValTre	:= aRetBkp[nCntPag,5]
			cRecno 	:= Str(aRetBkp[nCntPag,2])
			
			cTabela := aRetBKP[nCntPag,1]
			
			DbSelectArea(cTabela)
			DbGoTo(aRetBkp[nCntPag,2])//--Posiciona na tabela e registro enviado pelo Pagador de Frete	
			//--Busca Informacoes da Coleta
			
			cChave := &(cTabela+"->(" + (cTabela)->(IndexKey(1)) + ")")
			
			cLinDoc := cTabela + "|1|"+ cChave + "#"
			
			If aRetBkp[nCntPag,1] == 'DT5' .And. cSerTms == '1'
				cTipOper := '2'
				//--Inclui as informações do Remente ou Solicitante no Inicio do Trecho	
				If DT5_LOCCOL == '2' //--Remetente
					cDataPrv:= DTos(DT5_DATPRV)
					cHoraPrv := DT5_HORPRV
					cCodCli := DT5_CLIREM
					cLojCli := DT5_LOJREM	
					cSeqEnd := DT5_SQEREM
				ElseIf DUE->(MsSeek(FwxFilial('DUE')+DT5->DT5_CODSOL)) //--Se nao for o remetente verifica o codigo do solicitante
					cDataPrv:= DTos(DT5_DATPRV)
					cHoraPrv := DT5_HORPRV
					cCodCli := DUE->DUE_CODCLI
					cLojCli := DUE->DUE_LOJCLI
					cSeqEnd := DT5_SEQEND			
				EndIf			
				cDataEmi 	:= DTos(DT5_DATSOL)   
				//--Verifica se o serviço do documento da coleta, está cadastrado como Tipo de Operação de Coleta e Entrega no Contrato
				//--Se estiver preenche inclui no roteiro os dados do destinatário
				cOpeCTC := Posicione('DDA',2,FwxFilial('DDA')+DT5_NCONTR+DT5_CODNEG+DT5_SERVIC,"DDA_TIPOPE")
				
				If Empty(cOpeCTC) .Or. cOpeCTC == '0'
					 cOpeCTC:=  Posicione('DDC',2,FwxFilial('DDC')+DT5_NCONTR+DT5_CODNEG+DT5_SERVIC,"DDC_TIPOPE")
				EndIf
					
				If cOpeCTC == '1' .Or. (cOpeCTC == '2' .Or. (Empty(cOpeCTC) .And. !Empty(DT5->(DT5_CLIDES + DT5_LOJDES))) )
					
								 
					//--Valida se o remetente/solicitante já está incluído no roteiro
					//--O desenvolvimento foi realizado para não permitir que o mesmo cliente faça parte de vários trechos do roteiro
					//--Considerando que o transportador passará apenas uma vez no cliente.
					//--Se o cliente já foi inserido no roteiro, a data e hora prevista será a menor data/hora dos documentos do cliente.
				
					If (nPos := aScan(aCampos , { |x| (x[3]) +  (x[4]) + (x[5]) == cCodCli + cLojCli + cSeqEnd})) == 0
					
						//--Preenche array aCampos com os dados do remetente ou solicitante da coleta
						Aadd(aCampos,{cDataPrv,cHoraPrv,cCodCli,cLojCli,cSeqEnd,cCliDev,cLojDev,cRateio,cDocGer,cTipOper,cContrat,cValTre,cDataEmi,cRecno,cCliDDO,cLojDDO,cTipoKM,"ZZ","0",cLinDoc,"","","",""})
					
					Else
					
						//--Altera conteudo de alguns campos na unificação dos trechos
						aCampos[nPos] := Tmsaf10Uni(aCampos[nPos],cDataPrv,cHoraPrv,cRateio,cDocGer,cValTre,cTipOper,cDataEmi,cRecno,cLinDoc) //--Unificação dos trechos
					
					EndIf 				
					
					//--Prepara as variaveis para preencher o array aCampos com informações do destinatário já que se trata de coleta com entrega direta
					cDataPrv	:= Dtos(DT5_DATENT)
					cHoraPrv	:= DT5_HORENT
					cCodCli 	:= DT5_CLIDES
					cLojCli 	:= DT5_LOJDES	
					cSeqEnd 	:= DT5_SQEDES
					cTipOper	:= '3'

					If cOpeCTC == '1'
						lIncTrecho := .F.
					EndIf
					
				EndIf	
			ElseIf aRetBkp[nCntPag,1] == 'DTC' .And. cSerTms == '3' //--Busca as informacoes do documento do cliente nas viagens de entrega
				
				//--VERIFICA SE O DTC já virou DT6, de acordo com o retorno da rotina de pagadores de frete.
				If aRetBkp[nCntPag,4] == '1'
					
					//Se existe DT6 verifica se este DT6, já será incluído no roteiro
					If DT6->(MsSeek(FwxFilial('DT6')+DTC->(DTC_FILORI+DTC_LOTNFC+DTC_FILDOC+DTC_DOC+DTC_SERIE)))				
					
						//--Verifica se este DT6 já estará no roteiro, se já existir desconsidera este registro
						If aScan( aDoctos , { |x| (x[1]) +  (x[2]) + (x[3]) + (x[4]) == DT6->(DT6_LOTNFC+DT6_FILDOC+DT6_DOC+DT6_SERIE)}) > 0
							lIncTrecho := .F.
						Else
							lIncTrecho := .T.
						EndIf
					
					EndIf
				
				EndIf

				cOpeCTC := Posicione("DDA",2,FwxFilial("DDA") + DTC_NCONTR + DTC_CODNEG + DTC_SERVIC,"DDA_TIPOPE")
				
				If Empty(cOpeCTC) .Or. cOpeCTC == "0"
					 cOpeCTC:=  Posicione("DDC",2,FwxFilial("DDC") + DTC_NCONTR + DTC_CODNEG + DTC_SERVIC,"DDC_TIPOPE")
				EndIf

				If cOpeCTC == "3"
					cDataPrv := DTos(CToD(""))
					cHoraPrv := StrTran("0000",PesqPict("DT5","DT5_HORPRV"))
					cCodCli  := DTC->DTC_CLIREM
					cLojCli  := DTC->DTC_LOJREM	
					cSeqEnd  := Posicione("DT5",1,xFilial("DT5") + DTC->(DTC_FILCFS + DTC_NUMSOL),"DT5_SQEREM")
					cRateio	 := aRetBkp[nCntPag,3]
					cDocGer	 := aRetBkp[nCntPag,4]
					cTipOper := "2"
					cValTre	 := aRetBkp[nCntPag,5]
					cDataEmi := DToS(DTC->DTC_DATENT)
					cRecno 	 := Str(aRetBkp[nCntPag,2])
					If (nPos := aScan(aCampos , { |x| (x[3]) +  (x[4]) + (x[5]) == cCodCli + cLojCli + cSeqEnd})) == 0
						Aadd(aCampos,{cDataPrv,cHoraPrv,cCodCli,cLojCli,cSeqEnd,cCliDev,cLojDev,cRateio,cDocGer,cTipOper,cContrat,cValTre,cDataEmi,cRecno,cCliDDO,cLojDDO,cTipoKM,"ZZ","0",cLinDoc,"","","",""})
					EndIf 				
				EndIf

				cDataPrv	:= DTos(DTC->DTC_PRVENT)
				cHoraPrv 	:= DTC->DTC_PRHENT
				cCodCli 	:= DTC->DTC_CLIDES
				cLojCli 	:= DTC->DTC_LOJDES
				cSeqEnd 	:= DTC->DTC_SQEDES
				cLotNfc	:= DT6->DT6_LOTNFC
				cFilDoc	:= DT6->DT6_FILDOC
				cDoc		:= DT6->DT6_DOC
				cSerie		:= DT6->DT6_SERIE
				cDataEmi	:= DToS(DTC->DTC_DATENT)		
				cTipOper 	:= "3"
				
			ElseIf	aRetBkp[nCntPag,1] == 'DT5' .And. cSerTms == '3' //--	//--Busca as informações da coleta na viagem de entrega se houver serviço adicional
			
				//--Se a coleta estiver "Em Aberto" ou "Indicado para Coleta", busca as informações do remetente, respeitando o campo LOCCOL
				//--Alem de preencher as informações as informações do destinatárop
				If DT5_STATUS $ '1|2'		
					
					cOpeCTC := Posicione('DDA',2,FwxFilial('DDA')+DT5_NCONTR+DT5_CODNEG+DT5_SERVIC,"DDA_TIPOPE")
					
					If Empty(cOpeCTC) .Or. cOpeCTC == '0'
						 cOpeCTC:=  Posicione('DDC',2,FwxFilial('DDC')+DT5_NCONTR+DT5_CODNEG+DT5_SERVIC,"DDC_TIPOPE")
					EndIf
						
					If DT5->DT5_LOCCOL == '2' //--Remetente
						cCodCli := DT5_CLIREM
						cLojCli := DT5_LOJREM	
						cSeqEnd := DT5_SQEREM
					//--Se nao for o remetente verifica o codigo do solicitante	
					ElseIf DUE->(MsSeek(FwxFilial('DUE')+DT5->DT5_CODSOL))
						cCodCli 	:= DUE->DUE_CODCLI
						cLojCli 	:= DUE->DUE_LOJCLI
						cSeqEnd 	:= DT5_SEQEND
					EndIf		
					cDataPrv:= Dtos(DT5_DATPRV)
					cHoraPrv:= DT5_HORPRV
					cTipOper  := "2"		
					cDataEmi	:= Dtos(DT5_DATSOL)	
						
					//--Valida se o remetente/solicitante já está incluído no roteiro
					//--O desenvolvimento foi realizado para não permitir que o mesmo cliente faça parte de vários trechos do roteiro
					//--Considerando que o transportador passará apenas uma vez no cliente.
					//--Se o cliente já foi inserido no roteiro, a data e hora prevista será a menor data/hora dos documentos do cliente.
					
					If (nPos := aScan(aCampos , { |x| (x[3]) +  (x[4]) + (x[5]) == cCodCli + cLojCli + cSeqEnd})) == 0				
						//--Preenche array aCampos com os dados do remetente ou solicitante da coleta
						Aadd(aCampos,{cDataPrv,cHoraPrv,cCodCli,cLojCli,cSeqEnd,cCliDev,cLojDev,cRateio,cDocGer,cTipOper,cContrat,cValTre,cDataEmi,cRecno,cCliDDO,cLojDDO,cTipoKM,"ZZ","0",cLinDoc,"","","",""})
						
					Else				
						//--Altera conteudo de alguns campos na unificação dos trechos
						aCampos[nPos] := Tmsaf10Uni(aCampos[nPos],cDataPrv,cHoraPrv,cRateio,cDocGer,cValTre,cTipOper,cDataEmi,cRecno,cLinDoc) //--Unificação dos trechos
						
					EndIf 				
							
					//--Prepara as informações do destinatário para a ser apresentado no roteiro
					//--Como se trata de serviço adicional e a coleta não foi realizada, serão exibidos o remetente e destinatário do roteiro					
					cCodCli 	:= DT5_CLIDES
					cLojCli 	:= DT5_LOJDES	
					cSeqEnd 	:= DT5_SQEDES
					cTipOper  := "3"
						
					If cOpeCTC == '1'
						lIncTrecho := .F.
					EndIf
					
				ElseIf DT5_STATUS == '4'
					
					//--Se a coleta estiver "Encerrada", busca as informações do destinatário, já que a mesma será considerada como entrega.
					cDataPrv	:= Dtos(DT5_DATENT)
					cHoraPrv	:= DT5_HORENT
					cCodCli 	:= DT5_CLIDES
					cLojCli 	:= DT5_LOJDES	
					cSeqEnd 	:= DT5_SQEDES
					cDataEmi	:= Dtos(DT5_DATSOL)
					cTipOper  := "3"	
				
				EndIf	
						
	
			EndIf
	
			//--Valida se o cliente já está incluído no roteiro
			//--O desenvolvimento foi realizado para não permitir que o mesmo cliente faça parte de vários trechos do roteiro
			//--Considerando que o transportador passará apenas uma vez no cliente.
			//--Se o cliente já foi inserido no roteiro, a data e hora prevista será a menor data/hora dos documentos do cliente.
			If lIncTrecho 
							
				If (nPos := aScan( aCampos , { |x| (x[3]) +  (x[4]) + (x[5]) == cCodCli + cLojCli + cSeqEnd} )) == 0					
			
					//--Preenche array aCampos com os dados do remetente ou solicitante da coleta
					Aadd(aCampos,{cDataPrv,cHoraPrv,cCodCli,cLojCli,cSeqEnd,cCliDev,cLojDev,cRateio,cDocGer,cTipOper,cContrat,cValTre,cDataEmi,cRecno,cCliDDO,cLojDDO,cTipoKM,"ZZ","0",cLinDoc,"","","",""})
				
				Else
					
					//--Altera conteudo de alguns campos na unificação dos trechos
					aCampos[nPos] := Tmsaf10Uni(aCampos[nPos],cDataPrv,cHoraPrv,cRateio,cDocGer,cValTre,cTipOper,cDataEmi,cRecno,cLinDoc) //--Unificação dos trechos
					
				EndIf
				//--Se o DTC, já gerou DT6 efetua o controle no array aDoctos 	
				If aRetBkp[nCntPag,4] == '1'
					Aadd(aDoctos,{cLotnfc,cFilDoc,cDoc,cSerie})						
				EndIf
				
			EndIf	
	
		Next nCntPag
		
	Next nCntAll
EndIf	
nTamRet := Len(aCampos)
//--Efetua a ordenacao de acordo com a data e hora prevista, data emissao do documento e recno  
ASort(aCampos,,,{|x,y| x[18]+x[1]+x[2]+x[13]+x[14]+x[10] < y[18]+y[1]+y[2]+y[13]+y[14]+y[10]})

//-- Coloca filial de origem no trajeto
If !Empty(cFilAnt)	
	SM0->(DbSetOrder(1))
	If SM0->(DbSeek(cEmpAnt + cFilAnt))
		SA1->(DbSetOrder(3))
		lFilial := Len(aRetBkpOri) <= 0 .AND. SA1->(DbSeek(xFilial("SA1") + SM0->M0_CGC)) // Somente se for uma aba nova e se possuir a filial como cliente
	EndIf
EndIf

If lFilial
	cRateio := '3'
	cDocGer := '3'
	cValTre := '3'
	cTipOper := '6'
	//cContrat	:= Space(TamSx3('DT5_NCONTR')[1])

	//-- Inseri uma linha na posicao 1 do vetor
	Aadd(aCampos,{})
	Ains(aCampos,1)
	
	//-- Inclui a filial na origem do trecho
	aCampos[1] := {"  /  /    ",Space(TamSx3('DTW_HORPRE')[1]),SA1->A1_COD,SA1->A1_LOJA,"",cCliDevFil,cLojDevFil,cRateio,cDocGer,cTipOper,cContrat,;
				   cValTre,"","0","","",cTipoKM,"","0","","","","",""}
	
	//--Inclui a filial no destino do trecho
	Aadd(aCampos,{"  /  /    ",Space(TamSx3('DTW_HORPRE')[1]),SA1->A1_COD,SA1->A1_LOJA,"",cCliDevFil,cLojDevFil,cRateio,cDocGer,cTipOper,cContrat,;
				  cValTre,"","0",Iif(cTipoKM == "2",cCliDevFil,cCliGen),Iif(cTipoKM == "2",cLojDevFil,cLojGen),cTipoKM,"","0","","","","",""})

	nTamRet := Len(aCampos)	
		
EndIf

aRetBkp := aClone(aCampos)
aCampos := {}

For nCntPag := 1 To nTamRet
	AADD(aCampos,{})
	AADD(aCampos[nCntPag],{'TMP_DATPRV'	,aRetBkp[nCntpag,1]})
	AADD(aCampos[nCntPag],{'TMP_HORPRV'	,aRetBkp[nCntpag,2]})
	AADD(aCampos[nCntPag],{'TMP_CLIENT'	,aRetBkp[nCntpag,3]})
	AADD(aCampos[nCntPag],{'TMP_LOJA'		,aRetBkp[nCntpag,4]})
	AADD(aCampos[nCntPag],{'TMP_SEQEND'	,aRetBkp[nCntpag,5]})
	AADD(aCampos[nCntPag],{'TMP_CLIDEV'	,aRetBkp[nCntpag,6]})
	AADD(aCampos[nCntPag],{'TMP_LOJDEV'	,aRetBkp[nCntpag,7]})	
	AADD(aCampos[nCntPag],{'TMP_RATEIO'	,aRetBkp[nCntpag,8]})
	AADD(aCampos[nCntPag],{'TMP_DOCGER'	,aRetBkp[nCntpag,9]})	
	AADD(aCampos[nCntPag],{'TMP_TIPOPE'	,aRetBkp[nCntpag,10]})		
	AADD(aCampos[nCntPag],{'TMP_NCONTR'	,aRetBkp[nCntpag,11]})
	AADD(aCampos[nCntPag],{'TMP_VALTRE'	,aRetBkp[nCntpag,12]})	
	AADD(aCampos[nCntPag],{'TMP_DATEMI'	,aRetBkp[nCntpag,13]})
	AADD(aCampos[nCntPag],{'TMP_RECNO'		,aRetBkp[nCntpag,14]})
	AADD(aCampos[nCntPag],{'TMP_CLIDDO'	,aRetBkp[nCntpag,15]})
	AADD(aCampos[nCntPag],{'TMP_LOJDDO'	,aRetBkp[nCntpag,16]})
	If nCntpag == 1
		AADD(aCampos[nCntPag],{'TMP_CLIDE'	,aRetBkp[nCntpag,3]})
		AADD(aCampos[nCntPag],{'TMP_LOJDE'	,aRetBkp[nCntpag,4]})
		AADD(aCampos[nCntPag],{'TMP_SEQDE'	,aRetBkp[nCntpag,5]})	
	Else
		AADD(aCampos[nCntPag],{'TMP_CLIDE'	,aRetBkp[nCntpag-1,3]})
		AADD(aCampos[nCntPag],{'TMP_LOJDE'	,aRetBkp[nCntpag-1,4]})
		AADD(aCampos[nCntPag],{'TMP_SEQDE'	,aRetBkp[nCntpag-1,5]})	
	EndIf
	//------------------------------------------------------------------------------
	//----Verifica se a posicao do array e a primeira ou a ultima,------------------
	//----sendo o cliate será o mesmo que o clide, para que a KM Seja 0------------- 
	//------------------------------------------------------------------------------
	AADD(aCampos[nCntPag],{'TMP_CLIATE'	,aRetBkp[nCntpag,3]})
	AADD(aCampos[nCntPag],{'TMP_LOJATE'	,aRetBkp[nCntpag,4]})
	AADD(aCampos[nCntPag],{'TMP_SEQATE'	,aRetBkp[nCntpag,5]})	
	AADD(aCampos[nCntPag],{'TMP_TIPOKM'	,aRetBkp[nCntpag,17]})	
	AADD(aCampos[nCntPag],{'TMP_DOCS'		,aRetBkp[nCntpag,20]})	
	AADD(aCampos[nCntPag],{'TMP_KM'	     	,aRetBkp[nCntpag,19]})
	AADD(aCampos[nCntPag],{'TMP_ORDROT'	,cValToChar(nCntPag)})
	AADD(aCampos[nCntPag],{'TMP_IDLIN'	   ,aRetBkp[nCntpag,21]})
	AADD(aCampos[nCntPag],{'TMP_ROTA'	   ,aRetBkp[nCntpag,22]})
	AADD(aCampos[nCntPag],{'TMP_DATDTW'   ,aRetBkp[nCntpag,23] })
	AADD(aCampos[nCntPag],{'TMP_HORDTW'   ,aRetBkp[nCntpag,24] })

	// Dados da Viagem 
	AADD(aCampos[nCntPag],{'TMP_FILORI'	, cFilVge})
	AADD(aCampos[nCntPag],{'TMP_VIAGEM'	, cViagem })
	
Next nCntPag 

RestArea(aAreaSA1)
RestArea(aAreaSM0)
RestArea(aAreaDUE)
RestArea(aAreaDTC)
RestArea(aAreaDT6)
RestArea(aAreaDDC)
RestArea(aAreaDDA)

Return aCampos


/*--------------------------------------------------------------------------------------------------------
{Protheus.doc} TMF10RtVge
			Retorna os roteiros da viagem de acordo com os contratos ou clientes informados.
@author  	Leandro Paulino
@version 	Versao P12
@since		12/Mai/2016
@return 	Nil
@obs .
//------------------------------------------------------------------------------------------------------*/

Function TMF10RtVge(cFilOri,cViagem,cContrat,cCodCli, cLoja, nTipRot)
Local cQuery 		:= ''
Local cAliasQry	:= GetNextAlias()
Local nX			:= 0
Local nPosCdrDes	:= 7
Local nPosKM		:= 8
Local nTotalKM	:= 0
Local cCodRegiao	:= ''
Local aAreaDTQ	:= DTQ->(GetArea())
Local aAreaDJF	:= DJF->(GetArea())
Local aAreaDDJ	:= DDJ->(GetArea())
Local aRet			:= {}
Default cFilOri 	:= ' '
Default cViagem 	:= ' ' 
Default cContrat	:= ' '
Default cCodCli 	:= ' '
Default cLoja	  	:= ' '
Default nTipRot   := 1 //--Tipo de Roteiro que será retornado (1=Todos;2=Roteiro Geral;3=Roteiro dos Pagadores)

If !Empty(cFilOri) .And. !Empty(cViagem) .And. AliasIndic('DDJ') .And. AliasIndic('DJF')
	If nTipRot == 1
		cQuery := " SELECT 		DJF.DJF_ROTA, DJF.DJF_ROTEIR, DJF.DJF_NCONTR, DJF.DJF_NCONTR,  " 
		cQuery += " 			DJF.DJF_CLIDEV,	DJF.DJF_LOJDEV, DJF.DJF_KM,   "
		cQuery += " CASE WHEN DJF_SEQEND = '"+ Space(TamSx3('DJF_SEQEND')[1]) + "' THEN SA1.A1_CDRDES ELSE DUL.DUL_CDRDES END AS A1_CDRDES
		cQuery += " FROM " + RetSqlName("DJF") + " DJF "
		cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 " 
		cQuery += " ON    A1_COD    = DJF_CLIENT "
		cQuery += "   AND A1_FILIAL = '"+FwxFilial("SA1")+"'"
		cQuery += "   AND A1_LOJA   = DJF_LOJA   "
		cQuery += "   AND SA1.D_E_L_E_T_ = ' '   "

		cQuery  += "  LEFT JOIN " + RetSqlName("DUL")+ " DUL 	"
		cQuery  += "    ON  DUL_FILIAL ='"+ FwxFilial("DUL") +"'"
		cQuery  += "    AND DUL_CODCLI = DJF.DJF_CLIENT "
		cQuery  += "    AND DUL_LOJCLI = DJF.DJF_LOJA "
		cQuery  += "    AND DUL_SEQEND = DJF.DJF_SEQEND "
		cQuery  += "    AND DUL.D_E_L_E_T_ = ' '	"

		cQuery += " WHERE DJF_FILIAL = '" + FwxFilial("DJF") + "' "
		cQuery += "   AND DJF_FILORI = '" + cFilOri		+ "' "
		cQuery += "   AND DJF_VIAGEM = '" + cViagem		+ "' "
		If !Empty(cContrat) 
			cQuery += " 	AND 		DJF_NCONTR = '" + cContrat 		+ "' "		
		EndIf
		If !Empty(cCodCli) .And. !Empty(cLoja) 
			cQuery += "   AND 		DJF_CLIDEV = '" + cCliDev		+ "' "
			cQuery += "   AND 		DJF_LOJDEV = '" + cLojDev		+ "' "
		EndIf
		cQuery += " ORDER BY DJF.DJF_NCONTR, DJF_ROTA, DJF_ROTEIR "
	
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		While (cAliasQry)->(!Eof())
			cCodRegiao := (cAliasQry)->A1_CDRDES
			If Empty(aRet) 	
				nx++
				nTotalKM:= (cAliasQry)->DJF_KM
				AADD(aRet,{(cAliasQry)->DJF_ROTA,(cAliasQry)->DJF_ROTEIR,(cAliasQry)->DJF_NCONTR, (cAliasQry)->DJF_CLIDEV, (cAliasQry)->DJF_LOJDEV, cCodRegiao, cCodRegiao, (cAliasQry)->DJF_KM})		
			ElseIf aRet[nX,2] <> (cAliasQry)->DJF_ROTEIR .Or. aRet[nX,4] + aRet[nX,5] <> (cAliasQry)->DJF_CLIDEV + (cAliasQry)->DJF_LOJDEV  
				nTotalKM := 0
				nX++	
				AADD(aRet,{(cAliasQry)->DJF_ROTA,(cAliasQry)->DJF_ROTEIR,(cAliasQry)->DJF_NCONTR, (cAliasQry)->DJF_CLIDEV, (cAliasQry)->DJF_LOJDEV, cCodRegiao, cCodRegiao, (cAliasQry)->DJF_KM})
			Else
				aRet[nx,nPosKm] 		+= (cAliasQry)->DJF_KM  
				aRet[nx,nPosCdrDes] 	:= cCodRegiao
			EndIf	
				
			(cAliasQry)->(dbSkip())
		
		EndDo
	

	ElseIf nTipRot == 2
		If !Empty(Posicione('DTQ',2,FwxFilial('DTQ')+cFilOri+cViagem,'DTQ_ROTEIR'))
			cQuery := " SELECT DJH_ROTA, DDJ_ROTEIR, DDJ_SEQUEN, DDJ_CLIENT, DDJ_LOJA, DDJ_SEQEND " 
			cQuery += " FROM " + RetSqlName("DJH") + " DJH " 
			cQuery += " INNER JOIN " + RetSqlName("DDJ") + " DDJ " 
			cQuery += "   ON DDJ_FILIAL = '"+ FwxFilial("DDJ") +"'"			
			cQuery += "      AND DDJ_ROTEIR = DJH_ROTEIR "		
			cQuery += "      AND DDJ.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE DJH_FILIAL = '" + FwxFilial("DJH") + "' "
			cQuery += "   AND DJH_ROTA 	 = '" + DTQ->DTQ_ROTA + "' "
			cQuery += "   AND DJH_ROTEIR = '" + DTQ->DTQ_ROTEIR + "' "
			cQuery += "   AND DJH.D_E_L_E_T_ = ' ' 
			cQuery += " ORDER BY DDJ_SEQUEN " 	
			
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			
			While (cAliasQry)->(!Eof())
				AADD(aRet,{(cAliasQry)->DDJ_CLIENT, (cAliasQry)->DDJ_LOJA, (cAliasQry)->DDJ_SEQEND })				
				(cAliasQry)->(dbSkip())				
			EndDo		
		EndIf
	EndIf


	
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDDJ)
RestArea(aAreaDJF)

Return aRet 

/*/-----------------------------------------------------------
{Protheus.doc} TF10GrRote
Grava os Roteiros da Viagem

Uso: TMSA141

@sample
//TF10GrRote(cFilOri,cViagem,cRota,aRoteiros)

@author Paulo Henrique Corrêa Cardoso.
@since 11/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function TF10GrRote(nOpc, cFilOri,cViagem,aRoteiros,lDelDJJ,lDelDJK)

Local lRet			:= .T.	// Recebe o Retorno 
Local nCntRoteir 	:= 0	// Recebe o contador dos Roteiros
Local nPosRota	:= 1	// Recebe a Posição do Roteiro
Local nPosRotei	:= 2	// Recebe a Posição do Roteiro
Local nPosCliDev 	:= 3	// Recebe a Posição do Cliente devedor
Local nPosLojDev 	:= 4	// Recebe a Posição da Loja do cliente devedor
Local nPosContr	:= 5	// Recebe o Numero do Contrato
Local nPosSequen	:= 6	// Recebe o Numero da Sequencia
Local nPosKm 		:= 7 	// Recebe a Posição do KM
Local nPosClient	:= 8
Local nPosLoja	:= 9
Local nTamRot		:= 0
Local aAreaDJF		:= DJF->(GetArea())
Local cRota		:= ""
Local cRoteiro	:= "" 
Local cSequen		:= ""

Default cFilOri	:= ""
Default cViagem	:= ""
Default aRoteiros	:= {}
Default nOpc		:= 3
Default lDelDJJ	:= .T.
Default lDelDJK	:= .T.

nTamRot := Len(aRoteiros)

dbSelectArea("DJF")
dbSelectArea("DJJ")

DJF->(dbSetOrder(1))
DDJ->(dbSetOrder(1))

If nOpc == 3
	If Len(aRoteiros) > 0
	
		For nCntRoteir:= 1 To nTamRot
			
			If !Empty(aRoteiros[nCntRoteir][nPosCliDev]) .And. !Empty(aRoteiros[nCntRoteir][nPosLojDev])
				cRota		:= aRoteiros[nCntRoteir][nPosRota] 	
				cRoteiro 	:= aRoteiros[nCntRoteir][nPosRotei]
				cCliDev 	:= aRoteiros[nCntRoteir][nPosCliDev]
				cLojDev	:= aRoteiros[nCntRoteir][nPosLojDev]
				cSequen	:= aRoteiros[nCntRoteir][nPosSequen]
				
				If !DJF->(dbSeek(FwxFilial("DJF") + cFilOri + cViagem + cRota + cRoteiro + cCliDev + cLojDev + cSequen ) )
	
					RecLock('DJF',.T.)
				
					DJF->DJF_FILIAL := FwxFilial("DJF")
					DJF->DJF_FILORI := cFilOri
					DJF->DJF_VIAGEM := cViagem	
					DJF->DJF_ROTA   := cRota
					DJF->DJF_ROTEIR := cRoteiro
					DJF->DJF_CLIDEV := cCliDev
					DJF->DJF_LOJDEV := cLojDev
					DJF->DJF_CLIENT := aRoteiros[nCntRoteir][nPosClient]
					DJF->DJF_LOJA   := aRoteiros[nCntRoteir][nPosLoja]
					DJF->DJF_NCONTR := aRoteiros[nCntRoteir][nPosContr ]
					DJF->DJF_SEQUEN := cSequen
					DJF->DJF_KM     := aRoteiros[nCntRoteir][nPosKM	  ]										//Buscar a KM do Trecho					
				
					MsUnLock()
					
				EndIf
				
			EndIf		
		Next nCntRoteir
	Else
		lRet := .F.
	EndIf
ElseIf nOpc == 5
	// Apaga trechos do roteiro da viagem
	DJF->(dbSetOrder(1))
	If DJF->(MsSeek(FwxFilial('DJF')+cFilOri+cViagem))
		While DJF->(!Eof()) .And. DJF->(DJF_FILIAL+DJF_FILORI+DJF_VIAGEM) == FwxFilial('DJF')+cFilOri+cViagem
			RecLock('DJF',.F.,.T.)
			DJF->(DbDelete())
			MsUnLock()
			DJF->(dbSkip())
		EndDo
	EndIf
	
	If lDelDJJ
		// Apaga vimvulo docs X trechos do roteiro da viagem
		DJJ->(dbSetOrder(1))
		If DJJ->(MsSeek(FwxFilial('DJJ')+cFilOri+cViagem))
			While DJJ->(!Eof()) .And. DJJ->(DJJ_FILIAL+DJJ_FILORI+DJJ_VIAGEM) == FwxFilial('DJJ')+cFilOri+cViagem
				RecLock('DJJ',.F.,.T.)
				DJJ->(DbDelete())
				MsUnLock()
				DJJ->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If lDelDJK
	// Apaga vinculo Estados de Passagem X trechos do roteiro da viagem
		DJK->(dbSetOrder(1))
		If DJK->(MsSeek(FwxFilial('DJK')+cFilOri+cViagem))
			While DJK->(!Eof()) .And. DJK->(DJK_FILIAL+DJK_FILORI+DJK_VIAGEM) == FwxFilial('DJK')+cFilOri+cViagem
				RecLock('DJK',.F.,.T.)
				DJK->(DbDelete())
				MsUnLock()
				DJK->(dbSkip())
			EndDo
		EndIf
	EndIf
	
EndIf


RestArea(aAreaDJF)


Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} Tmsaf10Uni

Altera o conteúdo das opções abaixo de acordo com a regra
(Rateio,Documento Gerado, Tipo de Operação, Trecho Valorizado )

Uso: TMSA141

@sample
//Tmsaf10Uni (aCampos,cDataPrv,cHoraPRv,cRateio,cDocGer,cValTre,cTipOper,cDataEmi,cRecno,cLinDoc)

@author Leandro Paulino.
@since 11/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function Tmsaf10Uni (aCampos,cDataPrv,cHoraPRv,cRateio,cDocGer,cValTre,cTipOper,cDataEmi,cRecno,cLinDoc)

Local cSim 	:= '1' //--SIM
Local cNao 	:= '2' //--NAO
Local cColEnt := '4' //--COLETA/ENTREGA

Default aCampos := {} 
Default cDataPrv:= ''
Default cHoraPrv:= ''
Default cRateio := ''
Default cDocGer := ''
Default cValTre := ''
Default cTipOper:= ''
Default cDataEmi:= ''
Default cRecno  := '' 	
Default cLinDoc := ''
	
If aCampos[1] + aCampos[2] > cDataPrv + cHoraPrv

	//Utiliza a menor data e hora dos documentos ou coletas do cliente.	
	aCampos[1] := cDataPrv
	aCampos[2] := cHoraPrv
	
EndIf

If aCampos[13]  > cDataEmi
	//Utiliza a menor data de emissao do documento (DT5 ou DTC)	
	aCampos[13] := cDataEmi	
EndIf

If aCampos[14]  > cRecno
	//Utiliza o menor recno do DT5 ou DTC para ordernar o roteiro	
	aCampos[14] := cRecno	
EndIf

//--Se na unificação dos trechos houver um registro com a opção igual a "SIM" essa opção será utilizada no preenchimento da coluna 
If aCampos[8] == cNao .And. cRateio == cSim
	aCampos[8] := cSim
EndIf

If aCampos[9] == cNao .And. cDocGer == cSim
	aCampos[9] := cSim
EndIf
		
If aCampos[12] == cNao .And. cValTre == cSim
	aCampos[12] := cSim
EndIf

//--Se na unificação dos trechos houver Operações de Coleta e Entrega, altera o Tipo de Operação para 4=Coleta/Entrega					
If aCampos[10] <> cTipOper
	aCampos[10] := cColEnt
EndIf

// Caso tenha linha de documento
If	!Empty(cLinDoc) 
	aCampos[20] := RTrim(aCampos[20]) + cLinDoc
EndIf

		
Return aCampos

/*/-----------------------------------------------------------
{Protheus.doc} F10BusDocs

Altera o conteúdo das opções abaixo de acordo com a regra
(Rateio,Documento Gerado, Tipo de Operação, Trecho Valorizado )

Uso: TMSA141

@sample
//F10BusDocs(cFilOri,cViagem,cCliDev,cLojDev,cCliente,cLoja,cSeqEnd)

@author Paulo Henrique Corrêa Cardoso.
@since 11/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function F10BusDocs(cFilOri,cViagem,cCliDev,cLojDev,cCliente,cLoja,cSeqEnd)
Local cRet       := ""               // Recebe o retorno
Local cQuery     := ""               // Recebe a query     
Local aAreaAtu   := GetArea()        // Recebe a area atual
Local cAliasQry  := GetNextAlias()   // Recebe o proximo alias disponivel

Default cFilOri  := ""               // Recebe a filial de origem da viagem
Default cViagem  := ""               // Recebe a viagem
Default cCliDev  := ""               // Recebe o cliente devedor
Default cLojDev  := ""               // Recebe a loja do cliente devedor
Default cCliente := ""               // Recebe o cliente
Default cLoja    := ""               // Recebe a loja
Default cSeqEnd  := ""               // Recebe a sequencia de endereço do cliente

cQuery := " SELECT DJJ_TABELA || '|' || DJJ_INDICE || '|' || RTRIM(DJJ_CHAVE)  || '#' AS LINHA   "

cQuery += " FROM " + RetSqlName("DJJ") + " DJJ                                           "

cQuery += " WHERE DJJ_FILIAL = '"+ FwxFilial("DJJ") +"'                                  "
cQuery += " 	 AND DJJ_FILORI = '"+ cFilOri +"'                                          "
cQuery += " 	 AND DJJ_VIAGEM = '"+ cViagem +"'                                          "
cQuery += " 	 AND DJJ_CLIDEV = '"+ cCliDev +"'                                          "
cQuery += " 	 AND DJJ_LOJDEV = '"+ cLojDev +"'                                          "
cQuery += " 	 AND DJJ_CLIENT = '"+ cCliente +"'                                         "
cQuery += " 	 AND DJJ_LOJA   = '"+ cLoja +"'                                            "
cQuery += " 	 AND DJJ_SEQEND = '"+ cSeqEnd +"'                                          " 
cQuery += " 	 AND D_E_L_E_T_ = ' '                                                      " 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	cRet := RTrim(cRet) + (cAliasQry)->LINHA			
	(cAliasQry)->(dbSkip())				
EndDo		

RestArea(aAreaAtu)

Return cRet

#INCLUDE "CNTA100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CNTIncDoc³   Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza o documento ou o banco de conhecimento do item    ³±±
±±³          ³ selecionado na tree                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTIncDoc(oExp01,aExp02,cExp03,lExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - Objeto dbTree                                      ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos            ³±±
±±³          ³ cExp03 - Codigo do contrato                                 ³±±
±±³          ³ lExp04 - Valida banco de conhecimento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CNTIncDoc(oTree,aDocs,cContra,lBcVld)
Local nPos   := 0
Local cCargo := oTree:GetCargo()
Local aArea  := GetArea()
Local nPosN  := 0
Local cCod   := ""
Local lValid :=.F.
Local lSign := .F.
Local cRsrc
Local lContinua := .F.
Local aDocToAdd	:= {}

If "A" $ cCargo //Verifica se o item selecionado representa um grupo
	nPos := val(SubStr(cCargo,2,len(cCargo)))	
	
	If FindFunction("CNTA171")
		lContinua := DocViaC171(cContra, aDocs[nPos,1], @cCod, 1)
	Else
		lContinua := CN170Manut("CNK",,3,,cContra,aDocs[nPos,1],@cCod)//Chama rotina de inclusao antiga(CNTA170)
	EndIf

	If lContinua		
		dbSelectArea("CNK")
		dbSetOrder(1)
		dbSeek(xFilial("CNK")+cCod) //Seleciona registro incluso

		npos := aScan(aDocs,{|x| x[1] == CNK->CNK_TPDOC})

		If nPos > 0 .And. CNK->CNK_CONTRA == cContra
			
			If Empty(aDocs[nPos,3]) //Verifica se o item se encontra vazio
				nPosN := nPos
				cCargo := "V"+AllTrim(str(nPos))
			EndIf
			
			
			If lBcVld //Verifica se valida banco de conhecimento
				lValid := .F.//Nao valida documento, quando houver controle do banco de conhecimento.
			Else
				lValid := (CNK->CNK_DTEMIS <= dDataBase .And. CNK->CNK_DTVALI >= dDataBase)//Valida datas do documento
			EndIf

            lSign := aDocs[nPos, 13] //Permite assinatura eletrônica

			//Incrementa contadores dos documentos
			aEval(aDocs,{|x| If(x[1] == aDocs[nPos,1],(If(lValid,x[8]++,),x[9]++),)})

			//Seleciona resource de acordo com a validacao
			cRsrc := Iif(lValid .And. !lSign, "LBTIK", "LBNO")

			aDocToAdd 		:= Array(14)//Garante o tamanho fixo.
			aDocToAdd[1] 	:= aDocs[nPos,1]
			aDocToAdd[2] 	:= aDocs[nPos,2]
			aDocToAdd[3] 	:= CNK->CNK_CODIGO
			aDocToAdd[4] 	:= CNK->CNK_DESCRI
			aDocToAdd[5] 	:= CNK->CNK_DTEMIS
			aDocToAdd[6] 	:= CNK->CNK_DTVALI
			aDocToAdd[7] 	:= CNK->CNK_OBS
			aDocToAdd[8] 	:= aDocs[nPos,8]
			aDocToAdd[9] 	:= aDocs[nPos,9]
			aDocToAdd[10] 	:= aDocs[nPos,10]				
			aDocToAdd[11] 	:= aDocs[nPos,11]
			aDocToAdd[12] 	:= STR0202 //Não possui assinatura
			aDocToAdd[13] 	:= .F.
			aDocToAdd[14] 	:= ""

            If CN5->(FieldPos("CN5_ASSINA")) > 0 .And. CNK->(FieldPos("CNK_SIGNID")) > 0 
				SetStsSign(aDocToAdd, lSign, CNK->CNK_SIGNID)//Tratamento para carregar informações necessárias para o TOTVS Sign
            EndIf

			aAdd(aDocs, aClone(aDocToAdd))//Adiciona documento no array

            oTree:BeginUpdate()
			
			If oTree:TreeSeek("V"+AllTrim(str(nPos))) //Verifica se o grupo ja possui docs
				oTree:DelItem()
			EndIf
			oTree:TreeSeek("A"+AllTrim(str(nPos)))

			If lValid .And. !lSign //Altera resource da arvore qd o doc estiver valido e não for TOTVS Sign
				oTree:ChangeBmp("LBTIK","LBTIK")
			EndIf

			//Adiciona item na dbtree
			oTree:AddItem(CNK->CNK_CODIGO+"-"+CNK->CNK_DESCRI,AllTrim(Str(Len(aDocs))),cRsrc,cRsrc,,,2)
			oTree:EndUpdate()
			oTree:Refresh()
		EndIf
	EndIf
Else
	Aviso("CNTA100",OemtoAnsi(STR0081),{"OK"})
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CNTVisDoc³   Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza o documento ou o banco de conhecimento do item    ³±±
±±³          ³ selecionado na tree                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTVisDoc(oExp01,aExp02,lExp03)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - Objeto dbTree                                      ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CNTVisDoc(oTree,aDocs,lVisBC)
	Local nPos := 0
	Local cCargo := oTree:GetCargo()
	Local aArea := GetArea()
	Local cDoc := ""
	Local nI := 0
	Local lTotvsSign := SuperGetMv( "MV_CNTSIGN", .F., "0") == "1"//Verifica se permite TOTVS Sign
    Local lSign := .F.
	
	If "A" $ cCargo .OR. "V" $ cCargo
		nPos := val(SubStr(cCargo,2,len(cCargo)))
	Else
		nPos := val(cCargo)
	EndIf
	
	//Verifica se existe documento para o grupo
	If nPos > 0 .And. !Empty(aDocs[nPos,3])
		dbSelectArea("CNK")
		dbSetOrder(1)
		If dbSeek(xFilial("CNK")+aDocs[npos,3])
			
			//Chama banco de conhecimento ou visualizacao do doc		
			If !lVisBC
                If FindFunction("CNTA171")
		            DocViaC171(,,,2)
                Else
				    CN170Manut("CNK",CNK->(RECNO()),2)
                EndIf
			Else
				If(CN170Conh())
					oTree:BeginUpdate()
					
					lSign := lTotvsSign .And. aDocs[nPos,13]
					
                    If !lSign //-- Não permite marcar o documento caso possua integração com TOTVS Sign
                        oTree:ChangeBmp("LBTIK","LBTIK")
                    EndIf

					aDocs[nPos,10] += 1
					cDoc := aDocs[nPos,1]
					for nI:= 1 to Len(aDocs)
						if(nI != nPos .And. aDocs[nI,1] == cDoc)
							aDocs[nI,10]++
						endIf
					next nI
					
					oTree:EndUpdate()
					oTree:Refresh()
				EndIf
                
                CNTAlDoc(oTree,aDocs,Array(1))
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
    FwFreeArray(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    CNTDocSit  ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de validacao dos documentos, executada na alteracao ³±±
±±³          ³ de situacao do contrato                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTDocSit(nExp01,aExp02,lExp03)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Contrato selecionado                              ³±±
±±³          ³ aExp02 - Situacoes para qual o contrato sera alterado      ³±±
±±³          ³ lExp03 - Valida situacoes inferiores                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CNTDocSit(nReg,aSituac,lAll)
	Local aArea := GetArea()
	Local oDlDoc
	Local oTree                //Objeto dbtree
    Local oMenuSign
    Local oTMenuIte1
    Local oTMenuIte2
    Local oTMenuIte3
    Local oTButton1
	Local lFirst               //Identifica varredura dos tipos de documento
    Local lSign      := .F.
	Local lBsCnh     := (SuperGetMv( "MV_CNDOCBC", .F., "S") == "S")//Verifica se a validacao leva em consideracao o banco de conhec.
    Local lTotvsSign := (SuperGetMv( "MV_CNTSIGN", .F., "0") == "1")//Verifica se permite TOTVS Sign
	Local lBcoAc    := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRABCO,.F.)
	Local lLiber	:= .T.
	Local lContinua := .T.
	Local lCN100DCS := ExistBlock("CN100DCS")
    Local lCposSign := .F.
	Local nTotTree  		   //Total de docs para cada tipo de documento
	Local nTotDVld    		   //Total de docs validos para cada tipo de documento
	Local nx
	Local nTotBc:=0
    Local nTotSign := 0
	
	Local cDescLib  := ""      //Situacao de todos os documentos
	Local cDescTpc  := ""      //Tipo do Contrato
	Local cCadastro := STR0078 //"Check-List de Documentos"
	Local cCod        		   //Codigo do tipo de documento
	Local cRsrc       		   //Resource usado
	Local cDescSt := ""
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local cUmAlias:= ""
	Local cCargo
	Local cSituac := ""
	Local aCtrs   := Array(13) //Array com os controles de tela
	Local aSits   := RetSx3Box( Posicione("SX3", 2, "CN9_SITUAC", "X3CBox()" ),,, 1 )
	Local aIfDoc  := {}		   //Array com as informacoes de exibicao
	Local aDocs   	:= {}
	Local aDocToAdd := {}
	//³ Controles visuais
	//³ Fixa dimensao da dialog                     ³
	Local aSize     := {}
	Local aObjects  := {}
	Local aObjects2 := {}
	Local aPosObj1  := {}
	Local aPosObj2  := {}
	Local oPanel
	Local oGroup1
	Local lInc
	
	//³ Monta estrutura das situacoes para pesquisa ³
	If len(aSituac) > 1
		For nx:=1 to len(aSituac)
			cSituac+="'"+aSituac[nx]+"',"
			cDescSt+= AllTrim( aSits[Ascan( aSits, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(aSituac[nx])} )][3] )+", "
		Next
		cSituac := SubStr(cSituac,1,len(cSituac)-1)
	ElseIf Len(aSituac) ==  1 .And. AllTrim(aSituac[1]) <> "00"
		cDescSt:= AllTrim( aSits[Ascan( aSits, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(aSituac[1])} )][3] )
	EndIf
	
	
	/*Estrutura do aIfDoc                                 ³
	aIfDoc[1] - Codigo do tipo de documento               ³
	aIfDoc[2] - Descricao do tipo de documento            ³
	aIfDoc[3] - Codigo do Documento                       ³
	aIfDoc[4] - Descricao do Documento                    ³
	aIfDoc[5] - Data de emissao do documento              ³
	aIfDoc[6] - Data de validacao do documento            ³
	aIfDoc[7] - Obs do documento                          ³
	aIfDoc[8] - Total de documentos do tipo de documento  ³
	aIfDoc[9] - Total de documentos validos do tipo de doc³
	aIfDoc[10]- Total de registros no banco de conhecim.  ³
	aIfDoc[11]- Total documentos assinados                ³
	aIfDoc[12]- Situacao do documento                     ³
	aIfDoc[13]- Situacao da assinatura                   */

	aIfDoc := {"","","","",CTOD("  /  /  "),CTOD("  /  /  "),"",0,0,0,0,"",""}
	
	CN9->(dbGoTo(nReg))
	cDescTpc := Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_DESCRI")
	
	//Retorna documentos requisitados pela nova situacao ³
	//junto com os documentos ja cadastrados             ³
	cQuery := "SELECT CN5.CN5_CODIGO,CN5.CN5_DESCRI,CNK.CNK_CODIGO,CNK.CNK_DESCRI,CNK.CNK_DTEMIS,CNK.CNK_DTVALI,CNK.CNK_OBS,CNJ.CNJ_SITUAC" 
	
    lCposSign := CN5->(FieldPos("CN5_ASSINA")) > 0 .And. CNK->(FieldPos("CNK_SIGNID")) > 0 .And. CNK->(FieldPos("CNK_SIGNST"))

    If lCposSign //-- Adiciona campos do TOTVS Sign
        cQuery += ",CN5.CN5_ASSINA,CNK.CNK_SIGNID,CNK.CNK_SIGNST"
    EndIf
    
    cQuery += " FROM "+ RetSQLName("CNJ") +" CNJ"
	cQuery += " INNER JOIN "+ RetSQLName("CN5") +" CN5 ON(CNJ.CNJ_TPDOC = CN5.CN5_CODIGO AND CN5.CN5_FILIAL = '"+xFilial("CN5")+"' AND CN5.D_E_L_E_T_ = ' ')
	cQuery += " LEFT JOIN "	+ RetSQLName("CNK") +" CNK ON(CNK.CNK_TPDOC = CN5.CN5_CODIGO AND CNK.CNK_FILIAL = '"+xFilial("CNK")+"'" 
	cQuery += " AND CNK.D_E_L_E_T_ = ' ' AND CNK.CNK_CONTRA = '"+ CN9->CN9_NUMERO +"')"
	cQuery += " WHERE"
	cQuery += " CNJ.CNJ_FILIAL = '"+xFilial("CNJ")+"'"
	cQuery += " AND CNJ.D_E_L_E_T_ = ' '"
	cQuery += " AND CNJ.CNJ_TPCTO IN (' ','"+ CN9->CN9_TPCTO +"')"
	
	If Len(aSituac) > 1
		cQuery += " AND CNJ.CNJ_SITUAC IN ("+cSituac+")"
	Else
		cQuery += " AND CNJ.CNJ_SITUAC = '"+ aSituac[1] +"'"
		If aSituac[1] <> DEF_SCANC
			cQuery += " AND CNJ.CNJ_SITUAC <> '"+ DEF_SCANC +"'"
		EndIf
	EndIf 

	cQuery += " ORDER BY 1,5"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
	TCSetField(cAlias,"CNK_DTEMIS","D",08,0)
	TCSetField(cAlias,"CNK_DTVALI","D",08,0)
	TcSetField(cAlias,"CN5_ASSINA","L")

	lContinua := !((cAlias)->(Eof()))
	
	If lContinua		
		cUmAlias := GetNextAlias()	
		While !(cAlias)->(Eof())
			lInc := .T.
			nTotBc:=0

            If lCposSign
                lSign := lTotvsSign .And. (cAlias)->CN5_ASSINA
            EndIf

			If (lBsCnh .Or. lSign) .And. !Empty((cAlias)->CNK_CODIGO)
				cQuery := "SELECT COUNT(AC9.AC9_ENTIDA) AS BS_CONHE "
				cQuery += "  FROM "+ RetSQLName("AC9") +" AC9 "
				cQuery += "WHERE AC9.AC9_FILIAL = '"+xFilial("AC9")+"'"
				cQuery += "  AND AC9.AC9_ENTIDA = 'CNK'"
				cQuery += "  AND AC9.AC9_CODENT = '"+(cAlias)->CNK_CODIGO+"' "
				cQuery += "  AND AC9.D_E_L_E_T_ = ''"
	
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), (cUmAlias),.F.,.T.)
	
				nTotBc := (cUmAlias)->BS_CONHE
	
				(cUmAlias)->(dbCloseArea())
			EndIf
			
			/*Verifica documentos de situacoes anteriores que
			ja tenham sido validados e nao devem ser listados*/		
			If len(aSituac) == 1 .And. aSituac[1] > (cAlias)->CNJ_SITUAC
				If lAll
					lInc := !((cAlias)->CNK_DTEMIS <= dDataBase .AND. (cAlias)->CNK_DTVALI >= dDataBase)
					if lBsCnh .Or. lSign
						lInc := (nTotBc == 0)
					EndIf
				Else
					lInc := .F.
				EndIf
			EndIf
	
			If lInc
				/*Armazena documentos no array aDocs                   ³
					Estrutura do aDocs                                     ³
					aDocs[x,1] - Codigo do tipo de documento               ³
					aDocs[x,2] - Descricao do tipo de documento            ³
					aDocs[x,3] - Codigo do Documento                       ³
					aDocs[x,4] - Descricao do Documento                    ³
					aDocs[x,5] - Data de emissao do documento              ³
					aDocs[x,6] - Data de validacao do documento            ³
					aDocs[x,7] - Obs do documento                          ³
					aDocs[x,8] - Total de documentos validos do tipo de doc³
					aDocs[x,9] - Total de documentos do tipo de documento  ³
					aDocs[x,10]- Total de registros no banco de conhecim.  ³
					aDocs[x,11]- Total de Documentos assinados             ³
					aDocs[x,12]- Status assinatura                         ³
					aDocs[x,13]- Permite assinatura digital                ³
					aDocs[x,14]- Id da assinatura digital                 */
				aDocToAdd 		:= Array(14) //Garante o tamanho fixo.
				aDocToAdd[1] 	:= (cAlias)->CN5_CODIGO
				aDocToAdd[2] 	:= (cAlias)->CN5_DESCRI
				aDocToAdd[3] 	:= (cAlias)->CNK_CODIGO
				aDocToAdd[4] 	:= (cAlias)->CNK_DESCRI
				aDocToAdd[5] 	:= (cAlias)->CNK_DTEMIS
				aDocToAdd[6] 	:= (cAlias)->CNK_DTVALI
				aDocToAdd[7] 	:= (cAlias)->CNK_OBS
				aDocToAdd[8] 	:= 0
				aDocToAdd[9] 	:= 0
				aDocToAdd[10] 	:= nTotBc				
				aDocToAdd[11] 	:= 0
				aDocToAdd[12] 	:= STR0202 //Não possui assinatura
				aDocToAdd[13] 	:= .F.
				aDocToAdd[14] 	:= ""
                
                If lCposSign
                    SetStsSign(aDocToAdd, lSign, (cAlias)->CNK_SIGNID, (cAlias)->CNK_SIGNST)//-- Tratamento para carregar informações do TOTVS Sign no documento
                EndIf

				aAdd(aDocs, aClone(aDocToAdd))
            EndIf
			(cAlias)->(dbSkip())
		EndDo
	
		(cAlias)->(dbCloseArea())

		If(!IsBlind())		
			dbSelectArea("CN9")
			
			
			//³ Calcula posicao dos objetos na tela				
			aSize := MsAdvSize( .F. )
			aObjects := {}
			AAdd( aObjects, { 230, 030, .T., .F., .T. } )//Painel superior
			AAdd( aObjects, { 120, 144, .T., .T., .F. } )//dbTree
			AAdd( aObjects, { 120, 20, .T., .F., .F. } )//Botoes
		
			aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj1 := MsObjSize( aInfo, aObjects, .T., .F. )
		
			AAdd( aObjects2, { 120, 144, .T., .T., .F. } )//Group: Tipo de Documento
			AAdd( aObjects2, { 170, 144, .F., .T., .F. } )//Group: Informacoes do documento
		
			aInfo    := { aPosObj1[2,2],aPosObj1[2,1], aPosObj1[2,4], aPosObj1[2,3], 3, 3 }
			aPosObj2 := MsObjSize( aInfo, aObjects2, .F., .T. )
		
			DEFINE MSDIALOG oDlDoc TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] PIXEL
		
			@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlDoc
		
			//Situacao do contrato
			@ 001,000 Say RetTitle("CN9_SITUAC") Of oPanel PIXEL
			@ 000,024 MsGet oGetSit Var cDescSt When .F. PIXEL  Size 50,5 Of oPanel
		
			//Tipo do contrato
			@ 001,082 Say RetTitle("CN9_TPCTO") Of oPanel PIXEL
			@ 000,122 MsGet oGetTCto Var cDescTpc When .F. PIXEL  Size 100,5 Of oPanel
		
	
			//Situacao geral dos documentos
			@ 013,000 Say STR0063 Of oPanel PIXEL//"Situação Geral"
			@ 012,47 MsGet oGetSLib Var cDescLib When .F. PIXEL  Size 100,5 Of oPanel
		
			@ aPosObj1[2,1],aPosObj1[2,2] Say STR0064 Of oDlDoc PIXEL//"Documentos Requisitados"
		
			//-DBtree - Estrutura
			//--Nivel 1 - Tipos de Documentos
			//---Nivel 2 - Documentos cadastrados
			DEFINE DBTREE oTree ON CHANGE {CNTAlDoc(@oTree,aDocs,aIfDoc,lBsCnh),aEval(aCtrs,{|x| If (x!=Nil,x:Refresh(),)})} FROM aPosObj2[1,1]+006,aPosObj2[1,2] TO aPosObj2[1,3],aPosObj2[1,4] OF oDlDoc CARGO
		
			//Menu de visualizacao do documento
			MENU oMenuTree POPUP
				MENUITEM OemToAnsi(STR0003) Action CNTVisDoc(oTree,aDocs,.F.)//"Visualizar"
				MENUITEM OemToAnsi(STR0080) Action (CNTIncDoc(oTree,aDocs,CN9->CN9_NUMERO,lBsCnh),If(aScan(aDocs,{|x| x[8] == 0})==0,(lLiber:=.T.,cDescLib:=STR0066,oGetSLib:Refresh()),))//"Incluir Documento"
				If lBcoAc//Quando o usuario possui acesso ao banco de conhecimento
					MENUITEM OemToAnsi(STR0056) ACTION CNTVisDoc(oTree,aDocs,.T.)//"Banco de Conhecimento"
				EndIf
			ENDMENU
		
			oTree:bRClicked   := { |oObject,nx,ny| oMenuTree:Activate( nX-80, nY-200, oObject ) }
		
			lFirst := .T.
			
			//Arvore principal
			DBADDTREE oTree PROMPT cDescTpc OPEN OPENED CARGO "V0000"
		
			for nx:=1 to len(aDocs)		
                lSign := lTotvsSign .And. aDocs[nX,13]
                //Primeiro registro do tipo de documento			
				If lFirst				

					//³ Verifica se o tipo de documento possui algum       ³
					//³ documento valido                                   ³
					If aScan(aDocs,{|x| x[1] = aDocs[nX,1] .And. x[5] <= dDataBase .And. x[6] >= dDataBase .And. Iif(lBsCnh, x[10] > 0,.T.) .And. Iif(lSign, x[11] > 0, .T.)}) > 0
						cRsrc := "LBTIK"
					Else
						cRsrc := "LBNO"
					EndIf
					
					//³ Monta arvore do tipo de documento com a identificacao³
					//³ "A" no cargo                                         ³
					cCargo := "A"+alltrim(str(nX))
					DBADDTREE oTree PROMPT aDocs[nX,1]+"-"+aDocs[nX,2] RESOURCE cRsrc CARGO cCargo
					lFirst := .F.
					cCod :=  aDocs[nX,1]
					nTotTree:=0
					nTotDVld:=0
                    nTotSign := 0
				EndIf
		
				//³ Gera item do documento                             ³
				If !Empty(aDocs[nx,5])
                    lSign := lTotvsSign .And. aDocs[nX,13]

					If aDocs[nx,5] <= dDataBase .And. aDocs[nx,6] >= dDataBase .And. Iif(lBsCnh .Or. lSign, aDocs[nx,10] > 0, .T.)
						nTotDVlD++
						cRsrc := "LBTIK"
					Else
						cRsrc := "LBNO"
					EndIf

                    If lSign .And. aDocs[nX,11] > 0
                        nTotSign++
                    ElseIf lSign .And. aDocs[nX,11] == 0
                        cRsrc := "LBNO"
                    EndIf

					//³ Identifica cargo com a posicao do array aDocs      ³
					cCargo := alltrim(str(nX))
					DBADDITEM oTree PROMPT aDocs[nx,3]+"-"+aDocs[nx,4] RESOURCE cRsrc CARGO cCargo
					nTotTree++
				EndIf
				
				If nx == len(aDocs) .Or. aDocs[nX+1,1] != cCod //Verifica se e o ultimo elemento do grupo
					
					//³ Atualiza campos totalizadores do grupo             ³				
					aDocs := aEval(aDocs,{|x| If(x[1] == aDocs[nX,1],(x[8]:=nTotDVlD,x[9]:=nTotTree,x[11]:=nTotSign),)})
					
					//³ Gera item quando o grupo nao possuir documentos    ³				
					If nTotTree==0
						cCargo := "V"+alltrim(str(nX))
						DBADDITEM oTree PROMPT STR0065 CARGO cCargo//"Documento não fornecido"
					EndIf
					
					//³ Verifica se o tipo de documento foi liberado       ³
					If lLiber
						lLiber := (nTotTree > 0 .And. nTotDVlD>0 .And. Iif(lSign, nTotSign == nTotTree, .T.))
					EndIf
					nTotTree:=0
					DBENDTREE oTree
					lFirst := .T.
				EndIf
			Next
			
			//³ Gera elemento quando nao houver estrutura          ³
			If len(aDocs) == 0
				DBADDITEM oTree PROMPT STR0079 CARGO "V0000"//"Vazio"
			EndIf
		
			DBENDTREE oTree
		
			cDescLib := If(lLiber,STR0066,STR0067)//"Docs Liberados"##"Docs Pendentes"

			If lCposSign .And. lTotvsSign
				ProcessSign(aDocs, .F., 3, oTree) //Atualiza status das assinaturas
			EndIf

			//³ Componentes visuais de identificacao do documento  ³
			@ aPosObj2[2,1],aPosObj2[2,2] GROUP oGroup1 To aPosObj2[2,3],aPosObj2[2,4] Label OemToAnsi(STR0068) Of oDlDoc PIXEL//"Tipo do Documento"
		
			@ aPosObj2[2,1]+008,aPosObj2[2,2]+005 Say oCdTDoc Var RetTitle("CN5_CODIGO") Size 50,8 Of oGroup1 PIXEL
            
            oMenuSign := TMenu():New(0,0,0,0,.T.)
            oTMenuIte1 := TMenuItem():New(oGroup1,STR0207,,,,{||ProcessSign(aDocs, .T., 1, oTree)},,,,,,,,,.T.) //Integrar Assinaturas
            oTMenuIte2 := TMenuItem():New(oGroup1,STR0208,,,,{||ProcessSign(aDocs, .T., 2, oTree)},,,,,,,,,.T.) //Republicar Assinaturas
            oTMenuIte3 := TMenuItem():New(oGroup1,STR0209,,,,{||ProcessSign(aDocs, .T., 3, oTree)} ,,,,,,,,,.T.) //Atualizar Status
            oMenuSign:Add(oTMenuIte1)
            oMenuSign:Add(oTMenuIte2)
            oMenuSign:Add(oTMenuIte3)
            oTButton1 := TButton():New( aPosObj2[2,1]+008, aPosObj2[2,2]+123, STR0210 /*Assinatura*/ + CRLF + STR0211 /*Eletrônica*/,oGroup1,{||}, 42,16,,,.F.,.T.,.F.,,.F.,,,.F. )
            oTButton1:SetPopupMenu(oMenuSign)

			@ aPosObj2[2,1]+008,aPosObj2[2,2]+060 MsGet aCtrs[1] Var aIfDoc[1] Picture PesqPict("CN5","CN5_CODIGO") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+019,aPosObj2[2,2]+005 Say oNmTDoc Var RetTitle("CN5_DESCRI") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+019,aPosObj2[2,2]+060 MsGet aCtrs[2] Var aIfDoc[2] Picture PesqPict("CN5","CN5_DESCRI") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+032,aPosObj2[2,2]+005 Say aCtrs[9] Var OemToAnsi(STR0069)+AllTrim(str(aIfDoc[9])) Size 100,8 Of oGroup1 PIXEL//"Total de Documentos: "
			@ aPosObj2[2,1]+032,aPosObj2[2,2]+075 Say aCtrs[10] Var OemToAnsi(STR0070)+AllTrim(str(aIfDoc[8])) Size __DlgWidth(oDlDoc)-42,8 Of oGroup1 PIXEL//"Documentos Válidos: "
            @ aPosObj2[2,1]+043,aPosObj2[2,2]+005 Say aCtrs[12] Var OemToAnsi(STR0212/*Documentos Assinados: */)+AllTrim(str(aIfDoc[11]))+OemToAnsi(STR0074 /* registro(s)*/) Size __DlgWidth(oDlDoc)-42,8 Of oGroup1 PIXEL//"Documentos assinados: "##" registro(s)"

			@ aPosObj2[2,1]+058,aPosObj2[2,2]+005 Say OemToAnsi(STR0071) Size 100,8 Of oGroup1 PIXEL//"Detalhes do Documento"
			@ aPosObj2[2,1]+068,aPosObj2[2,2]+005 Say oCdDoc Var RetTitle("CNK_CODIGO") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+068,aPosObj2[2,2]+060 MsGet aCtrs[4] Var aIfDoc[3] Picture PesqPict("CNK","CNK_CODIGO") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+079,aPosObj2[2,2]+005 Say oNmDoc Var RetTitle("CNK_DESCRI") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+079,aPosObj2[2,2]+060 MsGet aCtrs[3] Var aIfDoc[4] Picture PesqPict("CNK","CNK_DESCRI") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+090,aPosObj2[2,2]+005 Say oDeDoc Var RetTitle("CNK_DTEMIS") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+090,aPosObj2[2,2]+060 MsGet aCtrs[5] Var aIfDoc[5] Picture PesqPict("CNK","CNK_DTEMIS") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+101,aPosObj2[2,2]+005 Say oDvDoc Var RetTitle("CNK_DTVALI") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+101,aPosObj2[2,2]+060 MsGet aCtrs[6] Var aIfDoc[6] Picture PesqPict("CNK","CNK_DTVALI") When .F. Size 60,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+112,aPosObj2[2,2]+005 Say oObDoc Var RetTitle("CNK_OBS") Size 50,8 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+112,aPosObj2[2,2]+060 MsGet aCtrs[7] Var aIfDoc[7] Picture PesqPict("CNK","CNK_OBS") When .F. Size 100,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+123,aPosObj2[2,2]+005 Say oStDoc Var OemToAnsi(STR0072) Size 50,8 Of oGroup1 PIXEL//"Status"
			@ aPosObj2[2,1]+123,aPosObj2[2,2]+060 MsGet aCtrs[8] Var aIfDoc[13] When .F. Size 100,5 Of oGroup1 PIXEL
            @ aPosObj2[2,1]+134,aPosObj2[2,2]+005 Say oStAss Var OemToAnsi(STR0213) Size 100,8 Of oGroup1 PIXEL//"Status da Assinatura"
			@ aPosObj2[2,1]+134,aPosObj2[2,2]+060 MsGet aCtrs[13] Var aIfDoc[12] When .F. Size 100,5 Of oGroup1 PIXEL
			@ aPosObj2[2,1]+147,aPosObj2[2,2]+005 Say aCtrs[11] Var OemToAnsi(STR0073)+AllTrim(str(aIfDoc[10]))+OemToAnsi(STR0074) Size __DlgWidth(oDlDoc)-42,8 Of oGroup1 PIXEL//"Base de Conhecimento: "##" registro(s)"
		
			DEFINE SBUTTON FROM aPosObj1[3,1], aPosObj1[3,4]-55 TYPE 1 ACTION (If(lCN100DCS, (lLiber:=ExecBlock("CN100DCS",.F.,.F.,{oDlDoc,aDocs,lLiber}),oDlDoc:End()),If((lLiber := aScan(aDocs,{|x| x[8] == 0 .Or. Iif(x[13], x[11] < x[9], .T.) }) == 0),(oDlDoc:End()),(lLiber:=CNTNoDoc(aDocs),oDlDoc:End())))) ENABLE OF oDlDoc
			DEFINE SBUTTON FROM aPosObj1[3,1], aPosObj1[3,4]-25 TYPE 2 ACTION (lLiber:=.F.,oDlDoc:End()) ENABLE OF oDlDoc
		
			ACTIVATE MSDIALOG oDlDoc CENTERED
		Else
			//Validar quando via ExecAuto
			lLiber := CNTNoDoc(aDocs)
		EndIf
		
		FwFreeArray(aDocs)
	Else	
		//Libera validacao quando nao houver documentos relacionados	
		lLiber := .T.
		(cAlias)->(dbCloseArea())
	EndIf
	
	FwFreeArray(aArea)
Return lLiber

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CNTAlDoc³   Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza valores de exibicao do elemento selecionado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTAlDoc(oExp01,aExp02,aExp03,lExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - DbTree                                            ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos           ³±±
±±³          ³ aExp03 - Array com os valores exibidos na dialog           ³±±
±±³          ³ aExp04 - Valida documento com base no banco de conhecimento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CNTAlDoc(oTree,aDocs,aIfDoc,lBsCnh)
Local nPos := 0
Local cCargo := oTree:GetCargo()
//Local lStatusDoc := .F.

Default lBsCnh := (SuperGetMv( "MV_CNDOCBC", .F., "S") == "S")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica posicao no array aDocs                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "A" $ cCargo .Or. "V" $ cCargo
	nPos := val(SubStr(cCargo,2,len(cCargo)))
Else
	nPos := val(cCargo)
EndIf

If nPos == 0
	aIfDoc := {"","","","",CTOD("  /  /  "),CTOD("  /  /  "),"",0,0,0,0,"",""}
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera copia do item do aDocs para o aIfDoc          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aIfDoc := Array(13)//Limpa array de exibicao
	aCopy(aDocs[nPos], aIfDoc, 1, 12)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica situacao do documento quando o mesmo existir³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aDocs[nPos,3])
		If aDocs[nPos,5] <= dDataBase .And. aDocs[nPos,6] >= dDataBase
            If lBsCnh .And. aDocs[nPos,10] == 0
				aIfDoc[13] := STR0076//"Não possui banco de conhecimento"
			Else
                aIfDoc[13] := STR0075//"Válido"
			EndIf
		Else
			aIfDoc[13] := STR0077//"Vencido"
		EndIf

	Else
		aIfDoc[13] := ""//"Vencido"
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNTNoDoc  ºAutor  ³ TOTVS              º Data ³  03/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao de validacao de documentos pendentes do contrato    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aDocs: Array com os documentos por tipo de documento       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTXDOC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CNTNoDoc(aDocs)
	Local lRet := .T.
	Local lBsCnh := (SuperGetMv( "MV_CNDOCBC", .F., "S") == "S")//Verifica se a validacao leva em consideracao o banco de conhec.	
	Local lMostraDoc := SuperGetMv("MV_GCDOCPE", .F., "N") == "S" //Determina se pode ou não alterar a Situação de um Contrato sem documento anexado. 
    Local lTotvsSign := SuperGetMv( "MV_CNTSIGN", .F., "0") == "1"//Verifica se permite TOTVS Sign
	Local lAuto := IsBlind()
    Local lCposSign := CN5->(FieldPos("CN5_ASSINA")) > 0 .And. CNK->(FieldPos("CNK_SIGNID")) > 0 .And. CNK->(FieldPos("CNK_SIGNST"))
	Local lPerg := .F.
	Local lFirst := .T.
    Local lSign := .F.
	Local nI := 0
	Local nTotDVlD := 0
	Local nTotDoc := 0
    Local nTotSign := 0
	Local cCod := ""
	
    If lCposSign .And. lTotvsSign
        ProcessSign(aDocs, .F., 3) //Atualiza status das assinaturas
    EndIf
    
	If lAuto //Tratamento para rotina automárica
		For nI := 1 To Len(aDocs)
            lSign := lTotvsSign .And. aDocs[nI,13]

			If lFirst //Primeiro registro do tipo de documento
				lFirst := .F.
				cCod :=  aDocs[nI,1]
				nTotDoc := 0
				nTotDVld := 0
                nTotSign := 0
			EndIf

			If !Empty(aDocs[nI,5]) //Valida data do documento
				If aDocs[nI,5] <= dDataBase .And. aDocs[nI,6] >= dDataBase .And. IIf(lBsCnh .Or. lSign, aDocs[nI,10] > 0, .T.)
					nTotDVlD++
				EndIf
				nTotDoc++
			EndIf

            If lSign .And. aDocs[nI,11] > 0 //Valida se o documento foi assinado
                nTotSign++
            EndIf

			If nI == Len(aDocs) .Or. aDocs[nI+1,1] != cCod //Verifica se é o ultimo elemento do grupo
				//Atualiza campos totalizadores do grupo				
				aDocs := aEval(aDocs, {|x| If(x[1] == aDocs[nI,1], (x[8] := nTotDVlD, x[9] := nTotDoc, x[11] := nTotSign),)})
				nTotDoc := 0
                nTotSign := 0
				lFirst := .T.
			EndIf
		Next nI
	EndIf

	For nI:= 1 to Len(aDocs)
        lSign := aDocs[nI,13]

        If (aDocs[nI,10] == 0 .And. lBsCnh) .Or. (lSign .And. (aDocs[nI,11] < aDocs[nI,9] .Or. aDocs[nI,11] == 0))
            lRet := .F.
            Help(" ",1,"CNTA100DOC")
            Exit
        EndIf

		If(aDocs[nI,9] == 0 .And. !lPerg) // Nenhum documento vinculado ao contrato
			lPerg := .T.
		EndIf
	Next nI
	
	If(!lBsCnh .And. !lSign .And. lPerg)
		If(!lAuto .And. lMostraDoc)
			lRet := MsgYesNo(STR0191,STR0067)	// "Não foi encontrado nenhum documento para o contrato. Deseja alterar a situação mesmo assim?"	
		Else
			Help(" ",1,"CNTA100DOC")
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} DocViaC171
	Realiza a inclusão de um documento via CNTA171
@author philipe.pompeu
@since 16/04/2021
@param cContra, caractere, contrato do documento 
@param cTpDoc, caractere, tipo do documento
@param cCod, caractere, retorna o código do documento inserido.
@param nOpc, numerico, operação 1- Insere documento; 2- Visualiza documento
@return lResult, logico, se a inclusão ocorreu corretamente
*/
Static Function DocViaC171(cContra as Char, cTpDoc as Char, cCod as Char, nOpc as Numeric) as Logical
	Local lResult	:= .F.
	Local nRet		:= 1
    Local nOper     := 0
	Local oModel	:= Nil
	Local oMdlCNK	:= Nil

    Default cContra := ''
    Default cTpDoc  := ''
    Default cCod    := ''
    Default nOpc    := 1

	If FindFunction("CNTA171")
		oModel := FWLoadModel("CNTA171")

        If nOpc == 1
		   nOper := MODEL_OPERATION_INSERT
        ElseIf nOpc == 2
            nOper := MODEL_OPERATION_VIEW
        EndIf
        
        oModel:SetOperation(nOper)

		oModel:Activate()
		
        If nOpc == 1
            oMdlCNK := oModel:GetModel("CNKMASTER")

            cCod := oMdlCNK:GetValue("CNK_CODIGO")

            oMdlCNK:SetValue("CNK_CONTRA"	, cContra)
            oMdlCNK:SetValue("CNK_TPDOC"	, cTpDoc)

            oMdlCNK:GetStruct():SetProperty("CNK_CONTRA",MODEL_FIELD_WHEN,{||.F.})
            oMdlCNK:GetStruct():SetProperty("CNK_TPDOC"	,MODEL_FIELD_WHEN,{||.F.})
        EndIf

		nRet := FWExecView( STR0062 , "CNTA171", nOper, /*oDlg*/, /*bCloseOnOK*/,/*bOk*/ , 30, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )

        lResult := (nRet == 0)
	EndIf
Return lResult

/*/{Protheus.doc} ProcessSign
	Processa documentos via TOTVS Sign.
@author juan.felipe
@since 20/04/2021
@param aDocs, array, documentos
@param lShowMsg, logical, exibe mensagens de sucesso ou erro
@param nOpc, numeric, opção a ser realiaza 1- Integra assinatura; 2- Republica assinatura; 3- Atualiza Status
@param oTree, object, árvore de documentos
@return Nil, nulo
/*/
Static Function ProcessSign(aDocs, lShowMsg, nOpc, oTree)
    Default aDocs := {}
    Default lShowMsg := .T.
    Default nOpc := 0
	Default oTree := Nil

    Processa({|| EnvAssDoc(aDocs, lShowMsg, nOpc, oTree)}, "TOTVS Sign")
Return Nil

/*/{Protheus.doc} EnvAssDoc
	Realiza integração com o TOTVS Sign.
@author juan.felipe
@since 19/04/2021
@param aDocs, array, documentos
@param lShowMsg, logical, exibe mensagens de sucesso ou erro
@param nOpc, numeric, opção a ser realiaza 1- Integra assinatura; 2- Republica assinatura; 3- Atualiza Status
@param, oTree, object, árvore de documentos
@return Nil, nulo
/*/
Static Function EnvAssDoc(aDocs, lShowMsg, nOpc, oTree)
    Local aStatusDoc As Array
    Local lEmptyDoc  As Logical
    Local lValidDoc  As Logical
    Local nX         As Numeric
	Local nCountDoc	 As Numeric
    Local nLen       As Numeric
    Local nProcDoc   As Numeric
    Local oGCTSign   As Object

    Default aDocs := {}
    Default lShowMsg := .T.
    Default nOpc := 0
    Default oTree := Nil
    
    If Len(aDocs) > 0
        oGCTSign := GCTSign():New()
        oGCTSign:SetOperation(nOpc)

        If oGCTSign:Authenticate()
            lValidDoc := .F.
			nCountDoc := 1
            nLen := Len(aDocs)
            nProcDoc := nLen
            ProcRegua(nLen)

            For nX := 1 To nLen
                lEmptyDoc := Empty(aDocs[nX][3]) //-- Se vazio é um tipo de documento

                If lEmptyDoc .And. nProcDoc > 1 //-- Subtrai documentos a serem processados caso o seja o elemento de tipo de documento
                    nProcDoc -= 1
                EndIf

                If aDocs[nX][13] //-- Permite assinatura digital
					IncProc(STR0214 + cValToChar(nCountDoc) + STR0215 + cValToChar(nProcDoc)) //Processando documento X de XX

                    If !lEmptyDoc
                        nCountDoc ++
                        oGCTSign:SetDocument(aDocs[nX][3])
                        oGCTSign:SetSignId(Val(aDocs[nX][14]))
                        
                        If oGCTSign:Process(.F.) //-- Processa documento
                            aStatusDoc := oGCTSign:GetStatusDoc()
                            aDocs[nX][12] := aStatusDoc[2]
                            aDocs[nX][14] := cValToChar(oGCTSign:GetSignId())

                            If nOpc == 3 .And. !Empty(aDocs[nX][14]) //-- Marca documento na tree
                                lValidDoc := aStatusDoc[1] .And. aDocs[nX,5] <= dDataBase .And. aDocs[nX,6] >= dDataBase .And. aDocs[nX,10] > 0
                                
                                If lValidDoc
                                    aEval(aDocs, {|x| Iif(x[1] == aDocs[nX,1], x[11]++, Nil) }) //-- Atualiza contador de documentos assinados
                                    
                                    If oTree <> Nil .And. oTree:TreeSeek(cValToChar(nX))
                                        oTree:BeginUpdate()
                                        oTree:ChangeBmp("LBTIK","LBTIK")
                                        oTree:EndUpdate()
                                        oTree:Refresh()
                                    EndIf

                                EndIf

                            EndIf

                        EndIf

                    EndIf
                    
                EndIf
            Next nX
        EndIf
        
        If nOpc == 3 .And. oTree <> Nil //Tratamento para atualizar marcador do tipo de documento
            For nX := 1 To nLen
                If oTree:TreeSeek("A"+cValToChar(nX)) //-- Marca tipo do documento na tree
                    oTree:BeginUpdate()

                    If aScan(aDocs,{|x| x[1] == aDocs[nX,1] .And. x[5] <= dDataBase .And. x[6] >= dDataBase .And. x[10] > 0 .And. x[9] == x[11]}) > 0
                        oTree:ChangeBmp("LBTIK","LBTIK")
                    Else
                        oTree:ChangeBmp("LBNO","LBNO")
                    EndIf

                    oTree:EndUpdate()
                    oTree:Refresh()
                EndIf
            Next nX
        EndIf

        If lShowMsg
            oGCTSign:GetMessage(.F.) //-- Exibe mensagens de sucesso ou erro
        EndIf

        oGCTSign:CleanUp()
        FreeObj(oGCTSign)
    EndIf

Return Nil

/*/{Protheus.doc} SetStsSign
	Seta status da assinatura para o documento no array aDocs.
Essa função atualiza as seguintes posições da estrutura do aDocs:
	aDocs[x,11]- Total de Documentos assinados
	aDocs[x,12]- Status assinatura
	aDocs[x,13]- Permite assinatura digital
	aDocs[x,14]- Id da assinatura digital	
@author juan.felipe
@since 30/04/2021
@param aDocumento, array, um documento
@param lSign, logical, permite assinatura eletrônica
@param cSignId, character, id da assinatura (CNK_SIGNID)
@param cSignSts, character, status da assinatura (CNK_SIGNST)
@return Nil, nulo
/*/
Static Function SetStsSign(aDocumento, lSign, cSignId, cSignSts)
    Default aDocumento 	:= {}
    Default lSign 		:= .F.
    Default cSignId 	:= ''
    Default cSignSts 	:= ''

    If (Len(aDocumento) >= 14)
        If cSignSts == '2' .And. lSign
			aDocumento[11] := 1            
        Else
			aDocumento[11] := 0            
        EndIf

        If cSignSts == '0'
            aDocumento[12] := STR0203 //Pendente
        ElseIf cSignSts == '2'
            aDocumento[12] := STR0204 //Finalizada
        ElseIf cSignSts == '4'
            aDocumento[12] := STR0205 //Rejeitada
        ElseIf cSignSts == '5'
            aDocumento[12] := STR0206 //Em Rascunho
        Else
            aDocumento[12] := STR0202 //Não possui assinatura
        EndIf
		
		aDocumento[13] := lSign
		aDocumento[14] := cSignId
    EndIf

Return Nil

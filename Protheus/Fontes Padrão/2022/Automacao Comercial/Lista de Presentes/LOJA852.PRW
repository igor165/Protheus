#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA852.CH"
#DEFINE CRLF CHR(13)+CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LOJA852  ³ Autor ³ Vendas Cliente        ³ Data ³ 26/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Endreçamento do Browser                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA852()

Private aCores  := {}
Private aRotina := {	{STR0001,"AxPesqui"		,0,1},;		//Pesquisar
					 	{STR0002,"LJ852PROC"	,0,2},;		//Visualizar
  					 	{STR0003,"LJ852PROC"  ,0,3},;		//Incluir
  					 	{STR0004,"LJ852PROC"  ,0,4},;		//Alterar
  					 	{STR0005,"LJ852PROC"	,0,5}}		//Excluir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Semaforo:                     ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Verde    - Sugestao ativa     ³
//³ Vermelho - Sugestao Bloqueada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCores,{'ME7_STATUS =  "1"','BR_VERDE'   })
aAdd(aCores,{'ME7_STATUS <> "1"','BR_VERMELHO'})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enderaca o browser ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ME7")
dbSetOrder(1)
mBrowse( 6,1,22,75,"ME7",,,,,,aCores,,,,,,,,)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³          ³ Autor ³ Vendas Cliente        ³ Data ³ 26/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ852PROC(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlgLbx
Local oTit1
Local oTit2
Local oTit3
Local oListBx1
Local oListBx2
Local oListBx3
Local oCheck    := LoadBitMap(GetResources(),"LBOK"			)
Local oNoCheck  := LoadBitMap(GetResources(),"LBNO"			)
Local oCan	  := LoadBitMap(GetResources(),"BR_VERDE"		)
Local oNoCan	  := LoadBitMap(GetResources(),"BR_VERMELHO"	)
Local VISUALIZA := nOpc == 2
Local INCLUI    := nOpc == 3
Local ALTERA    := nOpc == 4
Local EXCLUI    := nOpc == 5    
Local nOpca     := 0
Local cTit1     := STR0006 //"Facilitadores"
Local cTit2     := STR0007 //"Grupos de Lista"
Local cTit3     := STR0008 //"Produtos"
Local cTabela   := ""
Local aDados    := {}
Local oWndDefault := GetWndDefault() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Dialog da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgLbx  := TDialog():New(001,001,480,1000,OemToAnsi(STR0009),,,,,,,,oMainWnd,.T.) //"Sugestao de Lista"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Enchoice na parte superior da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("ME7",INCLUI,.F.)
If INCLUI
	M->ME7_CODIGO := GetSx8Num("ME7","ME7_CODIGO")
	M->ME7_STATUS := "1"
EndIf
cTabela := M->ME7_CODIGO
Processa({||aDados := LJ852Dados(cTabela)},STR0013)
EnChoice("ME7",nReg,nOpc,,,,,{15,5,70,495},,,,,,,,.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta 1o listbox na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 075, 005 Say oTit1 Var cTit1 Size 140, 010 Pixel Of oDlgLbx // Font oFntVlr
oListBx1 := TwBrowse():New(085,005,160,150,,{STR0010,STR0011},,oDlgLbx,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
oListBx1:SetArray(aDados)
oListBx1:bLine:={||{	aDados[oListBx1:nAt,1],;
						aDados[oListBx1:nAt,2]}}

oListBx1:bChange:= { ||	oListBx2:SetArray(aDados[oListBx1:nAt,3])							   									,;
						oListBx2:bLine:={||{	aDados[oListBx1:nAt,3,oListBx2:nAt,1]		 									,;
												aDados[oListBx1:nAt,3,oListBx2:nAt,2]}}	 									    ,;
						oListBx2:Refresh()								   					 									,;
						oListBx3:SetArray(aDados[oListBx1:nAt,3,oListBx2:nAt,3])			  									,;
						oListBx3:bLine:={||{	If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,4]	,oCheck,oNoCheck)	,;
												If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,3]	,oCan  ,oNoCan  )	,;
													aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,1]						,;
													aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,2]	}}					,;	
						oListBx3:Refresh()													   									}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta 2o listbox na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 075, 170 Say oTit2 Var cTit2 Size 140, 010 Pixel Of oDlgLbx // Font oFntVlr
oListBx2 := TwBrowse():New(085,170,160,150,,{STR0010,STR0011},,oDlgLbx,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
oListBx2:SetArray(aDados[oListBx1:nAt,3])
oListBx2:bLine:={||{	aDados[oListBx1:nAt,3,oListBx2:nAt,1],;
						aDados[oListBx1:nAt,3,oListBx2:nAt,2]}}

oListBx2:bChange:= { ||	oListBx3:SetArray(aDados[oListBx1:nAt,3,oListBx2:nAt,3])			  								,;
						oListBx3:bLine:={||{	If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,4],oCheck,oNoCheck)	,;
												If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,3],oCan  ,oNoCan  )	,;
													aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,1]					,;
													aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,2]}}					,;	
						oListBx3:Refresh()													   								}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta 3o listbox na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 075, 335 Say oTit3 Var cTit3 Size 140, 010 Pixel Of oDlgLbx // Font oFntVlr
oListBx3 := TwBrowse():New(085,335,160,150,,{"","",STR0010,STR0012},,oDlgLbx,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
oListBx3:SetArray(aDados[oListBx1:nAt,3,oListBx2:nAt,3])			  									
oListBx3:bLine:={||{	If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,4],oCheck,oNoCheck)	,;
						If(	aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,3],oCan  ,oNoCan  )	,;
							aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,1]					,;
							aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,2]					}}		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Clique na selecao dos produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI .Or. ALTERA
	oListBx3:BlDblClick := { ||	Iif(aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,3]	,;
									aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,4]:=	!;
									aDados[oListBx1:nAt,3,oListBx2:nAt,3,oListBx3:nAt,4]	,;
									.T.)}
EndIf
	
Activate MsDialog oDlgLbx Center On Init EnchoiceBar(oDlgLbx, {||(Iif(U_LJ852VLOK(),(oDlgLbx:End(),nOpca:=1),nOpca:=0))}, {|| (oDlgLbx:End(),nOpca := 0)},,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava a sugestao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1

	If !VISUALIZA
		If INCLUI
			ConfirmSx8()
		EndIf
		cTabela := M->ME7_CODIGO
		LJ852Grv(aDados,cTabela)
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ852DADOS³ Autor ³ Vendas Cliente        ³ Data ³ 26/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Carrega o conteudo no array das estruturas                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ852Dados(cTabela)
Local aAreaAnt := GetArea()
Local cAliasNew:= ''
Local cQuery	:= ''
//-- Pergunte
Local aDados	:= {}
Local aRet		:= {}
Local cCatDe	:= ''
Local cCatAte	:= ''
Local cArmDe	:= ''
Local cArmAte	:= ''
Local cProDe	:= ''
Local cProAte	:= ''


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declara variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCodFac  := ""
Private cDesFac  := ""
Private cCodGrp  := ""
Private cDesGrp  := ""
Private nPosFac  := 0
Private nPosGrp  := 0
Private lRetorno := .F.
Private lACVByPs := GetMv("MV_ACVBYPS ",,.T.)
Private aRetorno := {}


SB1->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a estrutura de categorias - apenas 2 niveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If lACVByPs

	SB1->(dbGoTop())
	ProcRegua(SB1->(RecCount()))
	While SB1->(!Eof())
		
		IncProc(STR0018+SB1->B1_COD)
		
		cCodGrp  := STR0014
		cDesGrp  := STR0015
			
		cCodFac  := STR0014
		cDesFac  := STR0016
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manipula facilitadores  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosFac := aScan(aRetorno,{|x| x[1] == cCodFac})
		If nPosFac == 0
			aAdd(aRetorno,{cCodFac,cDesFac,{}})
			nPosFac := Len(aRetorno)
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manipula grupo de lista ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosGrp := aScan(aRetorno[nPosFac,3],{|y| y[1] == cCodGrp})
		If nPosGrp == 0
			aAdd(aRetorno[nPosFac,3],{cCodGrp,cDesGrp,{}})
			nPosGrp := Len(aRetorno[nPosFac,3])
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manipula produtos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aRetorno[nPosFac,3,nPosGrp,3],{|y| y[1] == SB1->B1_COD}) == 0
			If SB1->(dbSeek(xFilial("SB1")+SB1->B1_COD))
				ME8->(dbSetOrder(1))
				lRetorno := ME8->(dbSeek(xFilial("ME8")+cTabela+cCodFac+cCodGrp+SB1->B1_COD))
				aAdd(aRetorno[nPosFac,3,nPosGrp,3],{SB1->B1_COD,SB1->B1_DESC,SB1->B1_MSBLQL<>'1', lRetorno .And. SB1->B1_MSBLQL<>'1'})
			EndIf
		EndIf
		
		SB1->(dbSkip())
		
	EndDo

Else
	dbSelectArea("ACV")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(ACV->(RecCount()))
	While ACV->(!Eof())
		
		IncProc(STR0017+ACV->ACV_CATEGO)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Identifica segundo nivel ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ACU->(dbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
			
			If Empty(ACU->ACU_COD)
				cCodGrp  := STR0014
				cDesGrp  := STR0015
			Else
				cCodGrp := AllTrim(ACU->ACU_COD)
				cDesGrp := AllTrim(ACU->ACU_DESC)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica primeiro nivel ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(ACU->ACU_CODPAI)
				cCodFac  := STR0014
				cDesFac  := STR0016
			Else
				If ACU->(dbSeek(xFilial("ACU")+ACU->ACU_CODPAI))
					cCodFac := AllTrim(ACU->ACU_COD)
					cDesFac := AllTrim(ACU->ACU_DESC)
				Else
					cCodFac  := STR0014
					cDesFac  := STR0016
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula facilitadores  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosFac := aScan(aRetorno,{|x| x[1] == cCodFac})
			If nPosFac == 0
				aAdd(aRetorno,{cCodFac,cDesFac,{}})
				nPosFac := Len(aRetorno)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula grupo de lista ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosGrp := aScan(aRetorno[nPosFac,3],{|y| y[1] == cCodGrp})
			If nPosGrp == 0
				aAdd(aRetorno[nPosFac,3],{cCodGrp,cDesGrp,{}})
				nPosGrp := Len(aRetorno[nPosFac,3])
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula produtos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aRetorno[nPosFac,3,nPosGrp,3],{|y| y[1] == ACV->ACV_CODPRO}) == 0
				If SB1->(dbSeek(xFilial("SB1")+ACV->ACV_CODPRO))
					ME8->(dbSetOrder(1))
					lRetorno := ME8->(dbSeek(xFilial("ME8")+cTabela+cCodFac+cCodGrp+SB1->B1_COD))
					aAdd(aRetorno[nPosFac,3,nPosGrp,3],{SB1->B1_COD,SB1->B1_DESC,SB1->B1_MSBLQL<>'1', lRetorno .And. SB1->B1_MSBLQL<>'1'})
				EndIf
			EndIf
		EndIf
		
		ACV->(dbSkip())
		
	EndDo
EndIf
*/

cAliasNew := GetNextAlias()
If lACVByPs
	aDados := {	{	1,'Armazem De'		,Replicate(' ',Len(SB1->B1_LOCPAD)),'@!','','','',020,.F.	},;
					{	1,'Armazem Ate'	,Replicate('Z',Len(SB1->B1_LOCPAD)),'@!','','','',020,.F.	},;
					{	1,'Produto De'		,Replicate(' ',Len(SB1->B1_COD)),'@!',"Iif(Empty(MV_PAR03)												 ,'',ExistCpo('SB1',MV_PAR03))",'SB1','',100,.F.},;
					{	1,'Produto Ate'	,Replicate('Z',Len(SB1->B1_COD)),'@!',"Iif(Empty(MV_PAR04) .Or. 'ZZZ'$Upper(Substr(MV_PAR04,3)),'',ExistCpo('SB1',MV_PAR04))",'SB1','',100,.F.	} }

	If	ParamBox(aDados, 'Produto', @aRet)
		cArmDe	:= aRet[1]
		cArmAte	:= aRet[2]
		cProDe	:= aRet[3]
		cProAte	:= aRet[4]
	
		cQuery := "SELECT B1_COD, B1_DESC, B1_MSBLQL "
		cQuery += " FROM"
		cQuery += " "+RetSqlName('SB1')+" SB1"
		cQuery += " WHERE "
		cQuery += " B1_FILIAL = '"+xFilial("SB1")+"'"
		cQuery += " AND B1_LOCPAD BETWEEN '" + cArmDe + "' AND '" + cArmAte + "' "
		cQuery += " AND B1_COD   BETWEEN '" + cProDe + "' AND '" + cProAte + "' "
		cQuery += " AND SB1.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY B1_FILIAL,B1_LOCPAD,B1_COD"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	
		ProcRegua(SB1->(RecCount()))
	
		While (cAliasNew)->(!Eof())
	
			IncProc(STR0017+(cAliasNew)->B1_COD)

			cCodGrp  := STR0014
			cDesGrp  := STR0015
			
			cCodFac  := STR0014
			cDesFac  := STR0016
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula facilitadores  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosFac := aScan(aRetorno,{|x| x[1] == cCodFac})
			If nPosFac == 0
				aAdd(aRetorno,{cCodFac,cDesFac,{}})
				nPosFac := Len(aRetorno)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula grupo de lista ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosGrp := aScan(aRetorno[nPosFac,3],{|y| y[1] == cCodGrp})
			If nPosGrp == 0
				aAdd(aRetorno[nPosFac,3],{cCodGrp,cDesGrp,{}})
				nPosGrp := Len(aRetorno[nPosFac,3])
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula produtos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aRetorno[nPosFac,3,nPosGrp,3],{|y| y[1] == (cAliasNew)->B1_COD}) == 0
				ME8->(dbSetOrder(1))
				lRetorno := ME8->(dbSeek(xFilial("ME8")+cTabela+cCodFac+cCodGrp+(cAliasNew)->B1_COD))
				aAdd(aRetorno[nPosFac,3,nPosGrp,3],{(cAliasNew)->B1_COD,(cAliasNew)->B1_DESC,(cAliasNew)->B1_MSBLQL<>'1', lRetorno .And. (cAliasNew)->B1_MSBLQL<>'1'})
			EndIf

			(cAliasNew)->(DbSkip())
		EndDo
		DbSelectarea(cAliasNew)
		DbCloseArea()
		RestArea(aAreaAnt)
	EndIf

Else

	aDados := {	{	1,'Armazem De'		,Replicate(' ',Len(SB1->B1_LOCPAD)),'@!','','','',020,.F.	},;
					{	1,'Armazem Ate'	,Replicate('Z',Len(SB1->B1_LOCPAD)),'@!','','','',020,.F.	},;
					{	1,'Produto De'		,Replicate(' ',Len(ACV->ACV_CODPRO)),'@!',"Iif(Empty(MV_PAR03)												 ,'',ExistCpo('SB1',MV_PAR03))",'SB1','',100,.F.},;
					{	1,'Produto Ate'	,Replicate('Z',Len(ACV->ACV_CODPRO)),'@!',"Iif(Empty(MV_PAR04) .Or. 'ZZZ'$Upper(Substr(MV_PAR04,3)),'',ExistCpo('SB1',MV_PAR04))",'SB1','',100,.F.},;
					{	1,'Categoria De'	,Replicate(' ',Len(ACV->ACV_CATEGO)),'@!','','','',100,.F.	},;
					{	1,'Categoria Ate'	,Replicate('Z',Len(ACV->ACV_CATEGO)),'@!','','','',100,.F.	} }

	If	ParamBox(aDados, 'Categorias', @aRet)
		cArmDe	:= aRet[1]
		cArmAte	:= aRet[2]
		cProDe	:= aRet[3]
		cProAte	:= aRet[4]
		cCatDe	:= aRet[5]
		cCatAte	:= aRet[6]
	
		cQuery := "SELECT ACV_CATEGO, ACU_COD, ACU_DESC, ACU_CODPAI, ACV_CODPRO, B1_COD, B1_DESC, B1_MSBLQL "
		cQuery += " FROM"
		cQuery += " "+RetSqlName('ACV')+" ACV,"
		cQuery += " "+RetSqlName('ACU')+" ACU,"
		cQuery += " "+RetSqlName('SB1')+" SB1"
		cQuery += " WHERE "
		cQuery += " ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
		cQuery += " AND ACV.ACV_CATEGO BETWEEN '" + cCatDe + "' AND '" + cCatAte + "' "
		cQuery += " AND ACV.ACV_CODPRO BETWEEN '" + cProDe + "' AND '" + cProAte + "' "
		cQuery += " AND ACV.D_E_L_E_T_ = ' '"
		cQuery += " AND ACU.ACU_FILIAL = '"+xFilial("ACU")+"'"
		cQuery += " AND ACU.ACU_COD = ACV.ACV_CATEGO "
		cQuery += " AND ACU.D_E_L_E_T_ = ' '"
		cQuery += " AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
		cQuery += " AND SB1.B1_COD = ACV.ACV_CODPRO "
		cQuery += " AND SB1.D_E_L_E_T_=' '"
		cQuery += " ORDER BY ACV.ACV_FILIAL, ACV.ACV_CATEGO, ACV.ACV_CODPRO"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	
		ProcRegua(ACV->(RecCount()))
	
		While (cAliasNew)->(!Eof())
	
			IncProc(STR0017+(cAliasNew)->ACV_CATEGO)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica segundo nivel ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty((cAliasNew)->ACU_COD)
				cCodGrp  := STR0014
				cDesGrp  := STR0015
			Else
				cCodGrp := AllTrim((cAliasNew)->ACU_COD)
				cDesGrp := AllTrim((cAliasNew)->ACU_DESC)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica primeiro nivel ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty((cAliasNew)->ACU_CODPAI)
				cCodFac  := STR0014
				cDesFac  := STR0016
			Else
				If ACU->(dbSeek(xFilial("ACU")+(cAliasNew)->ACU_CODPAI))
					cCodFac := AllTrim(ACU->ACU_COD)
					cDesFac := AllTrim(ACU->ACU_DESC)
				Else
					cCodFac  := STR0014
					cDesFac  := STR0016
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula facilitadores  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosFac := aScan(aRetorno,{|x| x[1] == cCodFac})
			If nPosFac == 0
				aAdd(aRetorno,{cCodFac,cDesFac,{}})
				nPosFac := Len(aRetorno)
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula grupo de lista ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosGrp := aScan(aRetorno[nPosFac,3],{|y| y[1] == cCodGrp})
			If nPosGrp == 0
				aAdd(aRetorno[nPosFac,3],{cCodGrp,cDesGrp,{}})
				nPosGrp := Len(aRetorno[nPosFac,3])
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manipula produtos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aRetorno[nPosFac,3,nPosGrp,3],{|y| y[1] == (cAliasNew)->ACV_CODPRO}) == 0
				ME8->(dbSetOrder(1))
				lRetorno := ME8->(dbSeek(xFilial("ME8")+cTabela+cCodFac+cCodGrp+(cAliasNew)->ACV_CODPRO))
				aAdd(aRetorno[nPosFac,3,nPosGrp,3],{(cAliasNew)->B1_COD,(cAliasNew)->B1_DESC,(cAliasNew)->B1_MSBLQL<>'1', lRetorno .And. (cAliasNew)->B1_MSBLQL<>'1'})
			EndIf
			(cAliasNew)->(DbSkip())
		EndDo
		DbSelectarea(cAliasNew)
		DbCloseArea()
		RestArea(aAreaAnt)
	EndIf
EndIf

If Len(aRetorno) == 0
	aAdd(aRetorno,{"","",{}})
	aAdd(aRetorno[1,3],{"","",{}})
	aAdd(aRetorno[1,3,1,3],{"","",.F.,.F.})
EndIf

Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ852Grv  ³ Autor ³ Vendas Cliente        ³ Data ³ 26/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³sigaloja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ852Grv(aDados,cTabela)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declara variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nQ := 0
Local nR := 0
Local nS := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³trata posicionamento do arquivo em paralelo ³
//³a posicao do array, para nao carregar a     ³
//³base de dados com sujeira.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ME8")
dbSetOrder(2)
dbSeek(xFilial("ME8")+cTabela,.T.)

If !EXCLUI
	For nQ:=1 To Len(aDados)
		For nR:=1 To Len(aDados[nQ,3])
			For nS:=1 To Len(aDados[nQ,3,nR,3])    
				If aDados[nQ,3,nR,3,nS,4]
					
					RecLock("ME8",ME8->ME8_CODIGO <> cTabela .Or. Eof())
					ME8->ME8_FILIAL := xFilial("ME8")
					ME8->ME8_CODIGO := cTabela
					ME8->ME8_FACIL  := aDados[nQ,1]
					ME8->ME8_DESFAC := aDados[nQ,2]
					ME8->ME8_GRPLIS := aDados[nQ,3,nR,1]
					ME8->ME8_DESGRP := aDados[nQ,3,nR,2]
					ME8->ME8_CODPRO := aDados[nQ,3,nR,3,nS,1]
					ME8->ME8_DESPRO := aDados[nQ,3,nR,3,nS,2]
					MsUnLock()
					
					ME8->(dbSkip())
				EndIf
	 		Next nS
		Next nR
	Next nQ
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga a sujeira ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ME8->(!Eof()) .And. ME8->(ME8_FILIAL+ME8_CODIGO) == xFilial("ME8")+cTabela
	RecLock("ME8",.F.)
	ME8->(dbDelete())
	MsUnLock()
	ME8->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o cabecalho apos os itens ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ME7")
dbSetOrder(1)
dbSeek(xFilial("ME7")+cTabela)
RecLock("ME7",INCLUI)

If EXCLUI
	ME7->(dbDelete())
Else
	ME7->ME7_FILIAL := xFilial("ME8")
	ME7->ME7_CODIGO := cTabela
	ME7->ME7_DESCRI := M->ME7_DESCRI
	ME7->ME7_TIPLIS := M->ME7_TIPLIS
	ME7->ME7_DESCTP := M->ME7_DESCTP
	ME7->ME7_STATUS := M->ME7_STATUS
EndIf	
	
MsUnLock()

Return()      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ852VlOk ³ Autor ³ Vendas Cliente        ³ Data ³ 26/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³sigaloja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LJ852VLOK()

Private lRet    := .T.
Private aArea   := GetArea()
Private aAreaX3 := SX3->(GetArea())

SX3->(dbSetOrder(1))
SX3->(dbSeek("ME7"))

While !Eof() .And. SX3->X3_ARQUIVO == "ME7"

	If Type("M->"+AllTrim(SX3->X3_CAMPO)) <> "U" 
		If !Empty(SX3->X3_OBRIGAT) .And. Empty(&("M->"+AllTrim(SX3->X3_CAMPO)))
			Help(" ",1,"OBRIGAT")
    		lRet := .F.
   			Exit
		EndIf
	EndIf

	SX3->(dbSkip())
EndDo

RestArea(aAreaX3)

Return(lRet)
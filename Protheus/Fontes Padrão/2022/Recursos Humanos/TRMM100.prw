#Include 'Protheus.ch'    
#Include 'TRMM100.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºFlavio C.    ³02/05/2016³              ³Rotina de geração de calendario de acordo ³±±
±±º            ³          ³               ³com a necessidade dos funcionarios        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TRMM100()
Local aSalva 	:= GetArea()
Private cPerg 	:= 'TRMM100'      

Pergunte( cPerg, .f. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela de dialogo.													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro	:= OemToAnsi( STR0001 )//"Sugestão de turmas para treinamento"                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
cDescricao 	:= OemToAnsi( STR0002 )//"Essa rotina irá sugerir a criação de turmas de acordo com o interesse nos treinamentos."
bProcesso 	:= {|oSelf| M100Calc(oSelf) }

tNewProcess():New( "TRMM100", cCadastro, bProcesso, cDescricao, cPerg,,.T.,20,cDescricao,.T.)

RestArea( aSalva )

Return

Static Function M100Calc(oSelf)
Local aArea 	:= GetArea()
Local cAliasTmp	:= GetNextAlias()
Local cWhere	:= ""
Local cJoin		:= '%' + FWJoinFilial( "RA3", "RA1" ) + '%'
Local cFilRange	:= ""
Local cCurso	:= ""
Local nQtdTurma	:= MV_PAR03
Local nQtd		:= 0
Local nI		:= 1
Local nTot		:= 0
Local nReserv	:= 0
Local nLinha	:= 0

Private aCols  		:= {}
Private aHeader		:= {}

M100Header()

MakeSqlExpr( cPerg ) //Transforma perguntas do tipo Range em expressao SQL

cFilRange  	:= mv_par01		//Range de Filiais
cCurso 		:= mv_par02		//Range de cursos

cWhere := "%"
cWhere += cFilRange 
If !Empty(cCurso)
	cWhere += " AND " + cCurso 
EndIf
cWhere += "%"
//verifica cursos com interesse sufuciente para montagem de turmas, respeitando a qtd minima definida no cadastro
BeginSql alias cAliasTmp
  SELECT RA3_FILIAL,RA3_CURSO,RA1_QTDMIN,COUNT(1) AS QTD
  FROM %table:RA3% RA3 
  INNER JOIN %table:RA1% RA1 
          ON %Exp:cJoin% 
         AND RA1.RA1_CURSO = RA3.RA3_CURSO  		
         AND RA1.%NotDel%		 
   WHERE %Exp:cWhere% 
       	 AND RA3.RA3_TURMA = %Exp:''% 
         AND RA3.RA3_CALEND = %Exp:''% 
         AND RA3.RA3_RESERV IN('S','L') 
         AND RA3.%NotDel%
   GROUP BY RA3_FILIAL,RA3_CURSO,RA1_QTDMIN
   HAVING COUNT(1) >= RA1_QTDMIN
EndSql   

DbSelectArea(cAliasTmp)
Count To nTot  
dbSelectArea(cAliasTmp)   
(cAliasTmp)->( DbGoTop() )


oSelf:SetRegua1(nTot)
oSelf:SaveLog(STR0003)//"Buscando treinamentos"

While !(cAliasTmp)->(Eof())
	oSelf:IncRegua1()
	nReserv := 0
	nQtd := Int((cAliasTmp)->QTD / nQtdTurma)
	If (cAliasTmp)->QTD % nQtdTurma > 0
		nQtd++
	EndIf
	dbSelectArea("RA1")
	RA1->(dbSeek(xFilial("RA1",(cAliasTmp)->RA3_FILIAL)+(cAliasTmp)->RA3_CURSO ))
	For nI := 1 To nQtd
		If ((cAliasTmp)->QTD - (nReserv * nQtdTurma)) >= Val((cAliasTmp)->RA1_QTDMIN)
			nLinha++
			//aadd(aTurmas,{(cAliasTmp)->RA3_FILIAL,(cAliasTmp)->RA3_CURSO,strzero(nI,3)})
			aAdd(aCols, { (cAliasTmp)->RA3_FILIAL	,;				
					(cAliasTmp)->RA3_CURSO	,;	
					RA1->RA1_DESC 	,;	
					strzero(nI,3)	,;	
					space(GetSx3Cache("RA2_ENTIDA", "X3_TAMANHO"))	,;	
					space(GetSx3Cache("RA2_DESCEN", "X3_TAMANHO"))	,;	
					date()+1	,;
					date()+30	,;
					"08:00"		,;
					RA1->RA1_DURACA 	,;
					nQtdTurma		,;
					space(GetSx3Cache("RA2_INSTRU", "X3_TAMANHO"))	,;
					space(GetSx3Cache("RA2_LOCAL", "X3_TAMANHO"))	,;
					0	,;
					space(GetSx3Cache("RA2_RESPON", "X3_TAMANHO"))	,;
					.F. 			;// GDDELETED 
		          })	
		          M100Custo(nLinha)
		          nReserv++
		EndIf
	Next nI
	
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

If Len(aCols) > 0
	M100tela(oSelf)
Else
	Aviso( OemToAnsi(STR0004),OemToAnsi(STR0005),{"OK"}) // "Atenção"#" "Atenção"#Não existem reservas suficientes para este treinamento!""
EndIf

RestArea(aArea)
Return

Static Function M100tela(oSelf)
Local aArea         := GetArea()
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdGrid
Local oPanelUp
Local oTela
Local oDlgPrinc
Local aData			:= {}
Local nI			:= 1
Local oSize      
Local bSet15		
Local bSet24		
Local nOpca 		:= 0

Define MsDialog oDlgPrinc Title OemToAnsi(STR0006) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Novas Turmas"

oSize := FWDefSize():New(.T.,,,oDlgPrinc) //passa para FWDefSize a dialog usada para calcular corretamente as proporções dos objetos
oSize:AddObject( "Panel1", 100, 100, .T., .T. ) //Panel 1 em 50% da tela
oSize:lProp := .T. //permite redimencionar as telas de acordo com a proporção do AddObject
oSize:Process() //executa os calculos


oTela     := FWFormContainer():New( oDlgPrinc )
cIdGrid   := oTela:CreateHorizontalBox( 80 )
oTela:Activate( oDlgPrinc, .F. )
oPanelUp  	:= oTela:GeTPanel( cIdGrid )

oGetDados	:= MsNewGetDados():New(oSize:GetDimension("Panel1","LININI"),;  // nTop
					oSize:GetDimension("Panel1","COLINI"),;		// nLelft
					oSize:GetDimension("Panel1","YSIZE"),;		// nBottom
					oSize:GetDimension("Panel1","XSIZE"),;		// nRright
					GD_UPDATE	,; 		// Controle do que podera ser realizado na GetDado - nstyle
					"M100Ok",;				// Funcao para validar a edicao da linha - ulinhaOK
					"M100Tok",;				// Funcao para validar todos os registros da GetDados - uTudoOK
					Nil,;				// cIniCPOS
					Nil,;				// aAlter
					0,;					// nfreeze
					99999,;				// nMax
					Nil,;				// cFieldOK
					Nil,;				// usuperdel
					Nil,;				// Bloco com funcao para validar registros deletados (Gp400DelOk())
					oDlgPrinc,;			// Objeto de dialogo - oWnd
				    aHeader,;			// Vetor com Header - AparHeader
				    @aCols;			// Vetor com Colunas - AparCols
				  ) 

	bSet15		:= { || nOpca := 1, If(oGetDados:TudoOk(), oDlgPrinc:End(), nOpca:=0) }
	bSet24		:= { || oDlgPrinc:End() }

Activate MsDialog oDlgPrinc ON INIT EnchoiceBar( oDlgPrinc , bSet15 , bSet24 ) Center

If nOpca == 1
	Begin Transaction
		M100Grava(oSelf)
	End Transaction	
EndIf

RestArea(aArea)
Return

Static Function M100Grava(oSelf)
Local aArea		:= GetArea()
Local cCod  	:= GetSx8Num("RA2","RA2_CALEND")
Local cDesc		:= "Reser. - " + dtoc(date()) //
Local nI		:= 1
Local nY		:= 1
Local cAliasTmp	
Local nCont		:= 0
Local nRecno	:= 0
Local aDados	:=  oGetDados:aCols
Local nPosFil	:= GdFieldPos("RA2_FILIAL")
Private cObs1 := ""
Private cObs2 := ""
Private cObs3 := ""
Private cObs4 := ""
Private cObs5 := ""
Private cObs6 := ""

ConfirmSX8()

oSelf:SetRegua2(Len(aDados))
oSelf:SaveLog(STR0007)//"Gravando reservas"
For nI := 1 to Len(aDados)
	oSelf:IncRegua2()
	If RA2->(RecLock("RA2",.T.))
		For nY := 1 To Len(aHeader)
			If aHeader[nY][10] <> "V"
				RA2->(FieldPut(FieldPos(aHeader[nY][2]),aDados[nI][nY]))
			EndIf	
		Next nY
		RA2->RA2_FILIAL 	:= xFilial("RA2")
		RA2->RA2_CALEND	 	:= cCod			
		RA2->RA2_DESC		:= cDesc
		RA2->RA2_DTREF		:= Date()
		RA2->(MsUnlock()) 
		nRecno := RA2->(Recno())
		
		cAliasTmp	:= GetNextAlias()
		//Grava RA3
		BeginSql alias cAliasTmp
		  SELECT RA3.R_E_C_N_O_ AS RA3RECNO
		  FROM %table:RA3% RA3 
		  WHERE RA3.RA3_FILIAL= %Exp:aDados[nI][nPosFil]% 
	   		 AND RA3.RA3_CURSO = %Exp:RA2->RA2_CURSO% 
	       	 AND RA3.RA3_RESERV IN('S','L') 
	       	 AND RA3.RA3_TURMA = ''
	       	 AND RA3.RA3_CALEND = ''
	         AND RA3.%NotDel%
		EndSql  
		         
		While !(cAliasTmp)->(eof())
			
			dbSelectArea("RA3")
			RA3->(dbGoTo((cAliasTmp)->RA3RECNO))
			RecLock("RA3",.F.)
				RA3->RA3_RESERV := "R"
				RA3->RA3_CALEND := RA2->RA2_CALEND
				RA3->RA3_TURMA  := RA2->RA2_TURMA
			RA3->(msUnlock())
			
			nCont++
			
			If RA3->RA3_EMAIL != "S"	
				Tr060Email(RA3->RA3_FILIAL, RA3->RA3_MAT,RA2->RA2_CALEND,RA2->RA2_CURSO,RA2->RA2_TURMA,"R",STR0009,.F.,"1") //"Confirmacao de Treinamento"
				RA2->(dbGoTo(nRecno))
			EndIf
			
			If nCont == RA2->RA2_VAGAS
				Exit
			EndIf
			(cAliasTmp)->(dbSkip())
		EndDo
		(cAliasTmp)->(dbCloseArea())
		
		//atualiza RA2_reserv
		RA2->(dbGoTo(nRecno))
		Reclock("RA2",.F.)
		RA2->RA2_RESERV	:= nCont
		RA2->(MsUnlock()) 
	EndIf
	nCont := 0
Next nI

RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050Ok   ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function M100Ok(n)
Local nPosCurso	:= GdFieldPos("RA2_CURSO")
Local nPosTurma	:= GdFieldPos("RA2_TURMA")
Local nPosDtIni	:= GdFieldPos("RA2_DATAIN")
Local nPosDtFin	:= GdFieldPos("RA2_DATAFI")
Local nPosNrVag	:= GdFieldPos("RA2_VAGAS")
Local nPosCC	:= GdFieldPos("RA2_CC")
Local nPosDtRef	:= GdFieldPos("RA2_DTREF")
Local nx  		:= 0
Local n			:= If(VALTYPE(n)<> "O",n,n:nAt)

	If !aCols[n,Len(aCols[n])]      /// Se nao esta Deletado
		If nPosDtIni > 0 .And. Empty(aCols[n][nPosDtIni])
			Help("",1,"TRA050DTIN")
			Return .F.
		ElseIf nPosNrVag > 0 .And. Empty(aCols[n][nPosNrVag])
			Help("",1,"TRA050NVAG")
			Return .F.
		EndIf
	    If aCols[n][nPosDtIni] > aCols[n][nPosDtFin]
	    	Aviso( OemToAnsi(STR0004),OemToAnsi(STR0008),{"OK"})//"Atenção"#"DAta inicial não pode ser menor que a data final"
	    	Return .F.
	    EndIf
		For nx:=1 To Len(aCols)
			If aCols[n][nPosCurso] == aCols[nx][nPosCurso] .And.;
				aCols[n][nPosTurma] == aCols[nx][nPosTurma] .And.;
			    If(nPosCC > 0,aCols[n][nPosCC] == aCols[nx][nPosCC],.T.) .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n # nx 
				Help(" ",1,"TRA050EXIST")
				Return .F.
				Exit
			EndIf	
		Next nx		
	EndIf	

Return .T. 

Static Function M100Header()
Local nI			:= 1

Local aCampos		:= {;
			{"RA2_FILIAL",,"R","V"},; 
			{"RA2_CURSO",,"R","V"},; 
			{"RA1_DESC",,"V","V"},;
			{"RA2_TURMA",,"R","V"},; 
			{"RA2_ENTIDA"," M100DescEn()","R","A"},;
			{"RA2_DESCEN",,"V","V"},; 
			{"RA2_DATAIN",GetSx3Cache("RA2_DATAIN", "X3_VALID"),"R","A"},;
			{"RA2_DATAFI",GetSx3Cache("RA2_DATAFI", "X3_VALID"),"R","A"},;
			{"RA2_HORARI",GetSx3Cache("RA2_HORARI", "X3_VALID"),"R","A"},;
			{"RA2_DURACA",,,"R","V"},;
			{"RA2_VAGAS",,"R","V"},;
			{"RA2_INSTRU",'ExistCpo("RA7",M->RA2_INSTRU)',"R","A"},;
			{"RA2_LOCAL",,"R","A"},;
			{"RA2_CUSTO",,"R","V"},;
			{"RA2_RESPON",,"R","A"};
}//valid,contexto,visual

For nI := 1 To Len(aCampos)
	aadd(aHeader,{GetSx3Cache(	;
				aCampos[nI][1], "X3_TITULO"),;
				aCampos[nI][1],GetSx3Cache(aCampos[nI][1], "X3_PICTURE"),;
				GetSx3Cache(aCampos[nI][1], "X3_TAMANHO"),; 
				GetSx3Cache(aCampos[nI][1], "X3_DECIMAL"),;
				aCampos[nI][2],;
				GetSx3Cache(aCampos[nI][1], "X3_USADO"),;
				GetSx3Cache(aCampos[nI][1], "X3_TIPO"),;
				GetSx3Cache(aCampos[nI][1], "X3_F3")  ,;
				aCampos[nI][3],;							//Contexto
                "",;									//cBox
                "",;									//Inicializador Padrao
                "",;									//When
                aCampos[nI][4];							//Visual
                })

Next nI

Return .T.

Static Function M100Custo(nLinha)
Local aSaveArea := GetArea()
Local nPosVal	:= GdFieldPos("RA2_CUSTO")
Local nPosEnt	:= GdFieldPos("RA2_ENTIDA")
Local nPosCur	:= GdFieldPos("RA2_CURSO")
Local nPosVag	:= GdFieldPos("RA2_VAGAS")             
If nPosEnt > 0 .And. nPosCur > 0 .And. nPosVal > 0 

	dbSelectArea("RA6")
	RA6->(dbSetOrder(1))
	If RA6->(dbSeek(xFilial("RA6") + aCols[nLinha][nPosEnt] + aCols[nLinha][nPosCur]))
		aCols[nLinha][nPosVal] := RA6->RA6_VALOR * aCols[nLinha][nPosVag]
	Else
		dbSelectArea("RA1")
		RA1->(dbSetOrder(1))
		If RA1->(dbSeek(xFilial("RA1")+aCols[nLinha][nPosCur]))
			aCols[nLinha][nPosVal] := RA1->RA1_VALOR * aCols[nLinha][nPosVag]
		EndIf		
	EndIf
EndIf    

RestArea(aSaveArea)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr050TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a funcao de tudo Ok                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr050TudOk(Expl1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nOpcx - Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function M100Tok()
Local lRet		:= .T.
Local nX		:= 0

For nX:=1 to len(aCols)
	If lRet
		lRet := M100Ok(nX)
	Else
		Exit
	Endif
Next
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada antes da gravacao do Calendario.		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("TRM050GR")
	lRet := ExecBlock("TRM050GR",.F.,.F.,{3})
Endif

Return lRet

Function M100DescEn()
Local nPosDes 	:= GdFieldPos("RA2_DESCEN")
Local nPosCur	 := GdFieldPos("RA2_CURSO")
Local cVar := &(ReadVar())
Local nLinha := oGetDados:nAt
Local cRetorno	:= ""
n:= nLinha
If !Empty(cVar)
	dbSelectArea("RA6")
	dbSetOrder(1)
	If dbSeek(xFilial("RA6") + cVar + aCols[nLinha][nPosCur])
		cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
	Else
		RA6->(dbSetOrder(2))
		If !dbSeek(xFilial("RA6") + aCols[nLinha][nPosCur]) //Caso não haja entidades amarradas ao curso permite informar qualquer uma.
			cRetorno := Posicione("RA0", 1, xFilial("RA0")+cVar, "RA0_DESC")
		EndIf
		RA6->(dbSetOrder(1))
	EndIf
	aCols[nLinha][nPosDes] := cRetorno
EndIf
Return .T.
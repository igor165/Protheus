#INCLUDE "PCOA510.ch"
#INCLUDE "protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA510   ³ Autor ³ Bruno Sobieski        ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para manutecao de limites de aprovacao por usuario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Adaptado em 14/11/07 por Rafael Marin para utilizar tabeças  ³±±
±±³          ³ Padroes (ZU1,ZU2,ZU3,ZU4,ZU6 -> ALI,ALJ,ALK,ALL,ALM)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA510()
PRIVATE cCadastro	:= STR0001 //"Limites de liberadores de verba orcamentaria"
PRIVATE aRotina := MenuDef()			

mBrowse(6,1,22,75,"ALK")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA510DLG³ Autor ³ Bruno Sobieski        ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao principal para montar a tela                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA510DLG(cAlias,nRecno,nOpcX)
Local l020Inclui	:= .F.
Local l020Visual	:= .F.
Local l020Altera	:= .F.
Local l020Exclui	:= .F.
Local lContinua		:= .T.
Local nOpc		    := 0
Local aSize			:= {}
Local aObjects		:= {}                                                            
Local aButtons      := {}
Local aDadosExcel   := {}
Local aInfo         := {}
Local aPosObj       := {}
Local nX			:=	1
Local nI			:=	1
Local aRecAKJ		:=	{}					 
Local oDlg	

Private aTitles		:= { } 
Private aHeaderBlq	:=	{}
Private aColsBlq	:=	{}
Private aHeader		:=	{}
Private aCols		:=	{}
PRIVATE oGD         :=	{}
PRIVATE oEnch
PRIVATE oFolder
PRIVATE aSavN		:=	{}    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case                              
	Case aRotina[nOpcx][4] == 2
		l020Visual := .T.
		Inclui := .F.
		Altera := .F.
	Case aRotina[nOpcx][4] == 3
		l020Inclui	:= .T.
		Inclui := .T.
		Altera := .F.
	Case aRotina[nOpcx][4] == 4
		l020Altera	:= .T.
		Inclui := .F.
		Altera := .T.
	Case aRotina[nOpcx][4] == 5
		l020Exclui	:= .T.
		l020Visual	:= .T.
EndCase

///Tratativa para Dados Protegidos, quando usuario nao tiver acesso a Dados Pessoais
If FindFunction("CTPROTDADO") .AND. !CTPROTDADO()
	Return
Endif

AAdd( aButtons, { "PESQUISA", { || Pco510_Pesq( oGD[oFolder:nOption], oFolder:nOption ) }, "Consulta Padrao", "Consulta Padrao" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as variaveis de memoria ALK                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("ALK",l020Inclui)

A510Header(@aHeaderBlq,@aRecAKJ,@aTitles)
If Len(aRecAKJ) > 0
	A510aCols(If(INCLUI,Nil,ALK_USER),aHeaderBlq,aRecAKJ,aColsBlq)
	aSavN	:=Array(Len(aHeaderBlq))
	aFill(aSavN,1)
	oGD	:=Array(Len(aHeaderBlq))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o cALKulo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize(,.F.,400)
	aObjects := {} 
	
	AAdd( aObjects, { 100, 40  , .T., .F. } )
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	oEnch := MsMGet():New("ALK",ALK->(RecNo()),nOpcx,,,,,aPosObj[1],,3,,,,oDlg,,,,,,.T.)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{},oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oFolder:bSetOption:={|nFolder| A510SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@aColsBlq,@aHeaderBlq,@aSavN,@oGD) }
	For nI := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nI]
	Next	
	
	//AAdd(aDadosExcel,{"ENCHOICE",cCadastro,oEnch:aGets,oEnch:aTela})
	
	For nI := 1 To Len(oFolder:aDialogs)
		oFolder:aDialogs[nI]:oFont := oDlg:oFont
		aHeader		:= aClone(aHeaderBlq[nI])
		aCols		:= aClone(aColsBlq[nI])
		oGD[nI]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"AllwaysTrue","AllwaysTrue","+ALL_ITEM",.T.,,1,,990,,,,,oFolder:aDialogs[nI])

		oGD[nI]:oBrowse:bDrawSelect	:= {|| A510BlqCols(@aHeaderBlq,@aColsBlq,@aSavN,oFolder:nOption)}                                                 
		AAdd(aDadosExcel,&('{"GETDADOS",aTitles['+Alltrim(Str(nI))+'],aHeaderBlq['+Alltrim(Str(nI))+'],aColsBlq['+Alltrim(Str(nI))+']}'))
		oGD[nI]:oBrowse:lDisablePaint := .T.
	Next nI                 
	aHeader		:= aClone(aHeaderBlq[1])
 	aCols		:= aClone(aColsBlq[1])
	oGD[1]:oBrowse:lDisablePaint := .F.	
	//aButtons := AddToExcel(aButtons,{	aDadosExcel } )
	
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(	Obrigatorio(oEnch:aGets,oEnch:aTela).And.;
															A510BlqCols(@aHeaderBlq,@aColsBlq,@aSavN,oFolder:nOption) .And.;		
															Eval({|| lOk:=.T., aEval(oGD,{|cValue,nY| If(lOk,lOk := AGDTudok(aSavN,aColsBlq,aHeaderBlq,nY,@oGD),Nil)}),lOk});
															,(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
	
	If nOpc == 1 .And. (l020Inclui.Or.l020Exclui.Or.l020Altera)
		Begin Transaction
		PCOA510GRV(aColsBlq,aHeaderBlq,aRecAKJ,l020Inclui,l020Exclui,l020Altera)	
		End Transaction                                              
	Endif	
Else
	Aviso(STR0007,STR0008,{'Ok'}) //'Aviso'###'Nao existe nenhum bloqueio para cadastrar os limites'
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A510Header³ Autor ³ Bruno Sobieski        ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montar aheaders dos bloqueios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function A510Header(aHeaderBlq,aAKJ,aTitles)
Local nX
Local aHeaderPre	:=	{}
Local aHeaderPos	:=	{}
Local cCampo
Local nPosFim                      
Local cChave
Local nPosH
aAKJ		:=	{}
aHeaderBlq	:=	{}
aTitles		:= { } 
       
DbSelectArea("SX3")
DbSetOrder(1)
dbSeek("ALL")        
While !EOF() .And. (x3_arquivo == "ALL")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel 
	
		If AllTrim(X3_CAMPO) == "ALL_ITEM"
			AADD(aHeaderPre,{ 	TRIM(x3titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})
        Else
			AADD(aHeaderPos,{ 	TRIM(x3titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})

		Endif
	Endif
	dbSkip()
End

//campos VIRTUAIS de acordo com configuracao do cubo
dbSelectArea("SX3")
dbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem dos aHeaders para cada configuracao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AL3->(dbSetOrder(1))
AKW->(dbSetOrder(1))
DbSelectArea('AKJ') 
DbSetOrder(1)     
DbSeek(xFilial())
While !Eof().And. AKJ_FILIAL == xFilial()
	AAdd(aHeaderBlq,{})      
	AAdd(aAKJ,AKJ_COD)
	AAdd(aTitles,Alltrim(AKJ_DESCRI)+" ("+AKJ_COD+")")
	nPosH	:=	Len(aHeaderBlq) 
	For nX:= 1 To Len(aHeaderPre)
		Aadd(aHeaderBlq[nPosH],aHeaderPre[nX])
	Next
	//Incluir os campos do cubo
	AL3->(DbSeek(xFilial()+AKJ->AKJ_REACFG) )
	If AKW->(DbSeek(xFilial()+AL3->AL3_CONFIG+AKJ->AKJ_NIVRE) )
		cChave	:= Alltrim(AKW->AKW_CONCCH)	                                 
		cChave	:=	StrTran(cChave,"AKD->","")
		While Len(cChave) > 0
			nPosFim	:=	At("+",cChave)
			If nPosFim == 0 
				nPosFim	:=	Len(cChave)+1
			Endif	
			cCampo	:=	Substr(cChave,1,nPosFim-1)
		    If SX3->(dbSeek(TRIM(cCampo)))        
		    	For nX := 1 To 2
					AADD(aHeaderBlq[nPosH],{ 	TRIM(x3titulo())+If(nX==1,STR0009, STR0010),; //" de"###" ate"
								If(nX==1,"_DE", "ATE")+Substr(SX3->X3_CAMPO,4),; 
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								"",;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_F3,;
								SX3->X3_CONTEXT,;
								SX3->X3_CBOX,;
								SX3->X3_RELACAO,;
								SX3->X3_WHEN})
				Next
			Endif
			cChave	:=	Substr(cChave,nPosFim+1)	
		Enddo
	Endif
	For nX:= 1 To Len(aHeaderPos)
  		Aadd(aHeaderBlq[nPosH],aHeaderPos[nX])
	Next
	DbSelectArea('AKJ')	
	DbSkip()
Enddo	

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A510aCols ³ Autor ³ Bruno Sobieski        ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para preencher aCols                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function A510aCols(cUsuario,aHeaderBlq,aAKJ,aColsBlq)
Local nX,nY
Local nPos := 1                                         
Local nPosCol
aColsBlq	:=	{}       

For nY:=1 To Len(aAKJ)  
	AAdd(aColsBlq,{}) 
	If cUsuario <> Nil
		DbSelectArea('ALL') 
		DbSetOrder(1)                                   
		DbGoTop()
		DbSeek(xFilial()+cUsuario+aAKJ[nY])
		While ALL_FILIAL == xFilial() .And. ALL_USER+ALL_CODBLQ == cUsuario+aAKJ[nY]
			nPos	:=	1
			AAdd(aColsBlq[Len(aColsBlq)],Array(Len(aHeaderBlq[nY])+1))
			nPosCol	:= Len(aColsBlq[Len(aColsBlq)])
			For nX:=1 To Len(aHeaderBlq[nY])  
				If Substr(aHeaderBlq[nY,nX,2],1,3) == "_DE"  
					aColsBlq[nY,nPosCol,nX]	:=	Substr(ALL->(FieldGet(FieldPos('ALL_CODINI'))),nPos,aHeaderBlq[nY,nX,4])
				ElseIf Substr(aHeaderBlq[nY,nX,2],1,3) == "ATE" 
					aColsBlq[nY,nPosCol,nX]	:=	Substr(ALL->(FieldGet(FieldPos('ALL_CODFIM'))),nPos,aHeaderBlq[nY,nX,4])
					nPos	+= aHeaderBlq[nY,nX,4]
				Else		   
					aColsBlq[nY,nPosCol,nX]	:=	ALL->(FieldGet(FieldPos(aHeaderBlq[nY,nX,2])))
				Endif	
			Next nX	             

			aColsBlq[nY,nPosCol,nX]	:=	.F.
			DbSelectArea('ALL')	
			DbSkip()
		Enddo
	Endif
	If Empty(aColsBlq[Len(aColsBlq)])
		AAdd(aColsBlq[Len(aColsBlq)],Array(Len(aHeaderBlq[nY])+1))
    	For nX:=1 To Len(aHeaderBlq[nY])
    		If Substr(aHeaderBlq[nY,nX,2],1,3) == "_DE" .Or. Substr(aHeaderBlq[nY,nX,2],1,3) == "ATE"
				aColsBlq[nY,1,nX]	:= Space(aHeaderBlq[nY,nX,4])
			ElseIf Alltrim(aHeaderBlq[nY,nX,2]) == "ALL_ITEM"
				aColsBlq[nY,1,nX]	:= StrZero(1,aHeaderBlq[nY,nX,4])
			Else
				aColsBlq[nY,1,nX]	:= CriaVar(aHeaderBlq[nY,nX,2])
			Endif    	  				
    	Next		                                          
   		aColsBlq[nY,1,nX]	:=	.F.
	Endif
Next nY	

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A510BlqCols³ Autor ³ Bruno Sobieski       ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manipula os acols                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A510BlqCols(aHeaderBlq,aColsBlq,aSavN,nGetDados)

If nGetDados <= Len(aHeaderBlq) .And. !Empty(aHeaderBlq[nGetDados])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsBlq[nGetDados]		:= aClone(aCols)
	aHeaderBlq[nGetDados]	:= aClone(aHeader)
	aSavN[nGetDados]		:= n
	
	aCols			:= aColsBlq[nGetDados]
	aHeader			:= aHeaderBlq[nGetDados]
	n      			:= aSavN[nGetDados]
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A51SetOption³ Autor ³ Bruno Sobieski     ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCOA510                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A510SetOption(nFolder,nOldFolder,aCols,aHeader,aColsBlq,aHeaderBlq,aSavN,oGD)
           
If nOldFolder <= Len(aHeaderBlq) .And. !Empty(aHeaderBlq[nOldFolder])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsBlq[nOldFolder]		:= aClone(aCols)
	aHeaderBlq[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint	:= .T.	
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderBlq) .And. !Empty(aHeaderBlq[nFolder])
	oGD[nFolder]:oBrowse:lDisablePaint	:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o conteudo da GetDados se existir           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols	:= aClone(aColsBlq[nFolder])
	aHeader := aClone(aHeaderBlq[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
	nGDAtu	:= nFolder
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGdTudoK³ Autor ³ Bruno Sobieski          ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
±±³          ³ TudOk da GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(aSavN,aColsBlq,aHeaderBlq,nGetDados,oGD)
Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n             
Local lRet			:=	.T.
Local nX			:=	0
Local nY			:=	0

Eval(oFolder:bSetOption)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.
         
aCols	:= aClone(aColsBlq[nGetDados])
aHeader	:= aClone(aHeaderBlq[nGetDados])
n		:= aSavN[nGetDados]
oFolder:nOption	:= nGetDados
//TODO:
//
//Incluir validacao para cada GetDados          
For nX := 1 To Len(aCols)
	For nY:=1 To Len(aHeader)
		If (Substr(aHeader[nY,2],1,3) == "_DE" .Or. Substr(aHeader[nY,2],1,3) == "ATE") .And. !Empty(aCols[nX,nY])
			If !MaCheckCols(aHeader,aCols,nX)
				lRet	:=	.F.
			Endif
			Exit  //nY
		Endif		
	Next	
	If !lRet
		Exit
	Endif	
Next
aColsBlq[nGetDados]		:= aClone(aCols)
aHeaderBlq[nGetDados]	:= aClone(aHeader)

If nGetDados != oFolder:nOption
	aCols	:= aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		:= nSavN
EndIf

Return lRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA510GRV³ Autor ³ Bruno Sobieski        ³ Data ³ 05-03-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravar os dados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOA510GRV(aColsBlq,aHeaderBlq,aAKJ,lInclui,lDeleta,lAltera)
Local cChaveIni	:=	""
Local cChaveFim	:=	""
Local nPosIt:=	0
Local nPos	:=	1
Local nZ	:=	1
Local nX	:=	1
Local nY	:=	1
Local aALL	:=	{}
Local bCampo 	:= {|n| FieldName(n) }

If lAltera .Or. lInclui
	//Gravar Cabecalho
	If lAltera
		RecLock("ALK",.F.)
	Else
		RecLock("ALK",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx                                                                
	ALK->ALK_FILIAL := xFilial("ALK")
	MsUnLock()
	//Gravar itens
	For nX:= 1 To Len(aAKJ)
		aALL	:=	{}	
		//Carrega os dados ja gravados para este bloqueio
		DbSelectArea('ALL')
		DbSetOrder(1)
		DbSeek(xFilial()+ALK->ALK_USER+aAKJ[nX])
		While !Eof() .And. xFilial()+ALK->ALK_USER+aAKJ[nX] == ALL_FILIAL+ALL_USER+ALL_CODBLQ
			AAdd(aALL,Recno())
			DbSkip()
		Enddo
		//Percorre o aCols para este bloqueio
		For nY	:=	1	To Len(aColsBlq[nX])	
			nPos	:=	1
			//Verificar se esta deletado
			If !aColsBlq[nX,nY,Len(aColsBlq[nX,nY])]
				lContinua	:=	.F.
				//Verificar se foi preenchido algum campo de filtro antes de continuar com a gravacao do item
				For nZ:=1 To Len(aHeaderBlq[nX])
					If (Substr(aHeaderBlq[nX,nZ,2],1,3) == "_DE" .Or. Substr(aHeaderBlq[nX,nZ,2],1,3) == "ATE") .And. !Empty(aColsBlq[nX,nY,nZ])
						lContinua	:=	.T.
						Exit
		            Endif
		        Next
		        If lContinua    
					If lAltera
						DbSelectArea('ALL')
						DbSetOrder(1)
						If DbSeek(xFilial()+ALK->ALK_USER+aAKJ[nX]+aColsBlq[nX,nY,1])
							nPosIt	:=	Ascan(aALL,Recno())
							aDel(aALL,nPosIt)
							aSize(aALL,Len(aALL)-1)
							RecLock('ALL',.F.)
						Else
						   RecLock('ALL',.T.)
						Endif   
					Else
					   RecLock('ALL',.T.)
					Endif
					cChaveIni	:=	""
					cChaveFim	:=	""                                                     
					//Grava Campo a Campo
					For nZ	:=	1	To Len(aHeaderBlq[nX])	
						If Substr(aHeaderBlq[nX,nZ,2],1,3) == "_DE"  
							cChaveIni	+=	aColsBlq[nX,nY,nZ]
						ElseIf Substr(aHeaderBlq[nX,nZ,2],1,3) == "ATE"
							cChaveFim	+=	aColsBlq[nX,nY,nZ]
						Else		   
							ALL->(FieldPut(FieldPos(aHeaderBlq[nX,nZ,2]),aColsBlq[nX,nY,nZ]))
						Endif	
					Next nZ
					ALL_FILIAL := xFilial("ALL")
					ALL_CODINI	:=	cChaveIni						
					ALL_CODFIM	:=	cChaveFim						
					ALL_USER	:=	ALK->ALK_USER						
					ALL_CODBLQ	:=	aAKJ[nX]						
	                MsUnLock()
				Endif
			Endif
		Next nY	
		For nZ	:=	1 To Len(aALL)
			ALL->(MsGoto(aALL[nZ]))	
			RecLock('ALL',.F.)  
			DbDelete()
			MsUnLock()
		Next nZ	
	Next nX
ElseIf lDeleta      
	For nX:= 1 To Len(aAKJ)
		aALL	:=	{}	
		//Carrega os dados ja gravados para este bloqueio
		DbSelectArea('ALL')
		DbSetOrder(1)
		DbSeek(xFilial()+ALK->ALK_USER+aAKJ[nX])
		While !Eof() .And. xFilial()+ALK->ALK_USER+aAKJ[nX] == ALL_FILIAL+ALL_USER+ALL_CODBLQ
			AAdd(aALL,Recno())
			DbSkip()
		Enddo
		For nZ	:=	1 To Len(aALL)
			ALL->(MsGoto(aALL[nZ]))
			RecLock('ALL',.F.)  
			DbDelete()
			MsUnLock()
		Next nZ	
	Next nX     
	RecLock('ALK',.F.)
	DbDelete()
	MsUnLock()	                 
Endif

Return

Static Function Pco510_Pesq(oGdALL, nI)
Local nLinGd := oGdALL:oBrowse:nAt
Local nPosCpo := oGdALL:oBrowse:ColPos()

If Left(aHeaderBlq[nI,nPosCpo,2],3) == "_DE" .Or. Left(aHeaderBlq[nI,nPosCpo,2],3) == "ATE" 
	If !Empty(aHeaderBlq[nI,nPosCpo,9])
		If ConPad1( , , , aHeaderBlq[nI,nPosCpo,9] , , , .F. )
			aCols[nLinGd, nPosCpo] := Pco510RetPad(aHeaderBlq[nI,nPosCpo,9])
		EndIf	
	EndIf
Else
	Help( " ", 1, "PCO510PESQ",, STR0011, 1, 0 ) //""Esta consulta padrão deve ser utilizada nos campos de Contas Orçamentárias no Grid do Cadastro de Limites de Aprovação." "
EndIf

Return 

Static Function Pco510RetPad(cAlias)
Local aArea := GetArea()
Local aAreaSXB := SXB->(GetArea())
Local xRetorno

dbSelectArea("SXB")
dbSetOrder(1)
If dbSeek(PadR(cAlias, Len(SXB->XB_ALIAS))+"5")
	xRetorno := &(SXB->XB_CONTEM)
EndIf

RestArea(aAreaSXB)
RestArea(aArea)

Return(xRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  ºAutor  ³ Pedro Pereira Lima º Data ³  09/28/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002  	,"AxPesqui"   , 0 , 1},;  //"Pesquisar"
							{ STR0003 	,"PCOA510DLG" , 0 , 2},; //"Visualizar"
							{ STR0004	,"PCOA510DLG" , 0 , 3},; //"Incluir"
							{ STR0005 	,"PCOA510DLG" , 0 , 4},; //"Modificar"
							{ STR0006	,"PCOA510DLG" , 0 , 5 }}  //"Excluir"

Return aRotina
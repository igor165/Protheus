#INCLUDE  "TOTVS.CH"
#INCLUDE  "QDOA053.CH"
#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "COLORS.CH"
#INCLUDE  "FONT.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA053    ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Destinatarios                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA053()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQDO                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS  ³Programador³Alteracao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18/04/02³ xxxxx ³Eduardo S. ³Melhoria, Otimizacao e alterado para utilizar o no³±±
±±³        ³       ³           ³vo conceito de arquivos de Usuarios/Funcoes/Depto.³±±
±±³18/08/02³ xxxxx ³Eduardo S. ³Acerto para carregar todos departamentos/filiais. ³±±
±±³18/08/02³ Ficha ³Eduardo S. ³Acerto para carregar corretamente os destinatarios³±±
±±³04/12/02³ xxxxx ³Eduardo S. ³ Alterado para apresentar somente as pastas da    ³±±
±±³        ³       ³           ³ filial do departamento selecionado.              ³±±
±±³08/01/03³ ----- ³Eduardo S. ³ Alterado para permitir pesquisar usuarios de ou- ³±±
±±³        ³       ³           ³ tras filiais na inclusao de destinatarios.       ³±±
±±³23/01/03³ Meta  ³Eduardo S. ³ Inclusao da opcao "Copia Destino" utilizado para ³±±
±±³        ³       ³           ³ copia o destino de um docto existente.           ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA053(nOpc,lAltDoc)

Local aAuxQDJDoc  := aClone(aQDJDoc)
Local aCargos     := {}
Local aDeptos     := {}
Local aQDG        := {}
Local aQDGFt      := {}
Local lAlter      := If(lAltDoc == NIL, .T., lAltDoc)
Local lFiltro     := .F.
Local oBtn1       := Nil 
Local oBtn3       := Nil
Local oBtn4       := Nil
Local oBtn5       := Nil
Local oBtn6       := Nil
Local oBtn7       := Nil
Local oBtn8       := Nil
Local oBtn9       := Nil
Local oDlg        := Nil
Local oNo         := LoadBitmap( GetResources(), "LBNO" )
Local oOk         := LoadBitmap( GetResources(), "ENABLE" )

Private bQDGFLin  := {}
Private bQDGLine1 := {}
Private bQDGLine2 := {}
Private bQDJLine1 := {}
Private bQDJLine2 := {}
Private cCadastro := ""
Private cCodMat   := Space(Len(QAA->QAA_MAT))
Private cFilDep   := xFilial("QAD")
Private cFilMat   := cFilAnt
Private lAltQDJ   := .F.
Private lCarHab   := GetMV("MV_QDCARGO",.F.,"1") == "1" //No Documento permite a Escolha dos Destinarios por cargo 1=SIM/2=NAO
Private nOpca     := 0
Private nQaConPad := 4
Private oGet      := Nil
Private oQDG      := Nil
Private oQDJ      := Nil

If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)
   Return .F.
EndIf

If nOpc == 2 .Or. nOpc == 5
   lAlter:= .F.
EndIf

QD53CarDep(@aDeptos)                

MsgRun(OemToAnsi(STR0017),OemToAnsi(STR0031),{|| QD053LeQDJ(@aDeptos)}) // "Carregando Destinatarios do Documento..." ### "Aguarde..."


oSize := FwDefSize():New()            
oSize:AddObject( "DEPARTAMENTO"  ,  100, 50, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "DESTINATARIO"  ,  100, 50, .T., .T. ) // Totalmente dimensionavel	

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() 	   // Dispara os calculos 
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001); //"Cadastro de Destinatários"
				FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL                                      

@ oSize:GetDimension("DEPARTAMENTO","LININI") ,oSize:GetDimension("DEPARTAMENTO","COLINI") TO ;
		oSize:GetDimension("DEPARTAMENTO","LINEND"), oSize:GetDimension("DEPARTAMENTO","COLEND") LABEL OemToAnsi(STR0002)  OF oDlg  PIXEL //" Departamentos "
		
@ oSize:GetDimension("DEPARTAMENTO","LININI")+7,oSize:GetDimension("DEPARTAMENTO","COLINI")+3 BUTTON oBtn1 PROMPT OemToAnsi(STR0002) SIZE 050,011 OF oDlg PIXEL; // "Departamentos"
				ACTION If(QD53Destino(@aCargos,@aDeptos),MsgRun(OemToAnsi(STR0013),OemToAnsi(STR0031),;
							{|| QD053LeQDJ(@aDeptos),QD53AtArray(oQDJ:nAt)}),) // "Atualizando Informacoes..." ### "Aguarde..."
If !lAlter
	oBtn1:Disable()
EndIf
				
@ oSize:GetDimension("DEPARTAMENTO","LININI")+7,oSize:GetDimension("DEPARTAMENTO","COLINI")+55 BUTTON oBtn4 PROMPT OemToAnsi(STR0012) SIZE 050,011 OF oDlg PIXEL; // "Pesquisa Depto"
				ACTION If(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0,QD53PesqDep(aQDJDoc,1),)


@ oSize:GetDimension("DEPARTAMENTO","LININI")+7,oSize:GetDimension("DEPARTAMENTO","COLINI")+107 BUTTON oBtn7 PROMPT OemToAnsi(STR0033) SIZE 050,011 OF oDlg PIXEL; // "Copia Destino"
				ACTION If(Len(aQDJDoc)==0,QD53CopDest(@aDeptos),;
										Help(" ",1,"QDJAEDEST")) // "Nao sera possivel copiar destinos, pois ja" ### "existem Destinos cadastrados."
If !lAlter
	oBtn7:Disable() 
EndIf

@ oSize:GetDimension("DEPARTAMENTO","LININI")+20,oSize:GetDimension("DEPARTAMENTO","COLINI")+3 LISTBOX oQDJ FIELDS;
           HEADER  TitSx3("QDJ_TIPO")[1],;
                   TitSx3("QDJ_FILMAT")[1],;
                   TitSx3("QDJ_DEPTO")[1],;
                   TitSx3("QDJ_NDEPTO")[1];
           SIZE oSize:GetDimension("DEPARTAMENTO","XSIZE")-6,oSize:GetDimension("DEPARTAMENTO","YSIZE")-23 OF oDlg PIXEL

bQDJLine1 := { || { aQDJDoc[oQDJ:nAt,7],aQDJDoc[oQDJ:nAt,4],aQDJDoc[oQDJ:nAt,5],aQDJDoc[oQDJ:nAt,8]}}
bQDJLine2 := { || { Space( 15 ), Space( 2 ), Space( 6 ), Space( 40 ) } }
oQDJ:SetArray( aQDJDoc )
If Len(aQDJDoc) > 0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0
	oQDJ:bLine := bQDJLine1
Else
	oQDJ:bLine := bQDJLine2	
Endif

oQDJ:SetFocus(.t.)
oQDJ:Refresh()

@ oSize:GetDimension("DESTINATARIO","LININI") ,oSize:GetDimension("DESTINATARIO","COLINI") TO ; //" Departamentos "
		oSize:GetDimension("DESTINATARIO","LINEND")-9, oSize:GetDimension("DESTINATARIO","COLEND") LABEL OemToAnsi(STR0002)  OF oDlg  PIXEL 

@ oSize:GetDimension("DESTINATARIO","LININI")+7,oSize:GetDimension("DESTINATARIO","COLINI")+3 BUTTON oBtn5 PROMPT OemToAnsi(STR0029) SIZE 067,011 OF oDlg PIXEL ; //"Marcar/Desmarcar todos"
				ACTION (If(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0,(QD053MRcbT(@aQDJDoc[oQDJ:nAT,9]),oQDG:SetArray(aQDJDoc[oQDJ:nAT,9]),oQDG:bLine:=bQDGLine1),oQDG:bLine:=bQDGLine2),oQDG:Refresh(),lFiltro:=.F.)
If !lAlter
	oBtn5:Disable()
EndIf

@ oSize:GetDimension("DESTINATARIO","LININI")+7,oSize:GetDimension("DESTINATARIO","COLINI")+72 BUTTON oBtn3 PROMPT OemToAnsi(STR0030) SIZE 050,011 OF oDlg PIXEL ; //"Editar Usuario"
      		 ACTION ( IF(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0, QD053AlDst(@aQDJDoc[oQDJ:nAt,9],oQDG:nAt,@aQDGFt,lFiltro),""))
If !lAlter
	oBtn3:Disable()
EndIf

@ oSize:GetDimension("DESTINATARIO","LININI")+7,oSize:GetDimension("DESTINATARIO","COLINI")+124 BUTTON oBtn6 PROMPT OemToAnsi(STR0008) SIZE 050,011 OF oDlg PIXEL; //"Pesquisa Usuario"
				ACTION ( IF(!lFiltro,(If(Len(aQDJDoc)>0,QD53PesqUsr(aQDJDoc[oQDJ:nAt,9],aQDJDoc[oQDJ:nAt,6]),"")),;
							(If(Len(aQDJDoc)>0,QD53PesqUsr(aQDGFt,aQDJDoc[oQDJ:nAt,6]),""))))
				
				

@ oSize:GetDimension("DESTINATARIO","LININI")+7,oSize:GetDimension("DESTINATARIO","COLINI")+176 BUTTON oBtn8 PROMPT OemToAnsi(STR0039) SIZE 030,011 OF oDlg PIXEL ;  //"Legenda"
				ACTION QD053Legen()

@ oSize:GetDimension("DESTINATARIO","LININI")+7,oSize:GetDimension("DESTINATARIO","COLINI")+208 BUTTON oBtn9 PROMPT OemToAnsi(STR0048) SIZE 050,011 OF oDlg PIXEL ;   //"Filtrar Marcados"
				ACTION ( IF(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0,QD053FtMRc(aClone(aQDJDoc[oQDJ:nAt,9]),@aQDGFt,@lFiltro),))				

@ oSize:GetDimension("DESTINATARIO","LININI")+20,oSize:GetDimension("DESTINATARIO","COLINI")+3 LISTBOX oQDG FIELDS;
           HEADER  " ",;
                   TitSx3("QDG_TPRCBT")[1],;
                   OemToAnsi(STR0004),;                        // " Usu rios/Pastas "
                   TitSx3("QDG_NCOP")[1];
           SIZE    oSize:GetDimension("DEPARTAMENTO","XSIZE")-6,oSize:GetDimension("DEPARTAMENTO","YSIZE")-32 OF oDlg PIXEL ;
           ON DBLCLICK   ( IF (lAlter,QD053DBLcl(lFiltro,@aQDGFt),.t.) )
          
bQDGLine1 := { || { If( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 9 ] == "S" ,QD053MRLed(oQDG:nAt,aQDJDoc[oQDJ:nAt,9]), oNo ),;
                    QDXFNDsDtr( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 8 ] ),;
                    If( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 10 ] == "D", ( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 06 ]+" - "+ aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 13 ] ), ( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 13 ]+" - "+ aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 14 ] ) ),;
                    TRANSFORM( aQDJDoc[oQDJ:nAt,9][ oQDG:nAt, 7 ], "@E 9,999" ) } }

//Bline do Filtro
bQDGFLin  := { || { If( aQDGFt[ oQDG:nAt, 9 ] == "S" ,QD053MRLed(oQDG:nAT,aQDGFt), oNo ),;
                    QDXFNDsDtr( aQDGFt[ oQDG:nAt, 8 ] ),;
                    If( aQDGFt[ oQDG:nAt, 10 ] == "D", ( aQDGFt[ oQDG:nAt, 06 ]+" - "+ aQDGFt[ oQDG:nAt, 13 ] ), ( aQDGFt[ oQDG:nAt, 11 ]+" - "+ aQDGFt[ oQDG:nAt, 14 ] ) ),;
                    TRANSFORM( aQDGFt[ oQDG:nAt, 7 ], "@E 9,999" ) } }

bQDGLine2 := { || { oNo, Space(10), Space( 40 ), TRANSFORM( 0,"@E 9,999" ) } }
If Len(aQDJDoc) > 0 .And. Len(aQDJDoc[oQDJ:nAT,9]) > 0
	oQDG:SetArray( aQDJDoc[oQDJ:nAt,9] )
	oQDG:bLine:= bQDGLine1
Else
	oQDG:bLine:= bQDGLine2
Endif	

QD53AtArray(oQDJ:nAt)
oQDJ:bChange:={||(oQDG:SetArray(If(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0,aQDJDoc[oQDJ:nAt,9],{})),oQDG:bLine:= If(Len(aQDJDoc)>0 .And. Len(aQDJDoc[oQDJ:nAt,9])>0,bQDGLine1,bQDGLine2),oQDG:GoTop(),oQDG:Refresh(),lFiltro:=.F.)}
oQDG:cToolTip := OemToAnsi(STR0005)	//	"Duplo click para Habilitar/Desabilitar destinat rio"
oQDG:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| aQDJDoc:=aClone(aAuxQDJDoc),oDlg:End()})

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053LeQDJ ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Carrega os lancamentos dos Departamentos Destinatarios            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053LeQDJ(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array onde sera armazenado os Lactos dos Deptos dos Dest. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053LeQDJ(aDeptos)

Local cFilDep:= xFilial("QAD")
Local nPos1  := 0
Local nPos2  := 0
Local nT     := 1             
Local cFilCar:= xFilial("QAC")

//1 - QDJ->QDJ_FILIAL
//2 - QDJ->QDJ_DOCTO
//3 - QDJ->QDJ_RV
//4 - QDJ->QDJ_FILMAT
//5 - QDJ->QDJ_DEPTO
//6 - QDJ->QDJ_TIPO,
//7 - Descricao Tipo do Usuario
//8 - Descricao do Depto

For nT := 1 to Len(aQDJDoc)
   	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))	
   		cFilDep := aQDJDoc[nT,4]
   	EndIf
	If aQDJDoc[nT,6]== "D"
		If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == cFilDep+aQDJDoc[nT,5]} )) > 0
			aDeptos[nPos,1]:= "S"
			aDeptos[nPos,5]:= "S"
		Endif                             		
	Else
		If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == cFilDep+aQDJDoc[nT,5]} )) > 0
			aDeptos[nPos,1]:= "S"
			aDeptos[nPos,6]:= "S"
		Endif
	EndIf		
Next

For nT := 1 to Len(aDeptos)
	If aDeptos[nT,5]== "N" .And. aDeptos[nT,6]== "N"
		aDeptos[nT,1]:= "N"
	Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053MdRcb ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Atualiza os lancamentos dos destinatarios                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053MdRcb( ExpA1, ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1-Array contendo os lancamentos dos destinatarios             ³±±
±±³           ³ ExpN1-Numero da posicao atual do array de destinatarios           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053MdRcb(aQDG,nPos)

If Len( aQDG ) > 0
   	aQDG[nPos,9 ]:= If(aQDG[nPos,9] == "S","N","S")
	If aQDG[nPos,9] == "S" .And.  aQDG[nPos,12] == "I"
		aQDG[nPos,12]:= " "
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053AtQDG ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a gravacao dos Lancamentos dos destinatarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053AtQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD053AtQDG(aDeptos,nCnt,cTipo,cFilMat,aCargos)

Local aArea     := GetArea()
Local aQDGRet   := {}
Local cAliasQry := GetNextAlias()
Local cFilCar   := xFilial("QAC")
Local cFilDep   := xFilial("QAD")
Local cFilQDC   := ""
Local cMarca    := "S"
Local cMat      := Space(06)
Local lDepxPst  := .F.
Local lQacComp  := FWModeAccess("QAC")=="C" //Empty(xFilial("QAC")) //QAC - Compartilhado
Local lQadComp  := FWModeAccess("QAD")=="C" //Empty(xFilial("QAD")) //QAD - Compartilhado
Local nIndDoc   := 1
Local nIndQDJ   := 1
Local nPosCar   := 0
Local nPosCDep  := 0
Local nPosMat   := 0
Local nQdcRecno := 0

Default aQDJDoc := {}
Default nCnt    := 0

//Array aQDGDoc
// 1 - QDG->QDG_FILIAL
// 2 - QDG->QDG_DOCTO
// 3 - QDG->QDG_RV
// 4 - QDG->QDG_FILMAT
// 5 - QDG->QDG_DEPTO
// 6 - QDG->QDG_MAT
// 7 - QDG->QDG_NCOP,
// 8 - QDG->QDG_TPRCBT
// 9 - QDG->QDG_RECEB
//10 - QDG->QDG_TIPO
//11 - QDG->QDG_CODMAN
//12 - QDG->QDG_SIT,
//13 - cNomUsr,
//14 - QDXFNANMAN(QDG->QDG_CODMAN,.T.,If(!Empty(xFilial("QDC")),QDG->QDG_FILMAT,))

QAA->( DbSetOrder(2))                
QAD->( DbSetOrder(1))
QDC->( DbSetOrder(1))
QDT->( DbSetOrder(1))

If aDeptos[nCnt,5] == "S" .And. cTipo == "D" //-- Deptos
   	If !lQadComp
		cFilMat:= aDeptos[nCnt,2]
	Endif                 

	cQuery :="SELECT DISTINCT QAA.QAA_FILIAL,QAA.QAA_MAT,QAA.QAA_NOME,QAA.QAA_CODFUN,QAA.QAA_CC,QAA.QAA_TPRCBT "
	cQuery +="  FROM " + RetSqlName("QAA")+" QAA "
	If lQadComp
		cQuery +="	INNER JOIN " + RetSqlName("QAD")+" QAD ON QAD.QAD_CUSTO = QAA.QAA_CC
		cQuery +="	AND QAD.R_E_C_N_O_ = " + cValToChar(aDeptos[nCnT,7]) "
	EndIf
	cQuery +=" WHERE "
	cQuery +="       QAA.QAA_FILIAL='"+cFilMat+"' AND "			
	cQuery +="       QAA.QAA_CC='"+aDeptos[nCnT,3]+"' AND "
	cQuery +="       QAA.QAA_TPRCBT <> '4' AND "         				
	cQuery +=        QA_FilSitF(.T.,.T.) + " AND "
	cQuery +="       QAA.D_E_L_E_T_ <> '*' AND "
	cQuery +="       QAA.QAA_STATUS <> '2'" 

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1"
	Else
		cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL")
	Endif
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

	DbGotop()
	IF TMPQAA->(!Eof())			
		While TMPQAA->(!Eof())
			cMarca:="S"     
		    IF (nPosCar:=Ascan(aCargos,{|x| x[2]+x[3]==If(lQacComp,cFilCar,TMPQAA->QAA_FILIAL)+TMPQAA->QAA_CODFUN}) ) > 0 
		    	IF aCargos[nPosCar,1]=="N"
					cMarca:="N"
				ElseIF aCargos[nPosCar,1]=="P"						
					IF (nPosCDep:=Ascan(aCargos[nPosCar,5],{|x| IF(lQadComp,x[2]==aDeptos[nCnt,3],x[1]+x[2]==cFilMat+aDeptos[nCnt,3])}) ) > 0 
						IF aCargos[nPosCar,5,nPosCDep,3]=="N"
							cMarca:="N"
						Endif
					Else
						cMarca:="N"     					
					Endif
				Endif
			Else
				cMarca:="N"           
			Endif

			//Verifica se já existe o responsável na grid para manter a seleção.
			For nIndQDJ := 1 to Len(aQDJDoc)
				For nIndDoc := 1 to len(aQDJDoc[nIndQDJ][9])
					nPosMat := aScan(aQDJDoc[nIndQDJ][9],{|x| x[1]+x[2]+x[3]+x[4]+x[6] == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cFilMat+TMPQAA->QAA_MAT})
					If nPosMat > 0
						cMarca := aQDJDoc[nIndQDJ][9][nPosMat][9]
					EndIf
				Next nIndDoc
			Next nIndQDJ

			aAdd(aQDGRet,{M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,;
				cFilMat,aDeptos[nCnt,3],;
				TMPQAA->QAA_MAT,1,IF(Empty(TMPQAA->QAA_TPRCBT),"4",TMPQAA->QAA_TPRCBT),cMarca,"D"," "," ",TMPQAA->QAA_NOME," ",TMPQAA->QAA_CODFUN})
     		TMPQAA->(DbSkip())                         
       Enddo
	Endif	         			
	TMPQAA->(DbCLOSEAREA())	
	RestArea(aArea)									

	aQDGRet:= aSort( aQDGRet,,,{ |x,y| x[13] + x[6]+ x[14] + x[11] < y[13] + y[6] + y[14] + y[11] } ) 

Endif

If aDeptos[nCnt,6] == "S" .And. cTipo == "P"	//-- Pastas

	cFilQDC:= xFilial("QDC")
    If FWModeAccess("QDC")=="E" .And. FWModeAccess("QAD")=="E" //!Empty(cFilQDC) .And. !Empty(xFilial("QAD"))
    	cFilQDC:= aDeptos[nCnt,2]
    EndIf
    	
	QDG->(DbSetOrder(2))	
	QDC->(DBGOTOP())
	QDC->(DbSeek(cFilQDC))
	While QDC->(!Eof())	 .And. QDC->QDC_FILIAL == cFilQDC	
	
    	IF QDC->QDC_STATUS == "2" //Inativo
			QDC->(DbSkip() )
			Loop           
        Endif
        
		If !Empty(QDC->QDC_CODASS)
			If M->QDH_CODASS <> QDC->QDC_CODASS
				QDC->(DbSkip() )
				Loop
			EndIf
		EndIf				
		If !Empty(QDC->QDC_CODTP)
			If M->QDH_CODTP <> QDC->QDC_CODTP //Tipo do Docto
				QDC->(DbSkip() )
				Loop
			EndIf
		EndIf	          
		If FWModeAccess("QAD")=="E" //!Empty(xFilial("QAD"))
			cFilDep:= aDeptos[nCnt,2]
		EndIf				
		If QAD->(DbSeek(cFilDep+aDeptos[nCnt,3]))
			cMat:= QAD->QAD_MAT                  
			If Empty(cMat)
				cMat:= Qd053InQDG(QDC->QDC_CODMAN,cFilDep,aDeptos[nCnt,3],@cFilMat)
			Endif
			cFilMat:=QAD->QAD_FILMAT
		EndIf
        If !Empty(cMat)

			aArea := GetArea()

			cQuery :=  " SELECT * "
			cQuery +=  "   FROM " +RetSQLName("QDT") +" QDT "
			cQuery +=  "  WHERE QDT_FILDEP = '" + cFilDep + "' " 
			cQuery +=  "    AND QDT_DEPTO = '"+ aDeptos[nCnt,3] +"' " 
			cQuery +=  "    AND QDT_FILCOD = '"+ QDC->QDC_FILIAL +"' " 
			cQuery +=  "    AND QDT_CODMAN = '"+ QDC->QDC_CODMAN +"' " 
			cQuery +=  "    AND QDT.D_E_L_E_T_ <> '*' " 

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T.)
			
			If (cAliasQry)->(!Eof()) 
				lDepxPst:= .T.
				QDT->(DBGOTO( (cAliasQry)->R_E_C_N_O_ ))
			ELse
				lDepxPst:= .F.
			EndIf 

			(cAliasQry)->(DbCloseArea())

			RestArea(aArea)

			nQdcRecno := QDC->(RECNO())
			If lDepxPst
				aAdd(aQDGRet,{M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,;
					cFilMat,aDeptos[nCnt,3],cMat,1,"2",If(lDepxPst,"S","N"),"P",QDC->QDC_CODMAN," ",Posicione("QAA",1,cFilMat+cMat,"QAA_NOME") ,;
					QDXFNANMAN(QDC->QDC_CODMAN,.T.,If(FWModeAccess("QDC")=="E",aDeptos[nCnt,2],))," "})				
			EndIf			
			QDC->(Dbgoto(nQdcRecno))
		Endif
		QDC->(DbSkip())
		Loop
	EndDo
	aQDGRet:= aSort( aQDGRet,,,{ |x,y| x[11] < y[11] } ) 
EndIf

QDJ->(DbGoTop())
QAA->(DbSetOrder(1))


If Len(aQDGRet) == 0 .and. lDepVaz
	If aDeptos[nCnt,5] == "S" .And. cTipo == "D" 
		MsgStop(OemToAnsi(STR0043)+aDeptos[nCnt,2]+"-"+aDeptos[nCnt,3]) // "Nao Existe(m) usuario(s) cadastrado(s) para o departamento: "
	Endif
	If aDeptos[nCnt,6] == "S" .And. cTipo == "P" 
		MsgStop(OemToAnsi(STR0044)+aDeptos[nCnt,2]+"-"+aDeptos[nCnt,3]) // "Nao Existe(m) pasta(s) cadastrada(s) para o departamento: "
	Endif
Endif

Return aQDGRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053AlDst ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Tela para edicao/alteracao dos dados dos destinatarios            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053AlDst(aQDG,nPos)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Lactos dos destinatarios                ³±±
±±³           ³ ExpN1 - Numerico contendo a posicao corrente do array de aQDG     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053AlDst(aQDG,nPos,aQDGFt,lFiltro)
Local oDlg
Local oItem
Local oUsuario
Local oCopias
Local oItCp
Local cDescTit:= OemToAnsi(STR0015) // "Destinatarios - Altera‡ao"
Local nOpc1   := 0
Local nItem   := 0
Local nItCp   := 0
Local nCopias := 0
Local cUsuario:= ""
Local cChave  := ""
Local aNovItens:={}
Local aCobItens:={}
Local I
Local aQDGAux  :={}

IF lFiltro
	aQDGAux:=aClone(aQDGFt)
Else
	aQDGAux:=aClone(aQDG)
Endif

If Len(aQDGAux) == 0 .Or. Empty(aQDGAux[nPos,6]+aQDGAux[nPos,11])
	Return .F.
EndIf


nItem:= If(aQDGAux[nPos,9] == "S",1,2)
nCopias:= aQDGAux[nPos,7]

If aQDGAux[nPos,10] == "D"
	nItCp:= Val(aQDGAux[nPos,8])
Else
	nItCp:= Val(aQDGAux[nPos,8])/2
EndIf

If aQDGAux[nPos,10] == "D"
	cUsuario:= aQDGAux[nPos,6]+" - "+QA_NUSR(aQDGAux[nPos,4],aQDGAux[nPos,6],.T.)
Else
	cUsuario:= aQDGAux[nPos,11]+" - "+QDXFNANMAN(aQDGAux[nPos,11],.T.)
EndIf

DEFINE MSDIALOG oDlg FROM 221,101 TO 385,480 TITLE cDescTit PIXEL

@ 003,003 TO 067,186 OF oDlg PIXEL
@ 010,006 SAY If(aQDGAux[nPos,10] == "D",OemToAnsi(STR0016),OemToAnsi(STR0011)) SIZE 135,007 OF oDlg PIXEL // "Usu rio" ### "Pastas"
@ 011,040 MSGET oUsuario VAR cUsuario PICTURE "@!" SIZE 144,010 OF oDlg PIXEL
oUsuario:lReadOnly:= .T.

@ 022,006 SAY OemToAnsi(STR0018) SIZE 035,007 OF oDlg PIXEL	// "Nr Copias"
@ 023,040 MSGET oCopias VAR nCopias PICTURE "9999" SIZE 024,010 OF oDlg PIXEL;
VALID nCopias > 0 WHEN IF(aQDGAux[nPos,10]=="D",nItCp<>1,.T.)

@ 037,006 SAY OemToAnsi(STR0019) SIZE 035,007 OF oDlg PIXEL // "Recebe Docto"
@ 038,045 RADIO oItem VAR nItem 3D SIZE 025,007 OF oDlg PIXEL ;
ITEMS OemToAnsi(STR0021),; // "Sim"
OemToAnsi(STR0022)  // "Nao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que Monta Array com outras tipos de Copias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("QDOAP21")
	If aQDGAux[nPos,10] == "D"
		aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0023)},{2,OemToAnsi(STR0024)},{3,OemToAnsi(STR0025)},{4,OemToAnsi(STR0026)}})
		cItCp:= aNovItens[Val(aQDGAux[nPos,8]),2]
	Else
		aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{3,OemToAnsi(STR0024)},{4,OemToAnsi(STR0026)}})		
		cItCp:= aNovItens[IF(Val(aQDGAux[nPos,8])<=2,Val(aQDGAux[nPos,8])/2,Val(aQDGAux[nPos,8])-2),2]
	Endif	
	aCobItens:={}
	FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
	NEXT
		
	@ 025,097 SAY OemToAnsi(STR0020) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
	@ 025,128 	COMBOBOX oItCp VAR cItCp ;
				ITEMS aCobItens ;
				SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlg PIXEL
Else		
	If aQDGAux[nPos,10] == "D"
		@ 024,097 SAY OemToAnsi(STR0020) SIZE 035,007 OF oDlg PIXEL  // "Tipo Copias"
		@ 025,128 RADIO oItCp VAR nItCp;
		ITEMS OemToAnsi(STR0023),; // "Eletronica"
			  OemToAnsi(STR0024),; // "Papel"
			  OemToAnsi(STR0025),; // "Ambos"
			  OemToAnsi(STR0026);  // "Nao Recebe"
			  3D SIZE 050,007 OF oDlg PIXEL
	Else
		@ 037,097 SAY OemToAnsi(STR0020) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
		@ 038,128 RADIO oItCp VAR nItCp;
		ITEMS OemToAnsi(STR0024),; // "Papel"
			  OemToAnsi(STR0026);  // "Nao Recebe"
			  3D SIZE 050,007 OF oDlg PIXEL
	EndIf
	oItCp:BCHANGE:={|| IF(aQDGAux[nPos,10]=="D",(nCopias:=IF(nItCp==1,nCopias:=1,nCopias), oCopias:Refresh(),oCopias:SetFocus()),"") }
	
EndIf


DEFINE SBUTTON FROM 069,130 TYPE 1 ENABLE OF oDlg ACTION (nOpc1:= 1,oDlg:End())
DEFINE SBUTTON FROM 069,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc1 == 1

	IF ExistBlock("QDOAP21")
		If aQDGAux[nPos,10] == "P"
			nItCp+= IF( nItCp==1 ,1 ,2 ) 
		Endif
	ELSE
		If aQDGAux[nPos,10] == "P"
			nItCp:= nItCp * 2
		Endif
	EndIf
	
	aQDGAux[nPos,9]:= If( nItem == 1, "S", "N" )
	aQDGAux[nPos,8]:= Str( nItCp, 1 )
	aQDGAux[nPos,7]:= nCopias

	If aQDGAux[nPos,9] == "N" //.And. aQDGAux[nPos,8] == "4"
		If !fVerUsrRes(aQDGAux[nPos])
			oQDG:SetArray(aQDG)
			oQDG:bLine:= If(Len(aQDG)>0,bQDGLine1,bQDGLine2)
			oQDG:Refresh()
			Return
		EndIf
	EndIf
	                   	
	IF lFiltro
		aQDGFt:=aClone(aQDGAux)
		oQDG:SetArray( aQDGFt )
		oQDG:bLine:= If(Len(aQDGFt)>0,bQDGFLin,bQDGLine2)		
		
		aQDG[aQDGFt[nPos][Len(aQDGFt[nPos])],9]:= If( nItem == 1, "S", "N" )
		aQDG[aQDGFt[nPos][Len(aQDGFt[nPos])],8]:= Str( nItCp, 1 )
		aQDG[aQDGFt[nPos][Len(aQDGFt[nPos])],7]:= nCopias					
	Else
		aQDG:=aClone(aQDGAux)
		oQDG:SetArray(aQDG)
		oQDG:bLine:= If(Len(aQDG)>0,bQDGLine1,bQDGLine2)
	EndIF
	oQDG:Refresh()

EndIf


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053InQDG ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Inclusao do Responsavel pelo Depto caso nao exista                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053InQDG(cPasta,cDepFil,cDepCod)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Caracter contendo o codigo da Pasta/Manual                ³±±
±±³           ³ ExpC2 - Caracter contendo a filial do Departamento                ³±±
±±³           ³ ExpC3 - Caracter contendo o Codigo do Departamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053InQDG(cPasta,cDepFil,cDepCod,cFilUsr)

Local oDlgD
Local oMatUsr
Local oUsuario
Local oDepFil
Local oDepCod
Local oDepDes
Local cCodUsr:= Space(TAMSX3("QAA_MAT")[1])
Local cUsu   := Space(TAMSX3("QAA_APELID")[1])
Local cDepDes:= QA_NDEPT(cDepCod,.T.,cDepFil)
Local nOpc1  := 0        
Local oFilUsr

DEFINE MSDIALOG oDlgD FROM 000, 000 TO 189, 395 TITLE OemToAnsi(STR0027) PIXEL //"Respons vel pelo Departamento" 

@ 003,003 TO 079, 196 OF oDlgD PIXEL

//Posicionado o objeto para ser o primeiro foco da tela devido QA_CHKFIL
@ 039,040 MSGET oFilUsr VAR cFilUsr SIZE 075,008 F3 "SM0_01" OF oDlgD PIXEL;
				VALID QD053VLD(cFilUsr,cDepFil) .AND.QA_CHKFIL(cFilUsr,@cFilMat)

@ 011,040 MSGET oDepFil VAR cDepFil SIZE 075,008 OF oDlgD PIXEL
oDepFil:lReadOnly:= .T.

@ 011,118 MSGET oDepCod VAR cDepCod SIZE 075,008 OF oDlgD PIXEL
oDepCod:lReadOnly:= .T.

@ 018,006 SAY OemToAnsi(STR0006) SIZE 035,007 OF oDlgD PIXEL //"Depto"

@ 023,040 MSGET oDepDes VAR cDepDes SIZE 144,008 OF oDlgD PIXEL
oDepDes:lReadOnly:= .T.


@ 039,118 MSGET oMatUsr VAR cCodUsr F3 "QDE" SIZE 075,008 OF oDlgD PIXEL ;
            VALID QD053VLD(cFilUsr,cDepFil) .AND. If(Empty(cUsu:= Qa_nUsr(cFilUsr,cCodUsr,.T.)),;
            		(Help(" ",1,"QD050FNE"),oUsuario:Refresh(),.F.),;
            		(oUsuario:Refresh(),.T.)) // "Funcionario/Usuario nao Existe"

@ 046,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oDlgD PIXEL //"Usu rio"

@ 051,040 MSGET oUsuario VAR cUsu SIZE 144,008 OF oDlgD PIXEL
oUsuario:lReadOnly:= .T.

@ 067,006 SAY OemToAnsi(STR0028) SIZE 180, 07 OF oDlgD PIXEL //"Nao foi encontrado um respons vel pelo Depto. Cadastre-o."

DEFINE SBUTTON FROM 081,160 TYPE 1 ENABLE OF oDlgD ACTION (nOpc1 := 1, oDlgD:End())

ACTIVATE MSDIALOG oDlgD CENTERED

If nOpc1 == 1
	Reclock("QAD",.F.)
	QAD->QAD_FILMAT:= cFilUsr
	QAD->QAD_MAT   := cCodUsr
	QAD->(MsUnlock())
EndIf

Return (If(nOpc1 == 1,cCodUsr,NIL))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053MRcbT ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca os destinatarios                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053MRcbT( aQDG )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053MRcbT(aQDG)

Local cChave:= ""
Local nPos  := ""
Local nC    := ""

If Len( aQDG ) > 0
	nC:= Ascan( aQDG, { |X| x[9] == "S" } )
	aEval(aQDG,{|x|x[9]:= If(nC > 0,"N","S") })
	aEval(aQDG,{|x|x[12]:= If(x[9] == "S"," ",x[12]) })
EndIf

Return aQDG

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53Destino³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Inclusao de Usuarios                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53Destino(ExpA1,ExpA2)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo Departamentos                              ³±±
±±³           ³ ExpA2 - Array contendo Destinatarios  					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53Destino(aCargos,aDeptos)

Local aAuxDepto := Aclone(aDeptos)
Local aBakCargo := {}
Local bCtrCar   := {|| IF(!lCarHab,(oPanCarg:hide(),oBtn3:hide(),oBtn4:hide(),oBtn5:hide()),(oPanCarg:show(),oBtn3:show(),oBtn4:show(),oBtn5:show()))}
Local bQACLine1 := {}
Local bQACLine2 := {}
Local bQADLine1 := {}
Local bQADLine2 := {}
Local lRet      := .F.
Local nPosDep   := 1
Local oBtn1     := NIL
Local oBtn2     := NIL
Local oBtn3     := NIL
Local oBtn4     := NIL
Local oBtn5     := NIL
Local oCargos   := NIL
Local oCarHab   := NIL
Local oDeptos   := NIL
Local oDepVaz   := NIL
Local oDlg1     := NIL
Local oNo       := LoadBitmap( GetResources(), "LBNO" )
Local oOk       := LoadBitmap( GetResources(), "ENABLE" )
Local oPa       := LoadBitmap( GetResources(), "BR_AMARELO" )

Private lDepVaz := .T.

If Len(aQDJDoc) > 0
	If (nPosDep:= aScan(aDeptos,{|x| x[2]+x[3] == aQDJDoc[oQDJ:nAt,4]+aQDJDoc[oQDJ:nAt,5]})) == 0
		nPosDep:= 1
	EndIf
EndIf

IF(Empty(aCargos))
	QD53CarCar(@aCargos)              
Endif
aBakCargo := Aclone(aCargos)


DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0002) FROM 000,000 TO 550,780 OF oMainWnd PIXEL //"Departamentos"

oPanel:= tPanel():New(,,,oDlg1)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@ 003,003 TO 232,389 LABEL OemToAnsi(STR0002) OF oPanel PIXEL //"Departamentos"

@ 010,010 CHECKBOX oDepVaz VAR lDepVaz PROMPT OemToAnsi(STR0049)SIZE 200,007 OF oPanel COLOR CLR_HRED,CLR_WHITE PIXEL	  //'Apresenta mensagem alertando quando NÃO há usuarios no Departamento'

@ 018,007 MSPANEL oPanDept PROMPT "" SIZE 375,194 OF oPanel

@ 000,000 MSPANEL oPanCarg PROMPT "" SIZE 176,010 OF oPanDept 
oPanCarg:Align := CONTROL_ALIGN_RIGHT

@ 008,245 SAY oSayCar Var "  "+OemToAnsi(STR0057) SIZE 180,010 OF oPanCarg COLOR CLR_HRED,CLR_WHITE PIXEL	   //'As Funcoes podem possuir Deptos em comum, verifique a Legenda!'
oSayCar:Align := CONTROL_ALIGN_TOP

@ 018,007 LISTBOX oDeptos FIELDS;
             HEADER  " ", ;
                     OemToAnsi(STR0009),; // "Fil/Cod" 
                     OemToAnsi(STR0014) ; // "Descricao"
             SIZE 200,194 OF oPanDept PIXEL;
             ON DBLCLICK (QDO053Cl(oDeptos,@aDeptos,@aCargos),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh(),;
             					oCargos:SetArray(aCargos),oCargos:bLine:= If(Len(aCargos)>0,bQACLine1,bQACLine2),oCargos:Refresh())

bQADLine1 := {|| {If(aDeptos[oDeptos:nAt,1] == "S",oOk, oNo),aDeptos[oDeptos:nAt,2]+" - "+aDeptos[oDeptos:nAt,3],aDeptos[oDeptos:nAt,4]}}
bQADLine2 := {|| {oNo,Space(18),Space(25) }}

oDeptos:SetArray(aDeptos)
oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2)
oDeptos:nAt:= nPosDep
oDeptos:SetFocus(.t.)
oDeptos:Align:= CONTROL_ALIGN_ALLCLIENT
oDeptos:Refresh()

@ 216,006 BUTTON oBtn1 PROMPT OemToAnsi(STR0029) SIZE 067,011 OF oPanel PIXEL; //"Marcar/Desmarcar todos"
				ACTION (QD53MRDep(@aDeptos,@aCargos),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh(),;
								oCargos:SetArray(aCargos),oCargos:bLine:= If(Len(aCargos)>0,bQACLine1,bQACLine2),oCargos:Refresh())

@ 216,075 BUTTON oBtn2 PROMPT OemToAnsi(STR0012) SIZE 050,011 OF oPanel PIXEL; //"Pesquisa Depto"
				ACTION QD53PesqDep(aQDJDoc,2,@oDeptos,aDeptos)

@ 010,215 CHECKBOX oCarHab VAR lCarHab PROMPT OemToAnsi(STR0056) SIZE 100,007 OF oPanel  PIXEL 

oCarHab:bCHANGE:= bCtrCar

@ 028,214 LISTBOX oCargos FIELDS;
             HEADER  " ", ;
                     OemToAnsi(STR0009),; // "Fil/Cod" 
                     OemToAnsi(STR0014) ; // "Descricao"
                      COLSIZES 42,42 ;
             SIZE 180,192 OF oPanCarg PIXEL ;
           	 ON DBLCLICK (QD53MRCar(@aCargos,.T.,oCargos:nAt,@aDeptos),oCargos:SetArray(aCargos),oCargos:bLine:= If(Len(aCargos)>0,bQACLine1,bQACLine2),oCargos:Refresh(),;
						oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh())


bQACLine1 := {|| {If(aCargos[oCargos:nAt,1] == "S",oOk,IF(aCargos[oCargos:nAt,1] == "N",oNo,oPa)),aCargos[oCargos:nAt,2]+" - "+aCargos[oCargos:nAt,3],aCargos[oCargos:nAt,4]}}
bQACLine2 := {|| {oNo,Space(TamSx3("QAC_FUNCAO")[1]),Space(TamSx3("QAC_DESC")[1])}}

oCargos:SetArray(aCargos)
oCargos:bLine:= If(Len(aCargos)>0,bQACLine1,bQACLine2)
oCargos:SetFocus(.t.)
oCargos:Align:= CONTROL_ALIGN_TOP
oCargos:Refresh() 

@ 216,215 BUTTON oBtn3 PROMPT OemToAnsi(STR0029) SIZE 067,011 OF oPanel PIXEL; //"Marcar/Desmarcar todos"
				ACTION (QD53MRCar(@aCargos,.F.,oCargos:nAt,@aDeptos),oCargos:SetArray(aCargos),oCargos:bLine:= If(Len(aCargos)>0,bQACLine1,bQACLine2),oCargos:Refresh(),;
				 				 oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh())

@ 216,284 BUTTON oBtn4 PROMPT OemToAnsi(STR0054) SIZE 050,011 OF oPanel PIXEL;  //"Pesquisa Funcao"
				ACTION QD53PesqCar(@oCargos,aCargos)
				
@ 216,336 BUTTON oBtn5 PROMPT OemToAnsi(STR0039) SIZE 030,011 OF oPanel PIXEL ;  //"Legenda"
				ACTION QD053LeCar()
				
//Controla Cargos e Funcoes				
Eval(bCtrCar)				

ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1,{|| If(lAltQDJ,(QD53GrvQDJ(@aDeptos,aCargos,aAuxDepto,lCarHab),lRet:=.T.),lRet:=.F.),oDlg1:End()},{|| aDeptos:= Aclone(aAuxDepto),aCargos:=AClone(aBakCargo),oDlg1:End()})

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD53CarDep ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Carrega Departamentos para Selecao no Cadastro de Usuarios/Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD53CarDep(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro  ³ ExpA1 - Array Contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53CarDep(aDeptos)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cFiltro	:= ""
Local lQd53FilDp:= .F. 

// Ponto de Entrada para permitir filtrar os departamentos a serem selecionados
If Existblock("QD53FILDP")
	cFiltro 	:= Execblock("QD53FILDP",.F.,.F.)
	lQd53FilDp	:= .T.
Endif

cQuery := " SELECT QAD_FILIAL,QAD_CUSTO,QAD_DESC, QAD.R_E_C_N_O_" // Departamentos que estao associados a algum funcionario ativo
cQuery += " FROM " + RetSqlName("QAD") + " QAD "
cQuery += " WHERE QAD_STATUS <> '2' AND D_E_L_E_T_ <> '*' AND"
cQuery += " QAD_CUSTO IN (SELECT DISTINCT QAA_CC FROM " + RetSqlName("QAA") + " WHERE D_E_L_E_T_ <> '*' AND QAA_STATUS <> '2' AND QAA_CC <> ' ')"

If lQd53FilDp
	cQuery += " AND "+cFiltro
Endif

//If !Empty(xFilial("QAD"))
//	cQuery += " AND QAD_FILIAL = '"+ xFilial("QAD") +"'
//EndIf

cQuery += " UNION" 

cQuery += " SELECT QAD_FILIAL,QAD_CUSTO,QAD_DESC, QAD.R_E_C_N_O_" // Departamentos que possuem algum responsavel ativo
cQuery += " FROM " + RetSqlName("QAD") + " QAD "
cQuery += " WHERE QAD_STATUS <> '2' AND D_E_L_E_T_ <> '*' AND"
cQuery += " QAD_MAT IN (SELECT DISTINCT QAA_MAT FROM " + RetSqlName("QAA") + " WHERE D_E_L_E_T_ <> '*' AND QAA_STATUS <> '2')"

If lQd53FilDp
	cQuery += " AND "+cFiltro
Endif

//If !Empty(xFilial("QAD"))
//	cQuery += " AND QAD_FILIAL = '"+ xFilial("QAD") +"'
//EndIf

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2"
Else
	cQuery += " ORDER BY " + SqlOrder("QAD_FILIAL+QAD_CUSTO")
Endif

cQuery := ChangeQuery(cQuery)			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAD",.T.,.T.)
  
TMPQAD->(DbGoTop())
While TMPQAD->(!Eof())
	Aadd(aDeptos,{"N",TMPQAD->QAD_FILIAL,TMPQAD->QAD_CUSTO,TMPQAD->QAD_DESC,"N","N",TMPQAD->R_E_C_N_O_})
	TMPQAD->(DbSkip())
Enddo
TMPQAD->(DBCLOSEAREA())
	    	    
RestARea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QDO053Cl   ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Tratar o click da pergunte                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QDO053Cl(ExpO1,ExpA1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Depto                                              ³±±
±±³           ³ ExpA1 - Array contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO053Cl(oDeptos,aDeptos,aCargos)

Local aTpDestino := {}
Local i          := oDeptos:nAt
Local iC         := 0
Local iT         := 0
Local lPasta     := .F.
Local lUsuario   := .F.
Local nContN     := 0
Local nContS     := 0

If aDeptos[oDeptos:nAt,1] == "S"
	If aDeptos[oDeptos:nAt,5] == "S"
		lUsuario:= .T.
	Endif
	If aDeptos[oDeptos:nAt,6] == "S"
		lPasta:= .T.
	EndIf
	aTpDestino:= QD53TPCop(lUsuario,lPasta)
	
	If !aTpDestino[1] .And. !aTpDestino[2]
		aDeptos[oDeptos:nAt,1]:= "N"
	EndIf
Else
	aTpDestino:= QD53TPCop()
	If aTpDestino[1] .Or. aTpDestino[2]
		aDeptos[oDeptos:nAt,1]:= "S"
	EndIf
EndIf	

aDeptos[oDeptos:nAt,5] := If(aTpDestino[1],"S","N")
aDeptos[oDeptos:nAt,6] := If(aTpDestino[2],"S","N")

lAltQDJ:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marcar Funcoes atraves Deptos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aDeptos[i,5]=="S" .Or. aDeptos[i,6]=="S"   //Eletronica
	For ic:=1 To Len(aCargos)			
		For iT:=1 To Len(aCargos[ic,5])			
			IF aCargos[ic,5,iT,1]+aCargos[ic,5,iT,2]==aDeptos[i,2]+aDeptos[i,3]
				aCargos[ic,5,iT,3]:="S"
			Endif
		Next
	Next
Else
	For ic:=1 To Len(aCargos)
		For iT:=1 To Len(aCargos[ic,5])
			IF aCargos[ic,5,iT,1]+aCargos[ic,5,iT,2]==aDeptos[i,2]+aDeptos[i,3]
				aCargos[ic,5,iT,3]:="N"
			Endif
		Next
	Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica Funcoes Completos "S" ou parciais "P" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ic:=1 To Len(aCargos)
	nContS:=0
	nContN:=0
	aEval(aCargos[ic,5],{|x| IF(x[3]=="S",nContS++,nContN++) })
	
	IF nContS==Len(aCargos[ic,5])
		aCargos[ic,1]:="S"
	ElseIF nContN==Len(aCargos[ic,5])
		aCargos[ic,1]:="N"
	Else
		aCargos[ic,1]:="P"
	Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD53TPCop  ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Retorna o Tipo de Copia (Usuario/Pasta)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD53TPCop()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53TPCop(lUsuario,lPasta,lCargo)

Local oDlg2
Local oUsuario
Local oPasta

Default lUsuario:= .F.
Default lPasta  := .F.
Default lCargo  := .F.

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0032) FROM 000,000 TO 100,200 OF oMainWnd PIXEL //"Tipo Destino"

@ 003,003 TO 035,098 LABEL OemToAnsi(STR0032) OF oDlg2 PIXEL //"Tipo Destino"

@ 011,007 CHECKBOX oUsuario VAR lUsuario PROMPT OemToAnsi(STR0010) SIZE 040,010 OF oDlg2 PIXEL // "Usuarios"
@ 022,007 CHECKBOX oPasta VAR lPasta PROMPT OemToAnsi(STR0011) SIZE 040,010 OF oDlg2 PIXEL // "Pastas"      

IF lCargo         
	oPasta:Disable()
Endif

DEFINE SBUTTON FROM 036,070 TYPE 1 ENABLE OF oDlg2;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

Return {lUsuario,lPasta}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD53GrvQDJ ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Grava/Apaga Departamentos Selecionados no arquivo QDJ             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD53GrvQDJ(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo Destinatarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD53GrvQDJ(aDeptos,aCargos,aAuxDepto,lCarHab)

Local aArea    := GetArea()
Local aAuxQDG  := {}
Local aFilQAA  := {}
Local lQadComp := FWModeAccess("QAD")=="C" //Empty(xFilial("QAD")) //QAD - Compartilhado
Local nCnt     := 0
Local nFilQaa  := 1
Local nIdx1    := 0
Local nIdx2    := 0
Local nPos     := 0

CursorWait()
For nCnt:= 1 To Len(aDeptos)
   
	aFilQAA := { aDeptos[nCnT,2] }
	If aDeptos[nCnt,1] == "S"	
		If lQadComp //QAD - Compartilhado
	
			cQuery :="          SELECT DISTINCT QAA.QAA_FILIAL,QAA.QAA_CC,QAA.QAA_TPRCBT "
			cQuery +="            FROM " + RetSqlName("QAA")+" QAA "
			If FWModeAccess("QAD",1) = "E"
				cQuery +="  INNER JOIN " + RetSqlName("QAD")+" QAD "
				cQuery +="          ON QAD.QAD_CUSTO = QAA.QAA_CC "
				cQuery +="         AND QAD.QAD_FILIAL = '"+aDeptos[nCnT,2]+"'"
				cQuery +="         AND QAD.D_E_L_E_T_ <> '*' "
			EndIf
			cQuery +="           WHERE QAA.QAA_CC='"+aDeptos[nCnT,3]+"' AND "
			If FWModeAccess("QAD",1) = "E"
				cQuery +="	           QAD.R_E_C_N_O_ = " + cValToChar(aDeptos[nCnT,7])	+ " AND"
			EndIf
			cQuery +="                 QAA.QAA_TPRCBT <> '4' AND "         				
			cQuery +=                  QA_FilSitF(.T.,.T.) + " AND "
			cQuery +="                 QAA.D_E_L_E_T_ <> '*' AND " 
			cQuery +="                 QAA.QAA_STATUS <> '2'" 

			If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
				cQuery += " ORDER BY 1"
			Else
				cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL")
			Endif
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

			DbGotop()
			IF TMPQAA->(!Eof())			
			    aFilQAA:={}			
				While TMPQAA->(!Eof())
     				If Ascan(aFilQAA, TMPQAA->QAA_FILIAL) = 0
						Aadd(aFilQAA, TMPQAA->QAA_FILIAL)
					EndIf
     				TMPQAA->(DbSkip())                         
         		Enddo
			Endif	         			
			TMPQAA->(DbCLOSEAREA())	
			RestArea(aArea)									

		Endif
	  
	    // Carrega Destinatarios				
		If aDeptos[nCnT,5] == "S"
		    IF aAuxDepto[nCnT,5] == "S" .AND. !lCarHab
		       Loop
		    Endif
			For nFilQAA := 1 TO Len(aFilQAA) 
				If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] == aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"D"})) == 0
					aAuxQDG := QD053AtQDG(aDeptos,nCnt,"D",aFilQAA[nFilQAA],aCargos)
					If Len(aAuxQDG) > 0
					   	Aadd(aQDJDoc,{M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,aFilQAA[nFilQAA],aDeptos[nCnT,3],"D",;
			                 OemToAnsi(STR0016),aDeptos[nCnT,4],aAuxQDG,aDeptos[nCnT,7]})  //"Usuario"
					Else
						aDeptos[nCnt,1] := "N"
					Endif
				Else
					aAuxQDG := QD053AtQDG(aDeptos,nCnt,"D",aFilQAA[nFilQAA],aCargos)
					If Len(aAuxQDG) > 0
						aQDJDoc[nPos]:={M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,aFilQAA[nFilQAA],aDeptos[nCnT,3],"D",;
		    				 OemToAnsi(STR0016),aDeptos[nCnT,4],aAuxQDG,aDeptos[nCnT,7]}  //"Usuario"						 
					Else
						aDeptos[nCnt,1] := "N"
					Endif				
				Endif
			Next	
		Else // Deleta Depto Destinatarios			
			If lQadComp //QAD - Compartilhado
				While (nPos := aScan(aQDJDoc,{|x| x[5]+x[6] == aDeptos[nCnT,3]+"D"})) > 0
		        	aDel(aQDJDoc,nPos)
		           	aSize(aQDJDoc,Len(aQDJDoc)-1)
				EndDo				
			Else
				For nFilQAA := 1 TO Len(aFilQAA) 
					If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] == aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"D"})) > 0
			       		aDel(aQDJDoc,nPos)
		    	   		aSize(aQDJDoc,Len(aQDJDoc)-1)
					EndIf								
				Next	
			Endif
	    Endif
		
		// Carrega Pastas
		If aDeptos[nCnT,6] == "S"
			If lQadComp //QAD - Compartilhado
				For nFilQAA := 1 TO Len(aFilQAA) 
					If (nPos := aScan(aQDJDoc,{|x| x[5]+x[6] == aDeptos[nCnT,3]+"P"})) == 0
						aAuxQDG := QD053AtQDG(aDeptos,nCnt,"P",@aFilQAA[nFilQAA])
						If Len(aAuxQDG) > 0 .AND. !Empty(aFilQAA[nFilQAA])
						   	Aadd(aQDJDoc,{M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,aFilQAA[nFilQAA],aDeptos[nCnT,3],"P",;
				                 OemToAnsi(STR0007),aDeptos[nCnT,4],aAuxQDG,aDeptos[nCnT,7]})  // "Pasta"
						Else
							For nIdx1:=1 To Len(aCargos)
								For nIdx2 :=1 To Len(aCargos[nIdx1,5])
									IF aCargos[nIdx1,5,nIdx2,1]+aCargos[nIdx1,5,nIdx2,2]==aDeptos[nCnt,2]+aDeptos[nCnt,3]
										aCargos[nIdx1,5,nIdx2,3]:="N"
										aCargos[nIdx1,1]:="N"
									Endif
								Next
							Next
							aDeptos[nCnt,1] := "N"
						Endif
					Endif                        
				Next	
		    Else
				For nFilQAA := 1 TO Len(aFilQAA) 
					If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] == aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"P"})) == 0
						aAuxQDG := QD053AtQDG(aDeptos,nCnt,"P",@aFilQAA[nFilQAA])
						If Len(aAuxQDG) > 0 .AND. !Empty(aFilQAA[nFilQAA])
						   	Aadd(aQDJDoc,{M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,aFilQAA[nFilQAA],aDeptos[nCnT,3],"P",;
				                 OemToAnsi(STR0007),aDeptos[nCnT,4],aAuxQDG,aDeptos[nCnT,7]})  // "Pasta"
						Else
							For nIdx1:=1 To Len(aCargos)
								For nIdx2 :=1 To Len(aCargos[nIdx1,5])
									IF aCargos[nIdx1,5,nIdx2,1]+aCargos[nIdx1,5,nIdx2,2]==aDeptos[nCnt,2]+aDeptos[nCnt,3]
										aCargos[nIdx1,5,nIdx2,3]:="N"
										aCargos[nIdx1,1]:="N"
									Endif
								Next
							Next
							aDeptos[nCnt,1] := "N"
						Endif
					Endif                        
				Next	
			Endif
		Else // Deleta Depto Pastas
			If lQadComp //QAD - Compartilhado
				While (nPos := aScan(aQDJDoc,{|x| x[5]+x[6] == aDeptos[nCnT,3]+"P"})) > 0
		           aDel(aQDJDoc,nPos)
		           aSize(aQDJDoc,Len(aQDJDoc)-1)
				EndDo	
			Else
				For nFilQAA := 1 TO Len(aFilQAA) 	
					If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] == aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"P"})) > 0
			           aDel(aQDJDoc,nPos)
			           aSize(aQDJDoc,Len(aQDJDoc)-1)
					EndIf						
				Next
			Endif
		Endif								
	Else // Deleta Depto 
		If lQadComp //QAD - Compartilhado
			While (nPos := aScan(aQDJDoc,{|x| x[5]+x[6]+cValToChar(x[10]) == aDeptos[nCnT,3]+"D"+cValToChar(aDeptos[nCnT,7])})) > 0
		    	aDel(aQDJDoc,nPos)
		        aSize(aQDJDoc,Len(aQDJDoc)-1)
			EndDo
			While (nPos := aScan(aQDJDoc,{|x| x[5]+x[6] == aDeptos[nCnT,3]+"P"})) > 0
		       aDel(aQDJDoc,nPos)
		       aSize(aQDJDoc,Len(aQDJDoc)-1)
			Enddo
		Else		
			For nFilQAA := 1 TO Len(aFilQAA)
				If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] ==  aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"D"})) > 0
		           aDel(aQDJDoc,nPos)
		           aSize(aQDJDoc,Len(aQDJDoc)-1)
				EndIf
				If (nPos := aScan(aQDJDoc,{|x| x[4]+x[5]+x[6] ==  aFilQAA[nFilQAA]+aDeptos[nCnT,3]+"P"})) > 0
		           aDel(aQDJDoc,nPos)
		           aSize(aQDJDoc,Len(aQDJDoc)-1)
				EndIf
			Next
		Endif
	EndIf
Next nCnt

lAltQDJ:= .F.
If Len(aQDJDoc) > 0
	aQDJDoc:= aSort( aQDJDoc,,,{ |x,y| x[6]+x[4]+x[5] < y[6]+y[4]+y[5] } ) 
Endif
CursorArrow() 
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53MRDep  ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca os Departamentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53MRDep(ExpA1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53MRDep(aDeptos,aCargos)

Local nCnt      := 0
Local nC        := 0
Local nCount    := 0
Local aTpDestino:= {}
Local lPasta    := .F.
Local lUsuario  := .F.
Local i	    	:= 0
Local iT	    := 0
Local iC	    := 0
Local nContS	:=0
Local nContN	:=0

If Len(aDeptos) > 0
	nC:= Ascan(aDeptos,{ |X| x[1] == "S" } )
	If nC == 0
		aTpDestino:= QD53TPCop()
		If aTpDestino[1]
			lUsuario := .T.
		EndIf
		If aTpDestino[2]
			lPasta := .T.
		EndIf
	EndIf
	For nCnt:= 1 to Len(aDeptos)
		If nC <> 0
			aDeptos[nCnt,1]:= "N"
		Else
			If aTpDestino[1] .Or. aTpDestino[2]
				aDeptos[nCnt,1]:= "S"
			EndIf
		EndIf
		aDeptos[nCnt,5]:= If(lUsuario,"S","N")
		aDeptos[nCnt,6]:= If(lPasta,"S","N")
	Next nCnt
	lAltQDJ:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marcar Cargos atraves Deptos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 To Len(aDeptos)
	IF aDeptos[i,5]=="S"   //Eletronica
		For ic:=1 To Len(aCargos)
			For iT:=1 To Len(aCargos[ic,5])
				IF aCargos[ic,5,iT,1]+aCargos[ic,5,iT,2]==aDeptos[i,2]+aDeptos[i,3]
					aCargos[ic,5,iT,3]:="S"
				Endif
			Next
		Next
	Else
		For ic:=1 To Len(aCargos)
			For iT:=1 To Len(aCargos[ic,5])
				IF aCargos[ic,5,iT,1]+aCargos[ic,5,iT,2]==aDeptos[i,2]+aDeptos[i,3]
					aCargos[ic,5,iT,3]:="N"
				Endif
			Next
		Next
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica Funcoes Completos "S" ou parciais "P" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ic:=1 To Len(aCargos)
	nContS:=0
	nContN:=0
	aEval(aCargos[ic,5],{|x| IF(x[3]=="S",nContS++,nContN++) })
	
	IF nContS==Len(aCargos[ic,5])
		aCargos[ic,1]:="S"
	ElseIF nContN==Len(aCargos[ic,5])
		aCargos[ic,1]:="N"
	Else
		aCargos[ic,1]:="P"
	Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53AtArray³ Autor ³ Eduardo de Souza           ³ Data ³ 15/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Atualiza os arrays do listbox                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53AtArray(ExpA1,ExpA2,ExpA3,ExpO1,ExpB1,ExpO2,ExpB2)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos destino                   ³±±
±±³           ³ ExpA2 - Array contendo os destinatarios                           ³±±
±±³           ³ ExpA3 - Array contendo os destinatarios                           ³±±
±±³           ³ ExpO1 - Objeto Departamento Destino                               ³±±
±±³           ³ ExpB1 - Bloco Departamento Destino                                ³±±
±±³           ³ ExpO2 - Objeto Destinatarios                                      ³±±
±±³           ³ ExpB2 - Bloco Destinatarios                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53AtArray(nAt)

oQDJ:SetArray(aQDJDoc)
oQDJ:bLine:= If(Len(aQDJDoc)>0,bQDJLine1,bQDJLine2)
oQDJ:GoTop()
oQDJ:Refresh()
If Len(aQDJDoc) > 0 .And. Len(aQDJDoc[oQDJ:nAt,9]) > 0
	oQDG:SetArray(aQDJDoc[oQDJ:nAt,9])
	oQDG:bLine:= bQDGLine1
Else
	oQDG:SetArray({})
	oQDG:bLine:= bQDGLine2
Endif
oQDG:GoTop()
oQDG:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53PesqDep³ Autor ³ Eduardo de Souza           ³ Data ³ 15/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Departamento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53PesqDep(ExpO1,ExpA1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Departamentos                                      ³±±
±±³           ³ ExpA1 - Array contendo os departamentos                           ³±±
±±³           ³ ExpN1 - Tipo de Array (aQDJ/aDeptos)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53PesqDep(aQDJDoc,nTpArray,oDeptos,aDeptos)
Local oDlg2
Local oFilDept
Local oCodDep
Local oDesDep
Local cCodDep := Space(TamSX3("QAD_CUSTO")[1])
Local cDesDep := Space(TamSX3("QAD_DESC")[1])
Local nOpcao1 := 0
Local nPos    := 0
Local nPosFil := If(nTpArray == 1,4,2) // aQDJDoc[nPos,4] ### aDeptos[nPos,2]
Local nPosDep := If(nTpArray == 1,5,3) // aQDJDoc[nPos,5] ### aDeptos[nPos,3]
Local nTpDest := 1
Local cTpDest := ""

Private cFilDept:= xFilial("QAD") // Será utizada na Consulta Padrao QDD por isso está como Private

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0012) FROM 000,000 TO 110,470 OF oMainWnd PIXEL //"Pesquisa Depto" 110 310

@ 003,003 TO 040,232 LABEL OemToAnsi(STR0002) OF oDlg2 PIXEL //"Departamento" 173

@ 010,006 MSGET oFilDept VAR cFilDept PICTURE REPL("@!",FWSizeFilial()) F3 "SM0_01" SIZE 070,008 OF oDlg2 PIXEL;
          VALID QA_CHKFIL(cFilDept,@cFilDep) WHEN FWModeAccess("QAD")=="E"//! Empty(cFilDept)

@ 010,078 MSGET oCodDep VAR cCodDep PICTURE '@!' F3 "QDD" SIZE 110,008 OF oDlg2 PIXEL;
				VALID If(Empty(cDesDep:= QA_NDEPT(cCodDep,.T.,cFilDept)),;
						(Help(" ",1,"QD050CCNE"),oDesDep:Refresh(),.F.),; // "Depto nao existe"
						(oDesDep:Refresh(),.T.))

@ 025,006 MSGET oDesDep VAR cDesDep SIZE 100,008 OF oDlg2 PIXEL
oDesDep:lReadOnly:= .T.

If nTpArray == 1
	@ 010,191 TO 035,227 LABEL OemToAnsi(STR0032) OF oDlg2 PIXEL //"Tipo Destino"
	@ 017,192 RADIO oTpDest VAR nTpDest;
									ITEMS OemToAnsi(STR0016),;// "Usuario"
											OemToAnsi(STR0007); // "Pasta"
					3D SIZE 030,007 OF oDlg2 PIXEL
	
EndIf

DEFINE SBUTTON FROM 041,155 TYPE 1 ENABLE OF oDlg2;
			ACTION (nOpcao1:= 1,cTpDest:= If(nTpDest == 1,"D","P"),oDlg2:End())

DEFINE SBUTTON FROM 041,185 TYPE 2 ENABLE OF oDlg2;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

If nOpcao1 == 1
	If nTpArray == 1
		If (nPos:= aScan(aQDJDoc,{|x| x[nPosFil]+x[nPosDep]+x[6] == cFilDept+cCodDep+cTpDest} )) > 0
			oQDJ:nAt:= nPos
			oQDJ:Refresh()
			oQDG:SetArray( aQDJDoc[oQDJ:nAt,9] )
			oQDG:bLine:= bQDGLine1
			oQDG:GoTop()
			oQDG:Refresh()
		EndIf
	Else
		If (nPos:= aScan(aDeptos,{|x| x[nPosFil]+x[nPosDep] == cFilDept+cCodDep} )) > 0
			oDeptos:nAt:= nPos
			oDeptos:Refresh()
		EndIf
	EndIf	
	If nPos == 0
		Help(" ",1,"QD053DEPNE") //"Departamento Destino nao cadastrado neste Documento"
	EndIf
EndIf
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53PesqUsr³ Autor ³ Eduardo de Souza           ³ Data ³ 15/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Usuario Destino                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53PesqUsr(ExpO1,ExpA1,ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Usuarios                                           ³±±
±±³           ³ ExpA1 - Array contendo Usuarios Destinos                          ³±±
±±³           ³ ExpC1 - Tipo de Destino (Usuario/Pasta)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53PesqUsr(aUsrs,cTpDest)

Local oDlg2
Local oFilUsr
Local oCodUsr
Local oDesUsr
Local cFilUsr:= xFilial("QAA")
Local cCodUsr:= Space(TamSX3("QAA_MAT")[1])
Local cDesUsr:= Space(TamSX3("QAA_NOME")[1])
Local nOpcao1:= 0
Local nPos   := 0

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0008) FROM 000,000 TO 110,420 OF oMainWnd PIXEL //"Pesquisa Usuario"

If cTpDest == "D"
	@ 003,003 TO 040,208 LABEL OemToAnsi(STR0016) OF oDlg2 PIXEL //"Usuario"
	
	@ 010,006 MSGET oFilUsr VAR cFilUsr PICTURE REPL("@!",FWSizeFilial()) F3 "SM0_01" SIZE 075,008 OF oDlg2 PIXEL;
	          VALID QA_CHKFIL(cFilUsr,@cFilMat)
	
	@ 010,095 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 110,008 OF oDlg2 PIXEL;
					VALID If(Empty(cDesUsr:= QA_NUSR(cFilUsr,cCodUsr,.T.)),;
							(Help(" ",1,"QD050FNE"),oDesUsr:Refresh(),.F.),; // "Funcionario nao Existe"
							(oDesUsr:Refresh(),.T.))
					
ElseIf cTpDest == "P"
	cCodUsr:= Space(15)
	@ 003,003 TO 040,208 LABEL OemToAnsi(STR0011) OF oDlg2 PIXEL //"Pastas"
	@ 010,006 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDC" SIZE 055,008 OF oDlg2 PIXEL;
					VALID If(Empty(cDesUsr:= QDXFNANMAN(cCodUsr,.T.)),;
							(Help(" ",1,"QD050PNE"),oDesUsr:Refresh(),.F.),; // "Pasta nao existe"
							(oDesUsr:Refresh(),.T.))
EndIf

@ 025,006 MSGET oDesUsr VAR cDesUsr SIZE 100,008 OF oDlg2 PIXEL
oDesUsr:lReadOnly:= .T.

DEFINE SBUTTON FROM 041,135 TYPE 1 ENABLE OF oDlg2;
			ACTION (nOpcao1:= 1,oDlg2:End())

DEFINE SBUTTON FROM 041,165 TYPE 2 ENABLE OF oDlg2;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

If nOpcao1 == 1
	If cTpDest == "D"
		If (nPos:= aScan(aUsrs,{|x| x[4]+x[6] == cFilUsr+cCodUsr} )) > 0
			oQDG:nAt:= nPos
			oQDG:Refresh()
			Else
			Help(" ",1,"QD053USRNE") //"Usuario Destino nao cadastrado neste Documento"
		EndIf
	ElseIf cTpDest == "P"
		If (nPos:= aScan(aUsrs,{|x| x[11] == Left(cCodUsr,15)} )) > 0
			oQDG:nAt:= nPos
			oQDG:Refresh()
		Else
			Help(" ",1,"QD053PSTNE") //"Pasta Destino nao cadastrada neste Documento"
		EndIf
	EndIf
EndIf
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD53CopDest³ Autor ³ Eduardo de Souza     ³ Data ³ 22/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia Destinos de um Docto existente.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD53CopDest(ExpA1,ExpA2,ExpA3,ExpO1,ExpB1,ExpB2,ExpO2,     ³±±
±±³          ³             ExpB3,ExpB4,ExpA4)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ ExpA1 - Array contendo os Destino                          ³±±
±±³          ³ ExpA2 - Array contendo os Destinatarios                    ³±±
±±³          ³ ExpA3 - Array contendo os Destinatarios                    ³±±
±±³          ³ ExpO1 - Objeto Departamento Destino                        ³±±
±±³          ³ ExpB1 - Bloco Departamento Destino                         ³±±
±±³          ³ ExpB2 - Bloco Departamento Destino                         ³±±
±±³          ³ ExpO2 - Objeto Destinatarios                               ³±±
±±³          ³ ExpB3 - Bloco Destinatarios                                ³±±
±±³          ³ ExpB4 - Bloco Destinatarios                                ³±±
±±³          ³ ExpA4 - Array contendo os Departamentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA053                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53CopDest(aDeptos)
Local oDlg
Local oDocOrig
Local oRevOrig
Local oTitOrig
Local cDocOrig := Space(TamSX3("QDH_DOCTO")[1])
Local cRevOrig := Space(TamSX3("QDH_RV")[1])
Local cTitOrig := Space(TamSX3("QDH_TITULO")[1])
Local nOpcao   := 0
Local nPosQDH  := QDH->(RecNo())
Local nOrdQDH  := QDH->(IndexOrd())
Local nI       := ""
Local aQDH     := {}
Local lAuxInc  := Inclui
Local cRet	   := ""
Local aAreaSXB := {}
Private lTrat  := GetMv("MV_QDOQDG",.T.,.F.)

DbSelectArea("QDH")
For nI := 1 To FCount()
	aADD(aQDH,M->&(Eval(bCampo,nI)))
Next nI	

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0033) FROM 000,000 TO 185,595 OF oMainWnd PIXEL // "Copia Destino"
oScroll := TScrollBox():new(oDlg,020,015,070,280,.T.,.T.,.T.)

@ 026, 003 SAY OemToAnsi(STR0034) SIZE 060,010 OF oScroll PIXEL // "Documento Origem"
@ 026, 054 MSGET oDocOrig VAR cDocOrig F3 "QDT" SIZE 070,007 OF oScroll PIXEL;
			VALID FQD53VLDCD(cDocOrig,@cRevOrig,@cTitOrig)
//			VALID (cTitOrig:= Posicione("QDH",1,xFilial("QDH")+cDocOrig+cRevOrig,"QDH_TITULO"))

@ 026, 130 SAY RetTitle("QDH_RV") SIZE 025,007 OF oScroll PIXEL // "Revisao"
@ 026, 155 MSGET oRevOrig VAR cRevOrig SIZE 015,007 OF oScroll PIXEL
oRevOrig:lReadOnly:= .T.

@ 040, 003 SAY RetTitle("QDH_TITULO") SIZE 025,007 OF oScroll PIXEL // "Revisao"
@ 039, 054 MSGET oTitOrig VAR cTitOrig SIZE 180,007 OF oScroll PIXEL
oTitOrig:lReadOnly:= .T.
oDocOrig:bChange:= {|| (oRevOrig:cText:=cRevOrig,oTitOrig:cText:=cTitOrig) }

@ 075,235 BUTTON oBtn1 PROMPT OemToAnsi(STR0035) SIZE 050,011 OF oDlg PIXEL; // "Cadastro"
			ACTION If(!Empty(cDocOrig) .And. !Empty(cRevOrig),QD050Telas("QDH",QDH->(RecNo()),2),)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcao:= 1,oDlg:End()}, {||oDlg:End()}) CENTERED

DbSelectArea("QDH")
QDH->(DbSetOrder(nOrdQDH))
QDH->(DbGoto(nPosQDH))
For nI := 1 To Len(aQDH)
	M->&(Eval(bCampo,nI)):= aQDH[nI]
Next nI

Inclui:= lAuxInc

If nOpcao == 1
	If MsgYesNo(OemToAnsi(STR0036)+" "+AllTrim(cDocOrig)+"/"+cRevOrig+" ?",OemToAnsi(STR0033)) // "Deseja realizar a copia do(s) destino(s) do documento" ### "Copia Destino"
		MsgRun(OemToAnsi(STR0017),OemToAnsi(STR0031),{|| QD53GrvCop(cDocOrig,cRevOrig,@aDeptos)}) // "Carregando Destinatarios do Documento..." ### "Aguarde..."
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD53GrvCop ³ Autor ³ Eduardo de Souza     ³ Data ³ 23/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Copia de Destinos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD53GrvCop(ExpC1,ExpC2,ExpA1,ExpA2,ExpA3,ExpO1,ExpB1,ExpB2,³±±
±±³          ³ 			  ExpO2,ExpB3,ExpB4,ExpA4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Documento Origem                                   ³±±
±±³          ³ ExpC2 - Revisao Documento Origem                           ³±±
±±³          ³ ExpA1 - Array contendo os Destino                          ³±±
±±³          ³ ExpA2 - Array contendo os Destinatarios                    ³±±
±±³          ³ ExpA3 - Array contendo os Destinatarios                    ³±±
±±³          ³ ExpO1 - Objeto Departamento Destino                        ³±±
±±³          ³ ExpB1 - Bloco Departamento Destino                         ³±±
±±³          ³ ExpB2 - Bloco Departamento Destino                         ³±±
±±³          ³ ExpO2 - Objeto Destinatarios                               ³±±
±±³          ³ ExpB3 - Bloco Destinatarios                                ³±±
±±³          ³ ExpB4 - Bloco Destinatarios                                ³±±
±±³          ³ ExpA4 - Array contendo os Departamentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA053                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53GrvCop(cDocOrig,cRevOrig,aDeptos)

Local nOrdQDJ  := QDJ->(IndexOrd())
Local nOrdQDG  := QDG->(IndexOrd())
Local cFilDep  := xFilial("QAD")
Local aAuxQDG  := {}
LocaL cQuery  := ""
Local cMatQAD := Space(TamSx3("QAD_MAT")[1])

//Array aQDJDoc
//1 - QDJ->QDJ_FILIAL
//2 - QDJ->QDJ_DOCTO
//3 - QDJ->QDJ_RV
//4 - QDJ->QDJ_FILMAT
//5 - QDJ->QDJ_DEPTO
//6 - QDJ->QDJ_TIPO,
//7 - Descricao Tipo do Usuario
//8 - Descricao do Depto

cQuery := "     SELECT QDJ.QDJ_FILIAL,QDJ.QDJ_DOCTO,QDJ.QDJ_RV,QDJ.QDJ_FILMAT,QDJ.QDJ_DEPTO,QDJ.QDJ_TIPO, QAD.R_E_C_N_O_ "
cQuery += "       FROM " + RetSqlName("QDJ")+" QDJ " 
cQuery += " INNER JOIN " + RetSqlName("QAD")+" QAD "
cQuery += "         ON QAD.QAD_CUSTO = QDJ.QDJ_DEPTO "
cQuery += "        AND QAD.D_E_L_E_T_ <> '*' "		
cQuery += "      WHERE QDJ.QDJ_FILIAL = '"+M->QDH_FILIAL+"' 
cQuery += "        AND QDJ.QDJ_DOCTO = '"+cDocOrig+"' 
cQuery += "        AND QDJ.QDJ_RV = '"+cRevOrig+"' "	
cQuery += "        AND QDJ.D_E_L_E_T_ <> '*' "

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,6,4,5"
Else
	cQuery += " ORDER BY " + SqlOrder("QDJ_FILIAL+QDJ_DOCTO+QDJ_TIPO+QDJ_FILMAT+QDJ_DEPTO")
Endif

cQuery := ChangeQuery(cQuery)			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDJ",.T.,.T.)	

While TMPQDJ->(!Eof())                                         
   	If FWModeAccess("QAD")=="E" //! Empty(xFilial("QAD"))	
   		cFilDep := TMPQDJ->QDJ_FILMAT
   	EndIf      
   	IF TMPQDJ->QDJ_TIPO == "P"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Garante o Responsavel pelo Depto quando tipo pasta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAD->(DBSeeK(cFilDep+TMPQDJ->QDJ_DEPTO))
			cMatQAD:= QAD->QAD_MAT
			IF Empty(cMatQAD) 												
				Help(" ",1,"QD050CCNER",,TMPQDJ->QDJ_DEPTO,5,0)	// Nao existe Responsavel para Depto ou esta Demitido
				IF lAltDoc .AND. M->QDH_STATUS != "L  "
					While Empty(cMatQAD) 
						cMatQAD:= QD053InQDG('',cFilDep,TMPQDJ->QDJ_DEPTO,QAD->QAD_FILMAT)
					Enddo	                            
				EndIF
			Endif				
		EndIf
 	Endif
	aAuxQDG := QD050CDQDG()
	If Len(aAuxQDG) > 0
		   	Aadd(aQDJDoc,{TMPQDJ->QDJ_FILIAL,TMPQDJ->QDJ_DOCTO,TMPQDJ->QDJ_RV,TMPQDJ->QDJ_FILMAT,TMPQDJ->QDJ_DEPTO,TMPQDJ->QDJ_TIPO,;
		                 If(TMPQDJ->QDJ_TIPO == "D",OemToAnsi(STR0016),If(TMPQDJ->QDJ_TIPO == "P",OemToAnsi(STR0007),Space(5))),;  //"Usuario"###"Pasta"
		                 QA_NDEPT(TMPQDJ->QDJ_DEPTO,.T.,cFilDep),aAuxQDG, TMPQDJ->R_E_C_N_O_})
	Endif
   	TMPQDJ->( DbSkip() )
Enddo               
TMPQDJ->(DBCLOSEAREA())
DbSelectArea("QDJ")  	    

QDG->(DbSetOrder(nOrdQDG))
QDJ->(DbSetOrder(nOrdQDJ))

QD053LeQDJ(@aDeptos)
QD53AtArray(1) // Posicionar no primeiro depto

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053MRLed ³ Autor ³ Telso Carneiro             ³ Data ³ 11/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca os destinatarios verificando a situacao na Folha   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053MRLed( cChave )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD053MRLed( nItem,aQDGAux ) 
Local cChave 	:= ""
Local cFilDep 	:= xFilial("QAD")
Local oOk      	:= LoadBitmap( GetResources(), "ENABLE" )
Local oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Local oDemt	   	:= LoadBitmap( GetResources(), "BR_VERMELHO" )  //Demitido durante o processo de Elaboracao
Local oPInat   	:= LoadBitmap( GetResources(), "BR_AZUL" )  //Pasta inativa durante o processo de Elaboracao
Local oReturn  	:= oOk
Local cFilQDC  := ""

If aQDGAux[nItem,10] == "D"
	cChave := aQDGAux[nItem,4]+aQDGAux[nItem,6]
	QAA->(dbSetOrder(1))
	IF QAA->(DBSeeK(cChave))
		IF !QA_SitFolh()
			oReturn:=oDemt
		Endif
	ENDIF
Else   
	If FWModeAccess("QAD")=="E" //!Empty(cFilDep)
		cFilDep := aQDGAux[nItem,4]
	Endif
	QAD->(DbSetOrder(1))
	If QAD->(DBSeeK(cFilDep+aQDGAux[nItem,5]))
		If !Empty(QAD->QAD_FILMAT) .And. !Empty(QAD->QAD_MAT)
			cChave := QAD->QAD_FILMAT+QAD->QAD_MAT	
			QAA->(dbSetOrder(1))
			IF QAA->(DBSeeK(cChave))
				IF !QA_SitFolh()
					oReturn:=oDemt
				Endif
			Endif		
		Else
			oReturn:=oNo				
		Endif		
	Endif
	cFilQDC:= xFilial("QDC")
    If FWModeAccess("QDC")=="E" .And. FWModeAccess("QAD")=="E" //!Empty(cFilQDC) .and. !Empty(cFilDep)
    	cFilQDC:= cFilDep
    EndIf

	cChave:=cFilQDC+aQDGAux[nItem,11] //Pasta
	QDC->(DbSetOrder(1))
	IF QDC->(DBSeek(cChave))
		IF QDC->QDC_STATUS=="2"
			oReturn:=oPInat         
	    Endif
	Endif	
Endif	

 
Return (oReturn)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD053Legen ³ Autor ³ Telso Carneiro       ³ Data ³ 11/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD053Legen                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA053()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD053Legen()

Local aCores := { {'ENABLE'     , OemtoAnsi(STR0040) },; //"Usuario Marcado"
                  {'LBNO'       , OemtoAnsi(STR0041)},;	 //"Usuario Desmarcado"
                  {'BR_VERMELHO', OemtoAnsi(STR0042)} }  //"Usuario Inativado"
                
Local cTitulo := OemToAnsi(STR0003)
Local cMensagem := OemToAnsi(STR0039) 	 //"Legenda"
Local ny       := 0
Local nx       := 0
Local aBmp     :={}
Local aSays	   :={}
Local oDlgLeg

Aadd(aCores,{"BR_AZUL"    , OemtoAnsi(STR0058)})  //"Pasta Inativada"	

aBmp :=Array(Len(aCores))
aSays:=Array(Len(aCores))

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+75,304 TITLE cTitulo PIXEL
@ 00,00 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
@ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009
For nx := 1 to Len(aCores)
	@ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aCores[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 19+((nx-1)*10),54 SAY If((ny+=1)==ny,aCores[ny][2]+If(ny==Len(aCores),If((ny:=0)==ny,"",""),""),"") of oDlgLeg PIXEL
Next
ny := 0

DEFINE SBUTTON FROM 25+((nx-1)*10),124 TYPE 1 ENABLE OF oDlgLeg ACTION oDlgLeg:End()

ACTIVATE MSDIALOG oDlgLeg CENTERED

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD053VLD  ºAutor  ³Telso Carneiro      º Data ³  25/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a Gravacao da Filial do Usuario Resposavel (PASTA)  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD053VLD(cFilUsr,cDepFil)
Local lRet	 :=.T.

IF FWModeAccess("QAD")=="E" //!EMPTY(xFilial("QAD"))
	IF cDepFil!=cFilUsr
		Help("",1,"QADFILDIF",,OemtoAnsi(STR0045)+CHR(13)+;   //"Devido a Configuração de (Filial Exclusiva)"
				               OemtoAnsi(STR0046)+CHR(13)+;    //" do Depto,Não é permitido o Cadastro"
				               OemtoAnsi(STR0047),1,0)   //" de Responsavel de Filial diferente da Depto"
		lRet:= .F.
	ENDIF
Endif

REturn(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ FQD53VLDCD ³ Autor ³ Aldo Marini Junior         ³ Data ³ 24/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Valida o documento a ser copiado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ FQD53VLDCD(cDocOrig,cRevOrig,cTitOrig)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Caracter contendo codigo do documento                     ³±±
±±³           ³ ExpC2 - Caracter contendo revisao do documento                    ³±±
±±³           ³ ExpC3 - Caracter contendo titulo do documento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function FQD53VLDCD(cDocOrig,cRevOrig,cTitOrig)
Local lRet := .F.
Local cRet := ""
Local lFCOPDST := Existblock("QD53FCOPDST")

If lFCOPDST
	cRet := Execblock("QD53FCOPDST",.F.,.F.)
Endif

If QDH->(dbSeek(xFilial("QDH")+cDocOrig))
	While QDH->(!Eof()) .And. xFilial("QDH")+cDocOrig == QDH->QDH_FILIAL+QDH->QDH_DOCTO
		If lFCOPDST
			If !Empty(cRet)
				If &(cRet) 
					cRevOrig := QDH->QDH_RV
					cTitOrig := QDH->QDH_TITULO
					lRet := .T.
					Exit
				Endif
			Else
				// Sem filtro
				cRevOrig := QDH->QDH_RV
				cTitOrig := QDH->QDH_TITULO
				lRet := .T.
			Endif
		Else
			If QDH->QDH_CANCEL <> "S" .AND. QDH->QDH_OBSOL <> "S" .AND. QDH->QDH_STATUS =="L  "
				cRevOrig := QDH->QDH_RV
				cTitOrig := QDH->QDH_TITULO
				lRet := .T.
				Exit
			Endif
		Endif
		QDH->(dbSkip())
	Enddo
	If !lRet
		If Empty(cRevOrig)
		   Help( " ", 1, "QDNEXISREV" )	// Nao existe revisao vigente
		Endif
	Endif
Else
	Help(" ",1,"QD120DNE") //"Documento nao encontrado."
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053FtMRc ³ Autor ³ Telso Carneiro				³ Data ³09/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Filtrar os destinatarios marcados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053FtMRc( aQDG )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD053FtMRc(aQDJDox,aQDGFt,lFiltro)

Local nPos  := 0

IF !lFiltro 
	aQDGFt:={}
	For nPos:= 1 to Len(aQDJDox)
		IF aQDJDox[nPos,9] == "S"				
			AADD(aQDGFt,aQDJDox[nPos])
			AADD(aQDGFt[Len(aQDGFt)],nPos)
		Endif
	Next nPos
	
	oQDG:SetArray(aQDGFt)
	oQDG:nAt:=1
	oQDG:bLine:= If(Len(aQDGFt)>0,bQDGFLin,bQDGLine2)
	oQDG:Refresh()
Else
	oQDG:SetArray(aQDJDox)
	oQDG:nAt:=1
	oQDG:bLine:= If(Len(aQDJDox)>0,bQDGLine1,bQDGLine2)
	oQDG:Refresh()
Endif

lFiltro:=!lFiltro


Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD053DBLcl ³ Autor ³ Telso Carneiro				³ Data ³10/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ DblClick para Marcar/Desmacar os destinatarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD053DBLcl(lFiltro,aQDG,aQDGFt,oQDG,bQDGFLin,bQDGLine1,bQDGLine2) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function QD053DBLcl(lFiltro,aQDGFt)
Local nPos  := 0

IF lFiltro	
    IF Len(aQDGFt) > 0
		aQDGFt[oQDG:nAt,9]:= If(aQDGFt[oQDG:nAt,9] == "S","N","S")
		oQDG:SetArray( aQDGFt )
		oQDG:bLine:= If(Len(aQDGFt)>0,bQDGFLin,bQDGLine2)
	
		For nPos:= 1 to Len(aQDGFt)
			IF aQDGFt[nPos,9] == "N"								
				QD053MdRcb(@aQDJDoc[oQDJ:nAt,9],aQDGFt[nPos][Len(aQDGFt[nPos])] )			
			Endif
		Next 	            
	Endif	                     
	oQDG:Refresh()               
Else
	If Type ("aQDJDoc[oQDJ:nAt,9]") == "U"
		oQDG:SetArray( aQDJDoc )
		oQDG:bLine:= {|| {}}
		oQDG:Refresh()    
	   Return
	Else
		QD053MdRcb( @aQDJDoc[oQDJ:nAt,9],oQDG:nAt )
		oQDG:SetArray( aQDJDoc[oQDJ:nAt,9] )
		oQDG:bLine:= If(Len(aQDJDoc[oQDJ:nAt,9])>0,bQDGLine1,bQDGLine2)	
		oQDG:Refresh()    
	Endif           
Endif

Return	



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD53CarCar ³ Autor ³ Telso Carneiro             ³ Data ³ 06/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Carrega Departamentos para Selecao no Cadastro de Usuarios/Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD53CarCar(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro  ³ ExpA1 - Array Contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA053()                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD53CarCar(aCargos)
Local aArea    := GetArea()
Local cQuery   := ""
Local ic       := 0
Local iT       := 0
Local lQacComp := FWModeAccess("QAC")=="C" //Empty(xFilial("QAC")) //QAC - Compartilhado
Local lQadComp := FWModeAccess("QAD")=="C" //Empty(xFilial("QAD")) //QAD - Compartilhado
Local nCont    := 0
Local nPos     := 0
Local nPosCar  := 0

aCargos:={}
CursorWait()
		
cQuery :=" SELECT DISTINCT QAC.QAC_FILIAL, QAA.QAA_CODFUN, QAA.QAA_CC ,QAC.QAC_DESC "
cQuery +=" FROM " + RetSqlName("QAA") +" QAA , "+RetSqlName("QAC") +" QAC "
cQuery +=" WHERE "+QA_FilSitF(.T.,.T.)	
cQuery +=" AND QAA.QAA_CODFUN = QAC.QAC_FUNCAO "
cQuery +=" AND QAA.D_E_L_E_T_ <> '*' AND QAC.D_E_L_E_T_ <> '*' AND QAA.QAA_STATUS <> '2'"
	 
If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,3"
Else
	cQuery += " ORDER BY " + SqlOrder("QAC_FILIAL+QAA_CODFUN+QAA_CC")
Endif

cQuery := ChangeQuery(cQuery)			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
  
TMPQAA->(DbGoTop()) 
While TMPQAA->(!Eof())		                   
    If (nPosCar:=AsCan(aCargos,{|x| x[2]+x[3]==TMPQAA->QAC_FILIAL+TMPQAA->QAA_CODFUN})) == 0
		Aadd(aCargos,{"N",TMPQAA->QAC_FILIAL,TMPQAA->QAA_CODFUN,TMPQAA->QAC_DESC,{{TMPQAA->QAC_FILIAL,TMPQAA->QAA_CC,"N"}}})
	Else							
	    Aadd(aCargos[nPosCar,5],{TMPQAA->QAC_FILIAL,TMPQAA->QAA_CC,"N"})
	Endif
	TMPQAA->(DbSkip())
Enddo
TMPQAA->(DBCLOSEAREA())	    	    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marcar Funcoes atraves dos Usuarios QDG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ic:=1 To Len(aCargos)
	For iT:=1 To Len(aCargos[ic,5])
		//aQDJDoc
		IF (nPos:= aScan(aQDJDoc,{|x| IF(lQadComp,x[6]+x[5] == "D"+aCargos[ic,5,iT,2],x[6]+X[4]+x[5] == "D"+aCargos[ic,5,iT,1]+aCargos[ic,5,iT,2])   } )) > 0
			IF (nPosCar:=Ascan(aQDJDoc[nPos,9],{|x| IF(lQacComp,x[9]+x[15]=="S"+aCargos[ic,3],x[9]+x[1]+x[15]=="S"+aCargos[ic,2]+aCargos[ic,3])}) ) >0
				aCargos[ic,5,iT,3]:="S"
			Endif
		Endif
	Next
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica Funcoes Completos "S" ou parciais "P" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ic:=1 To Len(aCargos)
	nCont:=0
	aEval(aCargos[ic,5],{|x| nCont+=IF(x[3]=="S",1,0)})
	IF nCont<>0
		aCargos[ic,1]:=IF(nCont==Len(aCargos[ic,5]),"S","P")
	Endif
Next

CursorArrow() 

RestARea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53MRCar  ³ Autor ³ Telso Carneiro             ³ Data ³ 07/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca as Funcoes                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53MRCar(ExpA1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as Funcoes                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD53MRCar(aCargos,lDbCli,nPosCar,aDeptos)

Local nCnt  	:= 0
Local i			:= 0
Local iT		:= 0
Local cFilDep	:=Space(FWSizeFilial())
Local cCodDep	:=""                     
Local nCont		:=0
Local aTpDestino:= {.F.,.F.}
Local lUsuario  := .F.
Local lPasta    := .F.
Local lCargo	:= .T.
Local aAuxCargo	:= {}
Local nPosDep   := 0
Local nPosAux	:= 0

IF lDbCli	
	IF aCargos[nPosCar,1]=="N"
		aTpDestino:= QD53TPCop(lUsuario,lPasta,lCargo)
		
		If aTpDestino[1]		
			aCargos[nPosCar,1]:="S"                        
			aEval(aCargos[nPosCar,5],{|x| x[3]:="S"})
		Endif
	Else
		aCargos[nPosCar,1]:="N"                      
		aEval(aCargos[nPosCar,5],{|x| x[3]:="N"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica Funcoes Completos "S" ou parciais "P" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i:=1 To Len(aCargos)
		nCont:=0
		aEval(aCargos[i,5],{|x| nCont+=IF(x[3]=="S",1,0)})
		IF nCont==0
			aCargos[i,1]:="N"
		Else
			aCargos[i,1]:=IF(nCont==Len(aCargos[i,5]),"S","P")
		Endif
	Next
	lAltQDJ:= .T.
Else
	
	If Len(aCargos) > 0
		nC:= Ascan(aCargos,{ |X| x[1] == "S" .OR. x[1] == "P" } )
		
		IF nC == 0
			aTpDestino:= QD53TPCop(lUsuario,lPasta,lCargo)
			If !aTpDestino[1]
				nC:=1
			Endif
		Endif
		
		For nCnt:= 1 to Len(aCargos)
			If nC <> 0
				aCargos[nCnt,1]:= "N"
				aEval(aCargos[nCnt,5],{|x| x[3]:="N" })
			Else
				aCargos[nCnt,1]:= "S"
				aEval(aCargos[nCnt,5],{|x| x[3]:="S" })
			EndIf
		Next nCnt
		lAltQDJ:= .T.
	EndIf
	
Endif

//ÚÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o Departamentos aDeptos³
//ÀÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 To Len(aCargos)
	For iT:=1 To Len(aCargos[i,5])
		IF (nPosAux:=Ascan(aAuxCargo,{|x| x[1]+x[2]==aCargos[i,5,iT,1]+aCargos[i,5,iT,2]}))==0
			Aadd(aAuxCargo,{aCargos[i,5,iT,1],aCargos[i,5,iT,2],aCargos[i,5,iT,3]})
		Else	
			IF aCargos[i,5,iT,3]=="S" 
				aAuxCargo[nPosAux,3]:=aCargos[i,5,iT,3]
			Endif
		Endif
	Next
Next

For iT:=1 To Len(aAuxCargo)
	IF (nPosDep:= Ascan(aDeptos,{|x| x[2]+x[3]==aAuxCargo[iT,1]+aAuxCargo[iT,2]})) > 0
		IF aAuxCargo[iT,3]=="S"
			aDeptos[nPosDep,1]:="S"
			aDeptos[nPosDep,5]:="S"
		Else			
			aDeptos[nPosDep,5]:="N"  //Eletronica
			IF aDeptos[nPosDep,6]=="N" //Papel
				aDeptos[nPosDep,1]:="N"
			Else
				aDeptos[nPosDep,1]:="S"				
			Endif
		Endif
	Endif
Next

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD053LeCar ³ Autor ³ Telso Carneiro       ³ Data ³ 11/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD053LeCar                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA053()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD053LeCar()

Local aCores := { {'ENABLE'     , OemtoAnsi(STR0050) },;  //"Funcao Marcado com Deptos Completos"
                  {'LBNO'       , OemtoAnsi(STR0051)},;	  //"Funcao Desmarcado"
                  {'BR_AMARELO' , OemtoAnsi(STR0052)} }   //"Funcao Marcado com Deptos Parcial"

Local cTitulo := OemToAnsi(STR0053) //"Destinatarios - Funcoes"
Local cMensagem := OemToAnsi(STR0039) 	 //"Legenda"
Local ny       := 0
Local nx       := 0
Local aBmp[Len(aCores)]
Local aSays[Len(aCores)]
Local oDlgLeg1

DEFINE MSDIALOG oDlgLeg1 FROM 0,0 TO (Len(aCores)*20)+75,304 TITLE cTitulo PIXEL
@ 00,00 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgLeg1 SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11,35 TO 013,400 LABEL '' OF oDlgLeg1 PIXEL
@ 03,37 SAY cMensagem OF oDlgLeg1 PIXEL SIZE 100,009
For nx := 1 to Len(aCores)
	@ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aCores[nx][1] of oDlgLeg1 SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 19+((nx-1)*10),54 SAY If((ny+=1)==ny,aCores[ny][2]+If(ny==Len(aCores),If((ny:=0)==ny,"",""),""),"") of oDlgLeg1 PIXEL
Next
ny := 0

DEFINE SBUTTON FROM 25+((nx-1)*10),124 TYPE 1 ENABLE OF oDlgLeg1 ACTION oDlgLeg1:End()

ACTIVATE MSDIALOG oDlgLeg1 CENTERED

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD53PesqCar³ Autor ³ Eduardo de Souza           ³ Data ³ 15/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Departamento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD53PesqDep(ExpO1,ExpA1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Departamentos                                      ³±±
±±³           ³ ExpA1 - Array contendo os departamentos                           ³±±
±±³           ³ ExpN1 - Tipo de Array (aQDJ/aDeptos)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA053                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD53PesqCar(oCargos,aCargos)
Local oDlg4
Local oFilCar
Local oCodCar
Local oDesCar
Local cFilCar := xFilial("QAC")
Local cCodCar := Space(TamSX3("QAC_FUNCAO")[1])
Local cDesCar := Space(TamSX3("QAC_DESC")[1])
Local nOpcao1 := 0
Local nPos    := 0

DEFINE MSDIALOG oDlg4 TITLE OemToAnsi(STR0054) FROM 000,000 TO 110,420 OF oMainWnd PIXEL  //"Pesquisa Funcao"

@ 003,003 TO 040,208 LABEL OemToAnsi(STR0055) OF oDlg4 PIXEL  //"Funcao"

@ 010,006 MSGET oFilCar VAR cFilCar PICTURE REPL("@!",FWSizeFilial()) F3 "SM0_01" SIZE 070,008 OF oDlg4 PIXEL;
          VALID QA_CHKFIL(cFilCar,@cFilCar) WHEN FWModeAccess("QAC")=="E" //! Empty(cFilCar)

@ 010,085 MSGET oCodCar VAR cCodCar PICTURE '@!' F3 "QAC" SIZE 122,008 OF oDlg4 PIXEL;
				VALID If(Empty(cDesCar:= QA_NFUNC(cCodCar,.T.,cFilCar)),;
						(HELP(' ',1,'EXISTEUSR'),oDesCar:Refresh(),.F.),; // "Funcao nao existe"
						(oDesCar:Refresh(),.T.))

@ 025,006 MSGET oDesCar VAR cDesCar SIZE 100,008 OF oDlg4 PIXEL
oDesCar:lReadOnly:= .T.


DEFINE SBUTTON FROM 041,130 TYPE 1 ENABLE OF oDlg4;
			ACTION (nOpcao1:= 1,oDlg4:End())

DEFINE SBUTTON FROM 041,160 TYPE 2 ENABLE OF oDlg4;
			ACTION oDlg4:End()

ACTIVATE MSDIALOG oDlg4 CENTERED	

If nOpcao1 == 1
	If (nPos:= aScan(aCargos,{|x| x[2]+x[3] == cFilCar+cCodCar} )) > 0
		oCargos:nAt:= nPos
		oCargos:Refresh()
	EndIf	
	If nPos == 0
		HELP(' ',1,'EXISTEUSR') // "Funcao nao existe"
	EndIf
EndIf
 
Return

/*/{Protheus.doc} fVerUsrRes(aQDGAux[nPos])
Valida se o usuario é responsavel pelo departamento de distribuição do tipo de documento	
@type  Static Function
@author rafael.kleestadt
@since 07/06/2019
@version 1.0
@param aUsrPosic, array, array com a chave de busca na QAD
@return lRet, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fVerUsrRes(aUsrPosic)
Local aAreaQAD := QAD->(GetArea())
Local lRet     := .T.

	DbSelectArea("QAD")
	DbSetOrder(1) //QAD_FILIAL+QAD_CUSTO
	If QAD->(DbSeek(M->(QDH_FILDEP+QDH_DEPTOD)))
		If QAD->(QAD_FILMAT+QAD_MAT) = aUsrPosic[4]+aUsrPosic[6]
			If !MsgYesNo( "O usuário "+AllTrim(aUsrPosic[13])+" é responsável pelo departamento "+AllTrim(QAD->QAD_DESC)+;
			              " que está configurado para distribuir este documento."+CHR(13)+CHR(10)+;
			              "Deseja realmente que esse usuário não receba uma cópia do documento?", "Usuário Responsável!" )
				lRet := .F.
			EndIf
		EndIf
	EndIf
	QAD->(DbCloseArea())

RestARea(aAreaQAD)
Return lRet

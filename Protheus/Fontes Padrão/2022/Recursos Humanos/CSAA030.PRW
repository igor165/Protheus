#include "dbtree.ch"
#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#INCLUDE "CSAA030.CH"

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CSAA030  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro das Pesquisas Salariais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³07/07/2014³TPZVTW³Incluido o fonte da 11 para a 12 e      ³±±
±±³            ³          ³      ³efetuada a limpeza.                     ³±±
±±³Matheus M.  ³15/12/2015³TTTSHQ³Incluso validação para que no momento   ³±±
±±³            ³          ³      ³de excluir uma pesquisa já montada seja ³±±
±±³            ³          ³      ³exibido um aviso com a opç Sim Não.	  ³±± 
±±³Oswaldo L    ³08-05-17³DRHPONTP11  ³Projeto SOYUZ ajuste Ctree         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAA030                                                         
Local cFiltra			// Variavel para filtro
Local aIndFil:= {}		// Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		// Variavel para Filtro
Private	aAC := {STR0001,STR0002}	//"Abandona"###"Confirma"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := { 	{ STR0003, 'PesqBrw', 0, 1}, ;	//'Pesquisar'
						{ STR0004, 'Cs030Rot', 0, 2}, ;	//'Visualizar'
						{ STR0005, 'Cs030Rot', 0, 3}, ;	//'Incluir'
						{ STR0006, 'Cs030Rot', 0, 4}, ;	//'Alterar'
						{ STR0007, 'Cs030Rot', 0, 5,3} }	//'Excluir'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro das Pesquisas Salariais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RB1")
dbSetOrder(1)
 
cFiltra 	:= CHKRH(FunName(),"RB1","1")
bFiltraBrw 	:= {|| FilBrowse("RB1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB1")
dbGotop()

mBrowse(6, 1, 22, 75, "RB1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RB1",aIndFil)

dbSelectArea("RB1")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs030Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que trata as funcoes para a Pesquisa Salarial       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs030Rot(cExpC1,nExpN1,nExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Rot(cAlias,nReg,nOpc)
Local oDlgMain
Local c1Lbx, c2Lbx
Local lTMarca, lTDesmarca
Local aPos	:= {14,84,145,310}
Local nOpca	:= 0         
Local i		:= 0
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {} 

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local aAdv31Size	:= {}
Local aInfo31AdvSize:= {}
Local aObj31Size	:= {}
Local aObj31Coords	:= {}

Local aAdv32Size	:= {}
Local aInfo32AdvSize:= {}
Local aObj32Size	:= {}
Local aObj32Coords	:= {}

Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}
Local aObj4Coords	:= {}

Local n

Private cTGet		:= Space(30)
Private cPesq		:= ""
Private cDescPesq	:= ""
Private cGet		:= ""

Private oArq1Tmp, oArq2Tmp, oArq3Tmp, oArq4Tmp
// Private dos Objetos da Tela
Private oEnchoice                                       
Private oSay1, oGet1
Private oSay2
Private o1Lbx, o1Group
Private o2Lbx, o2Group
Private oT1Grp, oT2Grp
Private o2Grp
Private oTGet, oTMarca, oTDesmarca
Private o1Btn, o2Btn
Private oNo, oOk

// Private da Enchoice
Private bCampo := {|nCPO| Field(nCPO) }
Private aTela[0][0],aGets[0]
Private cEstou:="1", cIndo:=""
Private cSay2
                      
If nOpc == 3
	cPesq 	 := CriaVar("RB1_PESQ")
	RollBackSX8()	//Retornar numeracao anterior devido criacao de var. Memoria abaixo.
	cDescPesq:= CriaVar("RB1_DESCRI")
Else
	cPesq 	 := RB1->RB1_PESQ
	cDescPesq:= RB1->RB1_DESCRI
EndIf        

cGet:= cPesq + " - "+ cDescPesq

// Seta Bitmap nas variaveis              
oNo 	:= LoadBitmap( GetResources(), "LBNO" )
oOk 	:= LoadBitmap( GetResources(), "LBOK" )

// Monta a enchoice da Pesquisa Salarial
If nOpc == 3	// Inclusao
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("RB1")
	While ( !Eof() .And. (SX3->X3_ARQUIVO == "RB1") )
		uCampo := SX3->X3_CAMPO
		M->&(uCampo) := CriaVar(SX3->X3_CAMPO)
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	        
	// Disposiciona o arquivo para nao aparecer na tela os campos virtuais
	// Qdo atualiza dados da enchoice traz os valores virtuais do que esta posicionado.
	dbSelectArea("RB1")
	dbGoBottom()
	dbSkip()
Else	
	uCampo := {|nCPO| Field(nCPO) }
	For i := 1 TO FCount()
		M->&(EVAL(uCampo,i)) := FieldGet(i)
	Next i
EndIf	

// Cria arquivos para todos os listboxs
Cs030CriaArq()

// Monta ListBox das Empresas Participantes da Pesquisa Salarial - RB0
Cs030Monta(1,nOpc)

// Monta ListBox das Funcoes da Pesquisa Salarial - SRJ
Cs030Monta(2,nOpc)

// Monta ListBox do Ramo de Atividade - SX5(RD)
Cs030Monta(3,nOpc)

// Monta ListBox do Faturamento - SX5(RE)
Cs030Monta(4,nOpc)

// Posiciona os arquivos no comeco do arquivo
dbSelectArea("TR1")
dbGotop()

dbSelectArea("TR2")
dbGotop()

dbSelectArea("TR3")
dbGotop()

dbSelectArea("TR4")
dbGotop()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 100 , 000 , .F. , .T. } )			//1-Tree
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )			//2-Dados
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords,, .T. )


aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }					 
aAdd( aObj1Coords , { 000 , 018 , .T. , .F. } )		//1-Cabec
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//2-Enchoice	
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }					 
aAdd( aObj2Coords , { 040 , 000 , .F. , .T. } )		//1-Say - Pesquisa Salarial
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )		//2-Get - Pesquisa salarial	
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

aAdv3Size		:= aClone(aObj1Size[2])
aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 1 , 1 }					 
aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )		//1-Group
aAdd( aObj3Coords , { 098 , 000 , .F. , .T. } )		//2-Coluna Controles 
aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )

aAdv31Size		:= aClone(aObj3Size[1])
aInfo31AdvSize	:= { aAdv31Size[2] , aAdv31Size[1] , aAdv31Size[4] , aAdv31Size[3] , 5 , 10}					 
aAdd( aObj31Coords , { 000 , 000 , .T. , .T. , .T. } )	//1-ListBox
aObj31Size		:= MsObjSize( aInfo31AdvSize , aObj31Coords )

aAdv32Size		:= aClone(aObj3Size[2])     		//Controles
aInfo32AdvSize	:= { aAdv32Size[2] , aAdv32Size[1] , aAdv32Size[4] , aAdv32Size[3] , 1 , 1 }					 
aAdd( aObj32Coords , { 000 , 030 , .T. , .F. } )  		//1-Todos
aAdd( aObj32Coords , { 000 , 030 , .T. , .F. } )		//2-Pesquisa
aAdd( aObj32Coords , { 000 , 040 , .T. , .F. } )  		//3-Definir Parametros
aAdd( aObj32Coords , { 000 , 000 , .T. , .T. } )		//4-Espaco
aObj32Size		:= MsObjSize( aInfo32AdvSize , aObj32Coords )

//Divisao em colunas dos Controles, para centralizacao
aAdv4Size		:= aClone(aObj32Size[3])
aInfo4AdvSize	:= { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 1 , 10 }					 
aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )			
aAdd( aObj4Coords , { 046 , 000 , .F. , .T. } )	
aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )   
aObj4Size	:= MsObjSize( aInfo4AdvSize , aObj4Coords,,.T. )




DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	//Tree
	DEFINE DBTREE oTree FROM aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] CARGO OF oDlgMain;
		ON CHANGE (Cs030Principal(oTree))

	oTree:bValid := {|| Cs030VlTree(nOpc) }
	oTree:lValidLost := .f.
	oTree:lActivated := .T.

	DBADDTREE oTree PROMPT OemToAnsi(STR0018)+Space(6);			//"Cadastrar Pesquisa"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "1"
	DBENDTREE oTree

	DBADDTREE oTree PROMPT OemToAnsi(STR0019);			//"Selecionar Participantes"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "2"
	DBENDTREE oTree

	DBADDTREE oTree PROMPT OemToAnsi(STR0020);						//"Selecionar Funcoes"
	RESOURCE "FOLDER5","FOLDER6";
	CARGO "3"
	DBENDTREE oTree
	
	// ListBox - Selecionar Empresas Participantes
	dbSelectArea("TR1")	                             
	@ aObj3Size[1,1],aObj3Size[1,2] GROUP o1Group	TO aObj3Size[1,3],aObj3Size[1,4] LABEL OemtoAnsi(STR0022) PIXEL OF oDlgMain 		//"Participantes"
	@ aObj31Size[1,1],aObj31Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS;
	 	HEADER 	"",;
	 			OemtoAnsi(STR0023),;	//"Razao Social"
				OemtoAnsi(STR0024),;	//"Cod Empresa"
				OemtoAnsi(STR0025),;	//"Ramo Atividade"
				OemtoAnsi(STR0026),;	//"Faturamento"
				OemtoAnsi(STR0027);		//"Nr. Func" 
		COLSIZES 	GetTextWidth(0,"W"),;
					GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
					GetTextWidth(0,"BBBBB"),;
					GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
					GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
					GetTextWidth(0,"BBBBBB") SIZE aObj31Size[1,3],aObj31Size[1,4]+5 OF oDlgMain PIXEL;
	ON DBLCLICK (Cs030Marca(nOpc,.F.,0,oTree:GetCargo())) 
	o1Group:Hide()
	o1Lbx:Hide()
	o1Lbx:bLine:= {||{If(	TR1->TR1_MARCA==1,oOk,oNo),;
							TR1->TR1_NOME,;
							TR1->TR1_EMPRES,;
							TR1->TR1_DESCRA,;
							TR1->TR1_DESCFA,;                                       	
							TR1->TR1_NRFUNC}}


	// ListBox - Selecionar os Funcoes
	dbSelectArea("TR2")	                             
	@ aObj3Size[1,1],aObj3Size[1,2] GROUP o2Group  TO aObj3Size[1,3],aObj3Size[1,4] LABEL OemtoAnsi(STR0031) PIXEL OF oDlgMain	//" Funcoes "
	@ aObj31Size[1,1],aObj31Size[1,2] LISTBOX o2Lbx VAR c2Lbx FIELDS;
		 	HEADER 	"",;
		 			OemtoAnsi(STR0032),;	//"Funcao"
					OemtoAnsi(STR0033);		//"Cod Funcao"
			COLSIZES 	GetTextWidth(0,"W"),;
						GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
						GetTextWidth(0,"BBBBB") SIZE aObj31Size[1,3],aObj31Size[1,4]+5 OF oDlgMain PIXEL;
	ON DBLCLICK (Cs030Marca(nOpc,.F.,0,oTree:GetCargo())) 
	o2Group:Hide()
	o2Lbx:Hide()
	o2Lbx:bLine:= {||{If(	TR2->TR2_MARCA==1,oOk,oNo),;
							TR2->TR2_NOME,;
							TR2->TR2_FUNCAO}}							

    
	//"Pesquisa Salarial: "
	@ aObj2Size[1,1],aObj2Size[1,2] SAY oSay1 PROMPT	OemToAnsi(STR0009) 	PIXEL SIZE 070,7		
	@ aObj2Size[2,1],aObj2Size[2,2] MSGET oGet1 VAR cGet 	PIXEL SIZE 170,7	WHEN .F.
    oSay1:Hide()
    oGet1:Hide()
    
    //----------
	// "Todos "
	@ aObj32Size[1,1],aObj32Size[1,2] GROUP oT1Grp	TO aObj32Size[1,3],aObj32Size[1,4] LABEL OemtoAnsi(STR0010) PIXEL OF oDlgMain 
			
	//"Marca"
	@ aObj32Size[1,1]+12,aObj32Size[1,2]+5 CHECKBOX oTMarca VAR lTMarca 	PROMPT OemtoAnsi(STR0011) SIZE 45,10 OF oDlgMain PIXEL;		
		ON CLICK (If(MsgYesNo(OemtoAnsi(STR0012),OemtoAnsi(STR0013)),Cs030Marca(nOpc,.T.,1,oTree:GetCargo()),),;		//"Marcar todos "###"Aten‡„o"
					lTMarca:=.F.,oTMarca:Refresh(.T.))	
	
	//"Desmarca"					
	@ aObj32Size[1,1]+12,aObj32Size[1,2]+45 CHECKBOX oTDesmarca VAR lTDesMarca 	PROMPT OemtoAnsi(STR0014) SIZE 35,10 OF oDlgMain PIXEL;	
		ON CLICK (If(MsgYesNo(OemtoAnsi(STR0015),OemtoAnsi(STR0016)),Cs030Marca(nOpc,.T.,0,oTree:GetCargo()),),;			//"Desmarcar todos "###"Aten‡„o"
					lTDesmarca:=.F.,oTDesmarca:Refresh(.T.))	
   
    //---------------
	//"Pesquisar por"
	@ aObj32Size[2,1],aObj32Size[2,2] GROUP oT2Grp	TO aObj32Size[2,3],aObj32Size[2,4] LABEL OemtoAnsi(STR0017) PIXEL OF oDlgMain 			
	
	// "Razao Social" ### "Funcao"						
	@ aObj32Size[2,1]+12,aObj32Size[2,2]+5 SAY	oSay2 PROMPT cSay2 	PIXEL SIZE 040,7  
	
	@ aObj32Size[2,1]+12,aObj32Size[2,2]+45 MSGET oTGet VAR cTGet	PICTURE "@!S30" VALID Cs030Pesq(cTGet,oTree:GetCargo()) PIXEL SIZE 45,7
	
	//--------------------
	// "Definir Parametros"
	@ aObj32Size[3,1],aObj32Size[3,2] GROUP o2Grp	TO aObj32Size[3,3],aObj32Size[3,4] LABEL OemtoAnsi(STR0028) PIXEL OF oDlgMain 

	//"Ramo"	
	o1Btn := TBrowseButton():New( aObj4Size[1,1],aObj4Size[2,2], OemToAnsi(STR0029),oDlgMain, {||Cs030Tela(nOpc,"4")},45,11,,,.F.,.T.,.F.,,.F.,,,)			   

	//"Faturamento"				
	o2Btn := TBrowseButton():New( aObj4Size[1,1]+13,aObj4Size[2,2], OemToAnsi(STR0030),oDlgMain, {||Cs030Tela(nOpc,"5") },45,11,,,.F.,.T.,.F.,,.F.,,,)			   		
	
	
	
	// Enchoice - Cadastrar Pesquisa Salarial
	Zero()
	oEnchoice:= MsMGet():New(cAlias, nReg, nOpc, aAC,"AC",STR0021,,aObjSize[2], , , , , , , , ,.T. ) //"Quanto a exclusao"		   
	
ACTIVATE MSDIALOG oDlgMain ON INIT  (oSay1:Hide(), oGet1:Hide(),;
									 o1Group:Hide(),o1Lbx:Hide(),;
									 oT1Grp:Hide(),oTMarca:Hide(),;   
									 o1Btn:Hide(),o2Btn:Hide(),o2Grp:Hide(),;
									 oTDesmarca:Hide(),oT2Grp:Hide(),;
									 oTGet:Hide(),oSay2:Hide(),;
									 o2Group:Hide(),o2Lbx:Hide(),;
									EnchoiceBar(oDlgMain,{||nOpca:=1,If(Cs030TudOk(9),oDlgMain:End(),nOpca:=2)},{|| nOpca := 2,oDlgMain:End()}))									

If nOpcA == 1 			// Confirma
	If nOpc == 3 .Or. nOpc == 4		// Inclusao ou Alteracao
		If(Obrigatorio(aGets,aTela))	
			Begin Transaction
				Cs030Grava(nOpc)
				EvalTrigger()
				If nOpc == 3
					If ( __lSx8 )
						ConfirmSX8()
					EndIf
				EndIf	
			End Transaction    
		EndIf
	ElseIf nOpc == 5					// Exclusao
		Cs030Delete(cAlias,nReg,nOpc)
	EndIf            
Else 
	If nOpc == 3		//Inclusao
		If ( __lSx8 )
			RollBackSx8()
		EndIf
	EndIf	
EndIf	  

// Apaga os arquivos temporarios
dbSelectArea("TR1")
dbCloseArea()
					
If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

dbSelectArea("TR2")
dbCloseArea()

If oArq2Tmp <> Nil
	oArq2Tmp:Delete()
	Freeobj(oArq2Tmp)
EndIf

dbSelectArea("TR3")
dbCloseArea()

If oArq3Tmp <> Nil
	oArq3Tmp:Delete()
	Freeobj(oArq3Tmp)
EndIf

dbSelectArea("TR4")
dbCloseArea()

If oArq4Tmp <> Nil
	oArq4Tmp:Delete()
	Freeobj(oArq4Tmp)
EndIf
                                
// Apaga os objetos com bitmaps
DeleteObject(oOk)
DeleteObject(oNo)

// Posiciona os arquivos no inicio 
dbSelectArea("SRJ")
dbSetOrder(1)      
dbGotop()

dbSelectArea("RB0")
dbSetOrder(1)
dbGotop()

dbSelectArea("RB1")

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030CriaArq³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados dos Listboxs              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030CriaArq()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030CriaArq()
Local a1Stru:= {}, a2Stru:={}, a3Stru:={}, a4Stru:={}
Local cCond1:="", cCond2:="", cCond3:="", cCond4:=""
Local aLstIndices := {}
// Cria arquivo de Participantes da Pesquisa Salarial
Aadd(a1Stru,{"TR1_MARCA"	,"N",01,0})
Aadd(a1Stru,{"TR1_EMPRES"	,"C",04,0})
Aadd(a1Stru,{"TR1_NOME"		,"C",30,0})
Aadd(a1Stru,{"TR1_FATURA"  ,"C",04,0})
Aadd(a1Stru,{"TR1_DESCFA"	,"C",34,0})
Aadd(a1Stru,{"TR1_RAMO"    ,"C",04,0})
Aadd(a1Stru,{"TR1_DESCRA"	,"C",34,0})
Aadd(a1Stru,{"TR1_NRFUNC"	,"N",06,0})

aLstIndices := {}

AAdd( aLstIndices, {"TR1_NOME"})
oArq1Tmp := RhCriaTrab('TR1', a1Stru, aLstIndices)
	

// Cria arquivo de Funcao da Pesquisa Salarial
Aadd(a2Stru,{"TR2_MARCA"	,"N",01,0})
Aadd(a2Stru,{"TR2_FUNCAO"	,"C",05,0})
Aadd(a2Stru,{"TR2_NOME"		,"C",30,0})

aLstIndices := {}
AAdd( aLstIndices, {"TR2_NOME"})
oArq2Tmp := RhCriaTrab('TR2', a2Stru, aLstIndices)

// Cria arquivo de Ramo de Atividade
Aadd(a3Stru,{"TR3_MARCA"	,"N",01,0})
Aadd(a3Stru,{"TR3_RAMO"		,"C",03,0})
Aadd(a3Stru,{"TR3_DESCRI"	,"C",30,0})

aLstIndices := {}
AAdd( aLstIndices, {"TR3_RAMO"})
oArq3Tmp := RhCriaTrab('TR3', a3Stru, aLstIndices)

// Cria arquivo de Faturamento
Aadd(a4Stru,{"TR4_MARCA"	,"N",01,0})
Aadd(a4Stru,{"TR4_FATURA"	,"C",03,0})
Aadd(a4Stru,{"TR4_DESCRI"	,"C",30,0})

aLstIndices := {}
AAdd( aLstIndices, {"TR4_FATURA"})
oArq4Tmp := RhCriaTrab('TR4', a4Stru, aLstIndices)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Monta  ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta os listbox para marcar para Pesquisa Salarial         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030Monta(cExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Monta(nQual,nOpc)                     
Local nMarca	:= 0
Local aEmpresa	:= {}
Local aFuncao	:= {}
Local aRamo		:= {}
Local aFatu		:= {}
Local nPos		:= 0
Local cFilSRJ 	:= xFilial("SRJ")                                  

inclui := .F.

If nOpc # 3 			// # Inclusao
	dbSelectArea("RB4")
	dbSetOrder(1)
	If dbSeek(xFilial("RB4")+cPesq)
		While !Eof() .And.	xFilial("RB4")+cPesq ==;
					        RB4->RB4_FILIAL+RB4->RB4_PESQ
                 
			If !Empty(RB4->RB4_EMPRES)
				Aadd(aEmpresa,RB4->RB4_EMPRES)
			EndIf	
			If !Empty(RB4->RB4_FUNCAO)	
				Aadd(aFuncao,RB4->RB4_FUNCAO)
			EndIf
			
			dbSkip()
		EndDo					         
	EndIf
EndIf

If nQual == 1			// Empresa Participante - RB0
	dbSelectArea("RB0")
	dbSetOrder(1)
	dbGotop()
	While !Eof()
	         
		// Verifica se a empresa ja foi selecionada anteriormente
		If nOpc # 3
			nPos	:= Ascan(aEmpresa,{|x| x ==RB0->RB0_EMPRES})
			If nPos > 0
				nMarca := 1
			Else
				nMarca := 0	
			EndIf	
		Else
			nMarca := 0
		EndIf		
	                          
		RecLock("TR1",.T.)                          
			TR1->TR1_MARCA		:= nMarca
			TR1->TR1_EMPRES 	:= RB0->RB0_EMPRES
			TR1->TR1_NOME		:= RB0->RB0_NOME
			TR1->TR1_FATURA		:= RB0->RB0_FATURA
			TR1->TR1_DESCFA		:= FDesc("SX5","RE"+RB0->RB0_FATURA,"X5_DESCRI",30)
			TR1->TR1_RAMO		:= RB0->RB0_ATIVID
			TR1->TR1_DESCRA		:= FDesc("SX5","RD"+RB0->RB0_ATIVID,"X5_DESCRI",30)			
			TR1->TR1_NRFUNC		:= RB0->RB0_NRFUNC
		MsUnlock()                                     
		
		dbSelectArea("RB0")
		dbSkip()
	EndDo

	dbSelectArea("TR1")
	dbSetOrder(1)
	dbGotop()            
ElseIf nQual == 2		// Funcoes - SRJ
    dbSelectArea("SRJ")
    dbSetOrder(1)
    dbGotop()
    
    SRJ->(dbSeek(cFilSRJ))
	While SRJ->(!Eof()) .And. (SRJ->RJ_FILIAL == cFilSRJ)          
		
		// Verifica se a funcao ja foi selecionado anteriormente
		If nOpc # 3
			nPos	:= Ascan(aFuncao,{|x| x ==SRJ->RJ_FUNCAO})
			If nPos > 0
				nMarca := 1
			Else
				nMarca := 0	
			EndIf	
		Else
			nMarca := 0
		EndIf		
	            
		RecLock("TR2",.T.)
			TR2->TR2_MARCA 	:= 	nMarca
			TR2->TR2_FUNCAO	:=	SRJ->RJ_FUNCAO
			TR2->TR2_NOME	:=	SRJ->RJ_DESC
		MsUnlock()                                     
		
		dbSelectArea("SRJ")
		dbSetOrder(1)
		dbSkip()
	EndDo     
	       
	dbSelectArea("TR2")
	dbSetOrder(1)
	dbGotop()
ElseIf nQual == 3		// Ramo de Atividade - RD
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"RD")
		While !Eof() .And. 	xFilial("SX5")+"RD" ==;
								X5_FILIAL+X5_TABELA

			// Verifica se o ramo de atividade ja foi selecionado anteriormente
			If nOpc # 3
				nPos	:= Ascan(aRamo,{|x| x ==Alltrim(SX5->X5_CHAVE)})
				If nPos > 0
					nMarca := 1
				Else
					nMarca := 0	
				EndIf	
			Else
				nMarca := 0
			EndIf			
        
			RecLock("TR3",.T.)
				TR3->TR3_MARCA 	:= 	nMarca
				TR3->TR3_RAMO	:=	Alltrim(SX5->X5_CHAVE)
				TR3->TR3_DESCRI	:=	Subst(X5Descri(),1,30)
			MsUnlock()                                     
			
			dbSelectArea("SX5")        
			dbSkip()
		EndDo			
	EndIf	
	
	dbSelectArea("TR4")
	dbSetOrder(1)
	dbGotop()	

ElseIf nQual == 4		// Faturamento - RE			
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"RE")
		While !Eof() .And. 	xFilial("SX5")+"RE" ==;
								X5_FILIAL+X5_TABELA
								
			// Verifica se o faturamento ja foi selecionado anteriormente
			If nOpc # 3
				nPos	:= Ascan(aFatu,{|x| x ==Alltrim(SX5->X5_CHAVE)})
				If nPos > 0
					nMarca := 1
				Else
					nMarca := 0	
				EndIf	
			Else
				nMarca := 0
			EndIf			
								
			RecLock("TR4",.T.)
				TR4->TR4_MARCA 	:= 	nMarca
				TR4->TR4_FATURA	:=	Alltrim(SX5->X5_CHAVE)
				TR4->TR4_DESCRI	:=	Subst(X5Descri(),1,30)
			MsUnlock()                                     

			dbSelectArea("SX5")        
			dbSkip()
		EndDo
	EndIf
	
	dbSelectArea("TR4")
	dbSetOrder(1)
	dbGotop()	
	
EndIf         

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Marca³ Autor ³ Cristina Ogura        ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no on click do listbox                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs030Marca(cExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc  = Opcao do arotina                                    ³±±
±±³          ³lFlag = .F.= registro posicionado .T.= todos os registro    ³±±
±±³			 ³nMarca= 1-marca todos 0-desmarca                            ³±±
±±³			 ³cLimpa= Indica em qual tree estou posicionado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Marca(nOpc,lFlag,nMarca,cLimpa)

If nOpc == 2 .Or. nOpc== 5
	Return .T.
EndIf

If !lFlag 	
	If cLimpa == "2"    	// Empresas Participantes
		RecLock("TR1",.F.,.T.)
			TR1->TR1_MARCA := IIF(TR1->TR1_MARCA==1,0,1)
		MsUnlock()	
	ElseIf cLimpa == "3"	// Funcoes
		RecLock("TR2",.F.,.T.)
			TR2->TR2_MARCA := IIF(TR2->TR2_MARCA==1,0,1)
		MsUnlock()	
	ElseIf cLimpa == "4"	// Ramo de Atividade
		RecLock("TR3",.F.,.T.)
			TR3->TR3_MARCA := IIF(TR3->TR3_MARCA==1,0,1)
		MsUnlock()	
	ElseIf cLimpa == "5"	// Faturamento
		RecLock("TR4",.F.,.T.)
			TR4->TR4_MARCA := IIF(TR4->TR4_MARCA==1,0,1)
		MsUnlock()	
	EndIf	  
Else
	If cLimpa == "2"		// Participantes
		dbSelectArea("TR1")
		dbGotop()
		While !Eof() 
			RecLock("TR1",.F.,.T.)
				TR1->TR1_MARCA := nMarca
			MsUnlock()
			dbSkip()	
		EndDo
		dbGotop()
	ElseIf cLimpa == "3"	// Funcoes
		dbSelectArea("TR2")
		dbGotop()
		While !Eof() 
			RecLock("TR2",.F.,.T.)
				TR2->TR2_MARCA := nMarca
			MsUnlock()
			dbSkip()	
		EndDo
		dbGotop()
	ElseIf cLimpa == "4"	// Ramo de Atividade
		dbSelectArea("TR3")
		dbGotop()
		While !Eof() 
			RecLock("TR3",.F.,.T.)
				TR3->TR3_MARCA := nMarca
			MsUnlock()
			dbSkip()	
		EndDo
		dbGotop()
	ElseIf cLimpa == "5"	// Faturamento
		dbSelectArea("TR4")
		dbGotop()
		While !Eof() 
			RecLock("TR4",.F.,.T.)
				TR4->TR4_MARCA := nMarca
			MsUnlock()
			dbSkip()	
		EndDo
		dbGotop()
	EndIf
EndIf	

o1Lbx:Refresh(.T.)
o2Lbx:Refresh(.T.)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Delete ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apaga os dados da Pesquisa, Funcoes e Empresas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030Delete()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Delete(cAlias,nReg,nOpc)
Local cKeyDel := cPesq
Local aAreas	:= {}
Local axErro	:= {}
Local aNotSx9Check := {}

Begin Transaction	
	aAdd( aNotSx9Check ,"RB4" )
	
	lChkDelOk  := ChkDelRegs(	cAlias				,;	//Alias do Arquivo Principal
							nReg				,;	//Registro do Arquivo Principal
							nOpc				   ,;	//Opcao para a AxDeleta
							xFilial( cAlias )		,;	//Filial do Arquivo principal para Delecao
							cKeyDel					,;	//Chave do Arquivo Principal para Delecao
							aAreas					,;	//Array contendo informacoes dos arquivos a serem pesquisados
							NIL						,;	//Mensagem para MsgYesNo
							NIL						,;	//Titulo do Log de Delecao
							NIL						,;	//Mensagem para o corpo do Log
							.F.				 		,;	//Se executa AxDeleta
							.F.						,;	//Se deve Mostrar o Log
							@axErro						,;	//Array com o Log de Exclusao
							NIL				 		,;	//Array com o Titulo do Log
							NIL						,;	//Bloco para Posicionamento no Arquivo
							NIL						,;	//Bloco para a Condicao While
							NIL						,;	//Bloco para Skip/Loop no While
							.T.						,;	//Verifica os Relacionamentos no SX9
							aNotSx9Check			,;	//Alias que nao deverao ser Verificados no SX9
							NIL				 	 	,;	//Se faz uma checagem soft
							.F.				 ;  //Se esta executando rotina automatica
						)
	If !lChkDelOk
		lChkDelOk	:= MsgNoYes ( STR0044 , STR0013 )
	EndIf
	
	
	// Apaga os Itens selecionados para Pesquisa Salarial	
	If lChkDelOk
		dbSelectArea("RB4")                  
		dbSetOrder(1)
		If dbSeek(xFilial("RB4")+cPesq)
			While !Eof() .And. xFilial("RB4")+cPesq == RB4->RB4_FILIAL+RB4->RB4_PESQ
			
				RecLock("RB4",.F.)
					dbDelete()
				MsUnlock()		
	
				dbSkip()			
			EndDo
		EndIf
	    
		// Apaga os dados da Pesquisa Salarial
		dbSelectArea("RB1")
		RecLock("RB1",.F.)
			dbDelete()
		MsUnlock()	
	EndIF	
	
End Transaction

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Grava  ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os dados da Pesquisa, Funcoes e Empresas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030Grava(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Grava(nOpc)
Local bCampo := {|nCPO| Field(nCPO) }
Local i, cVar
Local aSoma		:= {}
Local aAnterior	:= {}
Local aRetorno	:= {}
Local aEmpresa	:= {}
Local aFuncao	:= {}
Local aRamo		:= {}
Local aFatu		:= {}
Local aArray	:= {"TR1","TR2"}
Local lFound 	:= Iif(nOpc == 3, .T., .F.)         
Local nDel		:= 0
Local nVezes	:= 0
Local n1		:= 0

If nOpc # 3
	dbSelectArea("RB4")
	dbSetOrder(1)
	If dbSeek(xFilial("RB4")+cPesq)
		While !Eof() .And. xFilial("RB4")+cPesq ==;
							RB4->RB4_FILIAL+RB4->RB4_PESQ
	        Aadd(aAnterior, RecNo())
			dbSkip()					           
		EndDo		
	EndIf
EndIf

// Armazenar nos arrays somente os itens marcadas                       
For i:=1 To Len(aArray)

	dbSelectArea(aArray[i])
	dbGotop()
	While !Eof()
		cVar:= aArray[i]+"->"+aArray[i]+"_MARCA"
		If &cVar == 1
			If i == 1			// Empresa
				Aadd(aEmpresa,TR1->TR1_EMPRES)
			ElseIf 	i == 2		// Funcao
				Aadd(aFuncao,TR2->TR2_FUNCAO)				
			EndIf	
		EndIf
		dbSkip()	
	EndDo              
	
Next i	

// Armazenado no array o tamanho dos arrays e um identificador
Aadd(aSoma,{Len(aEmpresa),1,aEmpresa})
Aadd(aSoma,{Len(aFuncao),2,aFuncao})

// Colocado em ordem decrescente
aSoma := aSort(aSoma,,,{|x,y| x[1] > y[1]})
                        
dbSelectArea("RB4")

// Apaga os registros que estao a mais no RB4
If aSoma[1][1] < Len(aAnterior)
	nVezes := Len(aAnterior) - aSoma[1][1]
	For nDel := 1 To nVezes
		dbGoto(aAnterior[1])
		RecLock("RB4",.F.)
			dbDelete()
		MsUnlock()	
		aDel(aAnterior,1)
		aSize(aAnterior,Len(aAnterior)-1)
	Next nDel     
EndIf	

// Grava dados da Pesquisa Salarial

dbSelectArea("RB1")		
RecLock("RB1",lFound)
	For i := 1 TO FCount()
		If "_FILIAL"$Field(i)
			FieldPut(i,cFilial)
		Else
			FieldPut(i,M->&(EVAL(bCampo,i)))
		EndIf
	Next i

	Replace RB1->RB1_NREMPR		With Len(aEmpresa)
	Replace RB1->RB1_NRCARG		With Len(aFuncao)

MsUnlock()

//Deleta registros antes da gravacao
If nOpc == 4	//Alteracao
	dbSelectArea("RB4")   
	dbSeek(xFilial("RB4")+cPesq)
	While !Eof() .And. 	(xFilial("RB4")+cPesq) ==;
						(RB4->RB4_FILIAL+RB4->RB4_PESQ)
		RecLock("RB4",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf	
	
For n1:= 1 To aSoma[1][1]
         
	//Busca os variaveis para serem atualizadas
	aRetorno:= Cs030Itens(aEmpresa,aFuncao,aRamo,aFatu,n1,aSoma)

	RecLock("RB4",.T.)	
		Replace RB4->RB4_FILIAL 	With xFilial("RB4")
		Replace RB4->RB4_PESQ		With cPesq
   		Replace RB4->RB4_EMPRES		With aRetorno[1]
		Replace RB4->RB4_FUNCAO		With aRetorno[2]
		If !Empty(aRetorno[2])
			Replace RB4->RB4_FUNPES		With	StrZero(100*n1,4)
		EndIf	
	MsUnlock()
	
Next n1


Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Obrig  ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se foi marcado pelo menos 1 Empresa e 1 Funcao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030Grava(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Obrig()
Local lRet := .F.

// Verifica se existe alguma empresa marcada
dbSelectArea("TR1")
dbSetOrder(1)
dbGotop()
While !Eof()
    If TR1->TR1_MARCA == 1		//Marcado
		lRet:= .T.
		Exit
	EndIf	
	dbSkip()
EndDo	

If lRet
	lRet := .F.
	// Verifica se existe funcao marcado
	dbSelectArea("TR2")
	dbSetOrder(1)
	dbGotop()
	While !Eof()
		If TR2->TR2_MARCA == 1
			lRet := .T.
			Exit
		EndIf
		dbSkip()
	EndDo
EndIf	

If !lRet
	Help("",1,"Cs030NMARCA")
EndIf

Return lRet

/*                                                                             
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs030Itens  ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os dados do registro a ser gravado.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs030Itens(aEmpresa,aFuncao,aFatu,aRamo,nEstou)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/	
Function Cs030Itens(aEmpresa,aFuncao,aRamo,aFatu,nEstou,aSoma)
Local cEmpresa	:= CriaVar("RB4_EMPRES")
Local cFuncao	:= CriaVar("RB4_FUNCAO") 
Local n2:=0
	
For n2:= 1 To 2
	If aSoma[n2][2]== 1			// Empresas
		If nEstou <= Len(aEmpresa)
			cEmpresa := aEmpresa[nEstou]
		EndIf		
	ElseIf aSoma[n2][2]== 2		// Funcoes
		If nEstou <= Len(aFuncao)
			cFuncao := aFuncao[nEstou]
		EndIf	
	EndIf    
Next n2	     

Return {cEmpresa,cFuncao}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Cs030Principal  ³ Autor ³ Cristina Ogura  ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que controla a mudanca nos trees 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Cs030Principal() 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA030		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs030Principal(oTree)
cIndo:= oTree:GetCargo()
cTGet:= Space(30)

// 1- Pesquisa Salarial
// 2- Selecionar Participantes
// 3- Selecionar Funcoes
If cEstou == "1"
	cPesq		:= M->RB1_PESQ
	cDesqPesq	:= M->RB1_DESCRI
	cGet		:= M->RB1_PESQ + " - " + M->RB1_DESCRI
	oGet1:cText(cGet)
	oSay1:Show()
	oGet1:Show()
	oT1Grp:Show()
	oT2Grp:Show()       
	oTMarca:Show()
	oTDesmarca:Show()
	oTGet:Show()  
	oTGet:Refresh(.T.)
	oEnchoice:Hide()
ElseIf cEstou == "2"
	o1Group:Hide()
	o1Lbx:Hide()
ElseIf cEstou == "3"
	o2Lbx:Hide()
	o2Group:Hide()
EndIf

If cIndo == "1"
	oEnchoice:Show()
	oTMarca:Hide()
	oTDesmarca:Hide()
	oT1Grp:Hide()
	oT2Grp:Hide()
	oTGet:Hide()
	oSay1:Hide()
	oSay2:Hide()
	oGet1:Hide()
	o2Grp:Hide()
	o1Btn:Hide()
	o2Btn:Hide()
ElseIf cIndo == "2"
	cSay2:= STR0035		// "Razao Social:"
	oSay2:Show()
	o1Lbx:Show()
	o1Group:Show()         
	o2Grp:Show()
	o1Btn:Show()
	o2Btn:Show()
	oSay2:Refresh(.T.)
	oTGet:Refresh(.T.)
ElseIf cIndo == "3"
	cSay2:= STR0036		// "Funcao:"
	oSay2:Show()
	o2Lbx:Show()
	o2Group:Show()
	oSay2:Refresh(.T.)	
	oTGet:Refresh(.T.)	
	o2Grp:Hide()
	o1Btn:Hide()
	o2Btn:Hide()
EndIf

cEstou := cIndo            

dbSelectArea("TR1")
dbGotop()
o1Lbx:Refresh(.T.)

dbSelectArea("TR2")
dbGotop()
o2Lbx:Refresh(.T.)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Cs030VlTree ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o tree do programa       							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA030       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs030VlTree(nOpc)
Local lRet:=.T.

If nOpc # 2 .And. nOpc # 5			// Diferente de visual e delecao
	If cEstou == "1"
		lRet:= Obrigatorio(aGets,aTela)
	ElseIf cEstou == "2"
		lRet:= Cs030TudOk(2)
	ElseIf cEstou == "3"
		lRet:= Cs030TudOk(3)
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Cs030TudOk  ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se foi selecionado os dados para a Pesquisa		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA030       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs030TudOk(nFlag)
Local lRet1:= .F.
Local lRet2:= .F.

// nflag para avaliar os seguintes arquivos se foram marcados
// 2- Empresas
// 3- Funcoes
// 9- Todos                                           

If 	nFlag == 9		// Verificar campos da enchoice
	If 	M->RB1_REAL < M->RB1_INICIO
		Help("",1,"Cs030Data")		// Data realizacao deve ser maior ou igual que a data de inicio da pesquisa.
		Return .F.
	EndIf
EndIf		
                                                      
If nFlag ==2 .Or. nFlag == 9
	If nFlag # 9
		lRet2:=.T.
	EndIf	
	dbSelectArea("TR1")
	dbSetOrder(1)
	dbGotop()
	While !Eof()
		If TR1->TR1_MARCA == 1
			lRet1 := .T.
			Exit
		EndIf	
		dbSkip()
	EndDo
	dbGotop()
EndIf	          

If nFlag == 3 .Or. nFlag == 9
	If nFlag # 9
		lRet1:=.T.
	EndIf	
	dbSelectArea("TR2")
	dbSetOrder(1)
	dbGotop()
	While !Eof()
		If TR2->TR2_MARCA == 1
			lRet2 := .T.
			Exit
		EndIf	
		dbSkip()
	EndDo
	dbGotop()  
EndIf		

If !lRet1 .Or. !lRet2 
	Help("",1,"Cs030NSELEC")			// Verifique as empresas, Funcoes, ramo ou faturamento.
	Return .F.
EndIf

Return .T.
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Cs030Pesq   ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz pesquisa nos arquivos conforme opcao selecionada		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA030       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs030Pesq(cGet,cQual)
Local cAlias

If cQual == "2" .Or. cQual == "3"
	SET SOFTSEEK ON
	If cQual == "2"			// Participantes
		cAlias := "TR1"
	ElseIf cQual == "3"
		cAlias := "TR2"
	EndIf
					       	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(cGet,.T.)
	            
	SET SOFTSEEK OFF
	
	o1Lbx:Refresh(.T.)
	o2Lbx:Refresh(.T.)
EndIf
	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Cs030Tela   ³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a Tela do Ramo de Atividade e Faturamento     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA030       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs030Tela(nOpc,cFlag)
Local oDlg
Local c3Lbx, o3Lbx, o3Group
Local c4Lbx, o4Lbx, o4Group                             
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}


/**************************************************************
Monta as Dimensoes dos Objetos
**************************************************************/
aAdvSize		:= MsAdvSize(,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )  

DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE STR0037 PIXEL	// "Definir parametros:"

	If cFlag == "4"
		// Selecionar Ramo de Atividade
		dbSelectArea("TR3")
			                             
		@ aObjSize[1,1],aObjSize[1,2] LISTBOX o3Lbx VAR c3Lbx FIELDS;
		 	HEADER 	"",;
		 			OemtoAnsi(STR0038),;	//"Ramo Atividade"
					OemtoAnsi(STR0039);		//"Codigo"
			COLSIZES	GetTextWidth(0,"W"),;   
						GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
						GetTextWidth(0,"BBBB") SIZE aObjSize[1,3],aObjSize[1,4] OF oDlg PIXEL;
		ON DBLCLICK (Cs030Marca(nOpc,.F.,0,"4")) 
		o3Lbx:bLine:= {||{If(	TR3->TR3_MARCA==1,oOk,oNo),;
								TR3->TR3_DESCRI,;
								TR3->TR3_RAMO}}
	ElseIf cFlag == "5"
		// Selecionar Faturamento
		dbSelectArea("TR4")	                             
	
		@ aObjSize[1,1],aObjSize[1,2] LISTBOX o4Lbx VAR c4Lbx FIELDS;
		 	HEADER 	"",;
		 			OemtoAnsi(STR0040),;	//"Faturamento"
					OemtoAnsi(STR0041);		//"Codigo"
			COLSIZES 	GetTextWidth(0,"W"),;
						GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
						GetTextWidth(0,"BBBB") SIZE aObjSize[1,3],aObjSize[1,4] OF oDlg PIXEL;
		ON DBLCLICK (Cs030Marca(nOpc,.F.,0,"5")) 
		o4Lbx:bLine:= {||{If(	TR4->TR4_MARCA==1,oOk,oNo),;
								TR4->TR4_DESCRI,;
								TR4->TR4_FATURA}}                                         	
	EndIf                	
	
	bSet15 :=  {|| Cs030Empresas(cFlag),oDlg:End()}
	bSet24 :=  {||oDlg:End()}
           
ACTIVATE MSDIALOG oDlg ON INIT enchoicebar(oDlg,bSet15, bSet24) CENTERED	
          
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Cs030Empresa³ Autor ³ Cristina Ogura	    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a Tela do Ramo de Atividade e Faturamento     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA030       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs030Empresa(cQual)
Local nOk

dbSelectArea("TR1")
dbGotop()
While !Eof()                    
	nOk := 0
	If cQual == "4"
		dbSelectArea("TR3")
		If dbSeek(TR1->TR1_RAMO)
		 	If TR3->TR3_MARCA == 1
		 		nOK := 1
		 	EndIf		
		EndIf
	ElseIf cQual == "5"
		dbSelectArea("TR4")
		If dbSeek(TR1->TR1_FATURA)
		 	If TR4->TR4_MARCA == 1
		 		nOK := 1
		 	EndIf		
		EndIf
	EndIf	
	
	If nOk == 1
		Replace TR1->TR1_MARCA With 1
	EndIf	

	dbSelectArea("TR1")
	dbSkip()
EndDo     

dbSelectArea("TR1")
dbGotop()

o1Lbx:Refresh(.T.)

Return .T.

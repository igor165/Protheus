#include "dbtree.ch"
#include "Protheus.ch"
#include "font.ch"
#include "GPEA800.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³ GPEA800³ Autor ³ Marcos Kato			 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao SHST										  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³	DATA	 ³ Programador  ³BOPS  	³Manutencao Efetuada						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³08/12/08  ³Marcos Kato  	³       ³Ajuste na atribuicao do valores da variavel ³±±
±±³          ³           	³       ³aSHST no intervalo da posicao 108 a 126     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA800()          
Local nOpca:=0
Private cCadastro:=STR0001//"Manutencao SHST - Seguranca, Higiene e Saude do Trabalho"
Private aSays 	  	:= {}, aBotao  	:= {}           
Private cParFilial	:= cFilAnt, cParAnoBas	:=Substr(Dtos(dDataBase),1,4)
Private nTamL:=1,nTamC1:=1,nTamBox:=1,nTamLC2:=1

AADD(aSays,OemToAnsi(Substr(STR0371,1,80)))      
AADD(aSays,OemToAnsi(Substr(STR0371,81,40)))      
AADD(aBotao, {  5,.T.,{|| Pergunte("GPEA800",.T.) } } )
AADD(aBotao, {  1,.T.,{|o| (nOpca := 1,FechaBatch())}} )
AADD(aBotao, {  2,.T.,{|o| FechaBatch() }} )
//==================================================================================================================
//Montagem da Tela Inicial
//==================================================================================================================
FormBatch( cCadastro, aSays, aBotao )
	
cParFilial:=MV_PAR01
cParAnoBas:=MV_PAR02
If nOpca==1	
	If !Empty(cParFilial) .And. !Empty(cParAnoBas) 
		Processa({|lEnd| ManSHST(cParFilial,cParAnoBas),STR0131})
	Endif	
Endif

	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³ ManSHST³ Autor ³ Marcos Kato			 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela da Manutencao SHST								  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ManSHST(cParFilial,cParAnoBas)
Local aSaveArea	:= GetArea()
Local oDlgMain, oTree
Local nOpca		 := 0			,nSHST		:=0
Local bSet15	 := { || NIL },bSet24	 := { || NIL },aButtons	 := {}
Private aSHST    :=ARRAY(556)
Private aProcSHST:={},aAux	 :={},aIHMTrb:={},aEHMTrb:={},aICMTrb :={},aECMTrb :={},aIHTTrb :={},aEHTTrb :={},aICTTrb :={}
Private aECTTrb  :={},aHAcFor:={},aCAcFor:={},aHForPe:={},aCForPe :={},aHAudit :={},aCAudit :={},aHAgFis :={},aCAgFis :={}
Private aHAgQui	 :={},aCAgQui:={},aHAgBio:={},aCAgBio:={},aHAcoImu:={},aCAcoImu:={},aHCodDoe:={},aCCodDoe:={},aDelSHST:={}
Private aOk:={"0 - "+STR0132,"1 - "+STR0131},aNatureza:={"1 - "+STR0134,"2 - "+STR0133,"3 - "+STR0135,"4 - "+STR0136}//Sim#Nao#"Criação"#"Substituição"#"Modificação"#"Reorganização"
Private aSituacao:={STR0154,STR0155}//"Adequada"#"Inadequada"
Private oDadGer
Private oGetIM,oGetIT,oGetEM,oGetET,oGetAF,oGetFP,oGetAud,oGetAFis,oGetAQui,oGetABio,oGetAI,oGetCD,oVIIMsg,oVIIIMsg
Private oI,oII,oIII,oIV,oV,oVI			  //Capitulo I,II,III,IV,V
Private	oVIIP1,oVIIP2,oVIIP3,oVIIP4,oVIIP5//Capitulo VII
Private oVIIIP1,oVIIIP2					  //Capitulo VIII              
Private oIX								  //Capitulo IX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
Private aAdvSize	:= {},aInfoAdvSize:= {},aObjSize	:= {},aObjCoords	:= {}
Private aTreeCoords	:= {},aEnchCoords := {},aGetDCoords	:= {},aGdCoord		:= {}
Private nOpcao	:= 0,nHRes	:= 0

For nSHST:=1 To 458         
	If nSHST==4 .or. nSHST==5 .or. (nSHST>=7 .And. nSHST<=18) .or.nSHST==22 .or. nSHST==23 .or. (nSHST>=25 .And. nSHST<=34) ;
	.or.(nSHST>=38 .And. nSHST<=42) .or. (nSHST>=44 .And. nSHST<=48) .or. (nSHST>=51 .And. nSHST<=67) .or. (nSHST>=69 .And. nSHST<=82) ;
	.or.nSHST==84 .or. nSHST==85.or.(nSHST>=100 .And. nSHST<=106) .or. nSHST==131 .or. nSHST==133 .or. nSHST==135 .or. nSHST==137 .or. nSHST==139 ;
	.or. nSHST==145 .or.	nSHST==147 .or. nSHST==149 .or. nSHST==151 .or. nSHST==153 .or. nSHST==155 .or. nSHST==158 ;
	.or.(nSHST>=185 .And. nSHST<=208) .or. (nSHST>=210 .And. nSHST<=231) .or. (nSHST>=233.And. nSHST<=240) .or. (nSHST>=242 .And. nSHST<=259) .or. (nSHST>=262 .And. nSHST<=291) ;
	.or.(nSHST>=302 .And.  nSHST<=377) .or. (nSHST>=379 .And. nSHST<=381) .or.(nSHST>=383 .And. nSHST<=456)
		aSHST[nSHST]:=0	
	Else                
	    aSHST[nSHST]:=Space(200)
    Endif
Next 

MsgRun(STR0366,	STR0364, {||GeraSHST(cParFilial,cParAnoBas)})//Aguarde...#Consultando SHST" 

nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
nTamLC2 := 1.1
nTamBox	:= 0.8              
nTamC1  := 1  //Coluna 1	
nTamL  	:= 0.8

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , {000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aTreeCoords	:= { aAdvSize[2]+2	, aAdvSize[1]				, aAdvSize[4]		, aAdvSize[3]*0.2 }
aEnchCoords	:= { aAdvSize[2]+2	, aAdvSize[3]*0.2 + 2		, aAdvSize[4]		, aAdvSize[3]}
aGdCoord	:= { aAdvSize[2]+10	, aAdvSize[3]*0.2 + 2 + 5	, aAdvSize[4] - 10	, aAdvSize[3]-5}


DEFINE MSDIALOG oDlgMain TITLE cCadastro+" "+cParAnoBas  FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]  PIXEL

      
DEFINE DBTREE oTree FROM aTreeCoords[1],aTreeCoords[2] TO (aTreeCoords[3]+20),(aTreeCoords[4]-15) CARGO OF oDlgMain;
ON CHANGE (SHSTPrin(oTree,oDlgMain))

//	oTree:bValid 		:= {|| Tr100VlTree(nOpcx,1) }
oTree:lValidLost 	:= .f.
oTree:lActivated	:= .T.

DBADDTREE oTree PROMPT OemToAnsi(STR0003)+Space(30);//"Empresa"
RESOURCE "FOLDER5";
CARGO "01"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0004);//"Estabelecimento"
RESOURCE "FOLDER5";
CARGO "02"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0005);//"Organizacao SHST"
RESOURCE "FOLDER5";
CARGO "03"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0006);//"SHST-Servicos Internos e Externos"
RESOURCE "FOLDER5";
CARGO "04"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0007);//"Pessoas no Estabelecimento"
RESOURCE "FOLDER5";
CARGO "05"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0008);//"Atividade SHST "
RESOURCE "FOLDER5","FOLDER6";
CARGO "06"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0009);//"VII-Atividades desenvolvidas nos Dominios da Segurança e Higiene no Trabalho"
RESOURCE "FOLDER5","FOLDER6";
CARGO "07"
DBADDITEM oTree PROMPT STR0093 RESOURCE "FOLDER5" CARGO "07_1"//"Condições de trabalho e avaliação de riscos profissionais"
DBADDITEM oTree PROMPT STR0094 RESOURCE "FOLDER5" CARGO "07_2"//"Intervenções técnicas no controle do ambiente de trabalho"
DBADDITEM oTree PROMPT STR0095 RESOURCE "FOLDER5" CARGO "07_3"//"Beneficiações/correções introduzidas nas máquinas e outros equipamentos"
DBADDITEM oTree PROMPT STR0096 RESOURCE "FOLDER5" CARGO "07_4"//"Intervenção nas características dos locais de trabalho e práticas de trabalho"
DBADDITEM oTree PROMPT STR0097 RESOURCE "FOLDER5" CARGO "07_5"//"Medidas de proteção coletiva de proteção individual"
DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0010);//"VIII-Atividade desenvolvida no Âmbito da Saude no Trabalho"
RESOURCE "FOLDER5","FOLDER6";
CARGO "08"
DBADDITEM oTree PROMPT  STR0098 RESOURCE "FOLDER5" CARGO "08_1"//"Desenvolvidas"
DBADDITEM oTree PROMPT  STR0099 RESOURCE "FOLDER5" CARGO "08_2"//"Promocao da Saude"

DBENDTREE oTree

DBADDTREE oTree PROMPT OemToAnsi(STR0011);//"IX-Acidentes de Trabalho e Doenças Profissionais"
RESOURCE "FOLDER5","FOLDER6";
CARGO "09"

DBENDTREE oTree

//==================================
//Layout da Tela                    
//==================================
EmpSHST(oTree,oDlgMain)//Capitulo I - Empresa
//Telas que nao terao o objeto destruido devido ao getdados            
MsgSHST(oTree,oDlgMain)
ServIntExt(oTree,oDlgMain)    
VISHST(oTree,oDlgMain)
VIIPart1(oTree,oDlgMain)    
VIIPart2 (oTree,oDlgMain)//"Intervenções técnicas no controle do ambiente de trabalho"
VIIIPart1(oTree,oDlgMain)
AcidTrbDP(oTree,oDlgMain)                                  

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta os Botoes para a EnchoiceBar             			  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

bSet15		:= { ||nOpca := 1,oDlgMain:End()}
bSet24		:= { ||nOpca := 2,oDlgMain:End()}
aButtons:={}
ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain, bSet15, bSet24, NIL , aButtons))

If nOpca==1
	MsgRun(STR0366,STR0367, {||ProcSHST()})//Aguarde...#Processando SHST
	MsgRun(STR0365,STR0367, {||GravaSHST(cParFilial,cParAnoBas)})//Aguarde...#Gravando SHST
Endif
Release Objects oTree

RestArea(aSaveArea)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³SHSTPrin   ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de Itens da Arvore                						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SHSTPrin(oTree,oDlgMain)
cIndo := oTree:GetCargo()

//Capitulo I - Empresa
If cIndo == "01"
//	EmpSHST(oTree,oDlgMain)//Capitulo I - Empresa
	oI:Show()
Else     
	oI:Hide()
//  	If ValType(oI)=="O"
//		oI:FreeChildren()
//		FreeObj(oI)//Destroi o objeto
//   	Endif
Endif
//Capitulo II - Estabelecimento
If cIndo == "02"
	EstSHST(oTree,oDlgMain)
Else
	If ValType(oII)=="O"
		oII:FreeChildren()
		FreeObj(oII)
	Endif
Endif
//Capitulo III - Organizacao SHSt
If cIndo == "03"
	OrgSHST(oTree,oDlgMain)//Capitulo III - Organizacao SHST
Else
	If ValType(oIII)=="O"
		oIII:FreeChildren()
		FreeObj(oIII)
	Endif
Endif

If cIndo == "04"
	oIV:Show()
Else
	oIV:Hide()
Endif

If cIndo=="05"
	PesEstSHST(oTree,oDlgMain)//Capitulo V - Pessoas no Estabelecimento
Else
	If ValType(oV)=="O"
		oV:FreeChildren()
		FreeObj(oV)
	Endif
Endif
//================================================================================================================
//Capitulo VI - Atividades SHST
//================================================================================================================
If cIndo=="06"                
	oVI:Show()
Else 
	oVI:Hide()
Endif	
//================================================================================================================
//Capitulo VII - Atividades desenvolvidas nos Dominios da Segurança e Higiene no Trabalho                                                        
//================================================================================================================
If cIndo=="07"                   
	If oTree:CURRENTNODEID=="0000007"//"Mensagem para preenchimento na tela"
		oVIIMsg:Show()	
	Else
		oVIIMsg:Hide()
	Endif
	If oTree:CURRENTNODEID=="0000008"//"Condições de trabalho e avaliação de riscos profissionais"
		oVIIP1:Show()
	Else
		oVIIP1:Hide()	
	Endif	
	If oTree:CURRENTNODEID=="0000009"//"Intervenções técnicas no controle do ambiente de trabalho"
		oVIIP2:Show()
	Else
		oVIIP2:Hide()		
	Endif
	If oTree:CURRENTNODEID=="0000010"//"Beneficiações/correções introduzidas nas máquinas e outros equipamentos"
		If ValType(oVIIP3)<>"O"
			VIIPart3(oTree,oDlgMain)
		Endif	
	Else
		If ValType(oVIIP3)=="O"
			oVIIP3:Hide()
			oVIIP3:FreeChildren()
			FreeObj(oVIIP3)
		Endif
	Endif
	If oTree:CURRENTNODEID=="0000011"//"Intervenção nas características dos locais de trabalho e práticas de trabalho"
		If ValType(oVIIP4)<>"O"
			VIIPart4(oTree,oDlgMain)
		Endif	
	Else
		If ValType(oVIIP4)=="O"
			oVIIP4:Hide()
			oVIIP4:FreeChildren()
			FreeObj(oVIIP4)
		Endif
	Endif
	If oTree:CURRENTNODEID=="0000012"//"Medidas de proteção coletiva de proteção individual"
		If ValType(oVIIP5)<>"O"
			VIIPart5(oTree,oDlgMain)
		Endif	
	Else
		If ValType(oVIIP5)=="O"
			oVIIP5:Hide()
			oVIIP5:FreeChildren()
			FreeObj(oVIIP5)
		Endif
	Endif
Else
	oVIIP1:Hide()	
	oVIIP2:Hide()		
	If ValType(oVIIP3)=="O"
		oVIIP3:Hide()
		oVIIP3:FreeChildren()
		FreeObj(oVIIP3)
	Endif
	If ValType(oVIIP4)=="O"
		oVIIP4:Hide()
		oVIIP4:FreeChildren()
		FreeObj(oVIIP4)
	Endif
	If ValType(oVIIP5)=="O"
		oVIIP5:Hide()
		oVIIP5:FreeChildren()
		FreeObj(oVIIP5)
	Endif
	oVIIMsg:Hide()
Endif                                                       
//================================================================================================================
//VIII-Atividade desenvolvida no Âmbito da Saude no Trabalho
//================================================================================================================
If	cIndo=="08"
	If oTree:CURRENTNODEID=="0000013"//"Mensagem para preenchimento na tela"
		oVIIIMsg:Show()		
	Else
		oVIIIMsg:Hide()
	Endif
	If oTree:CURRENTNODEID=="0000014"//"Desenvolvidas"
		oVIIIP1:Show()
	Else
		oVIIIP1:Hide()
	Endif	
	If oTree:CURRENTNODEID=="0000015"//"Promocao da Saude"
		If ValType(oVIIIP2)<>"O"
			VIIIPart2(oTree,oDlgMain)
		Endif	
	Else
		If ValType(oVIIIP2)=="O"
			oVIIIP2:Hide()
			oVIIIP2:FreeChildren()
			FreeObj(oVIIIP2)
		Endif
	Endif
Else
	oVIIIP1:Hide()
	If ValType(oVIIIP2)=="O"
		oVIIIP2:Hide()
		oVIIIP2:FreeChildren()
		FreeObj(oVIIIP2)
	Endif
	oVIIIMsg:Hide()
Endif
//================================================================================================================
//Capitulo IX - Acidentes de Trabalho e Doenças Profissionais
//================================================================================================================
If	cIndo=="09"
	oIX:Show()
Else
	oIX:Hide()
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³EmpSHST   ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo I - Empresa                     						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EmpSHST(oTree,oDlgMain)
Local oNomEnt,oEndEnt,oLocEnt,oCodPos,oSufPos,oLocPos,oTel,oFax,oCodDis,oCodCon,oCAE,oNEstC,oNEstA,oNEstM,oNPQH,oNPQM,oNNPQH,oNNPQM

oI	:= TFolder():New(012*nTamL,086*nTamC1,{STR0003},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])
@ 012*nTamL ,005 TO  244*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" 							PIXEL OF oI:aDialogs[1]

@ 030*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0022) 	        SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Nome ou designação social da Entidade"
@ 030*nTamL ,110*nTamC1 MSGET oNomEnt VAR aSHST[1]			SIZE 150*nTamBox,8 Picture "@!X70"   		PIXEL OF oI:aDialogs[1]
@ 050*nTamL ,010*nTamC1	SAY	  OemToAnsi(STR0023) 			SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Endereço"
@ 050*nTamL ,110*nTamC1	MSGET oEndEnt VAR aSHST[2]			SIZE 150*nTamBox,8 Picture "@!X60"   		PIXEL OF oI:aDialogs[1]
@ 070*nTamL ,010*nTamC1	SAY	  OemToAnsi(STR0024) 			SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Localidade"
@ 070*nTamL ,110*nTamC1 MSGET oLocEnt VAR aSHST[3] 			SIZE 150*nTamBox,8 Picture "@!X40"   		PIXEL OF oI:aDialogs[1]
@ 090*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0025) 	    	SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Codigo Postal"
@ 090*nTamL ,110*nTamC1 MSGET oCodPos VAR aSHST[4]			SIZE 020*nTamBox,8 Picture "@E 9999" 		PIXEL OF oI:aDialogs[1]
@ 110*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0026) 	    	SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Sufixo Postal"
@ 110*nTamL ,110*nTamC1 MSGET oSufPos VAR aSHST[5]			SIZE 020*nTamBox,8 Picture "@E 999"  		PIXEL OF oI:aDialogs[1]
@ 130*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0027) 	    	SIZE 150*nTamBox,7 					  		PIXEL OF oI:aDialogs[1]//"Localidade Postal"
@ 130*nTamL ,110*ntamC1 MSGET oLocPos VAR aSHST[6]			SIZE 150*nTamBox,8 Picture "@!X40" 			PIXEL OF oI:aDialogs[1]
@ 150*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0028) 	    	SIZE 150*nTamBox,7 							PIXEL OF oI:aDialogs[1]//"Telefone"
@ 150*nTamL ,110*nTamC1 MSGET oTel    VAR aSHST[7]			SIZE 040*nTamBox,8 Picture "@E 999999999" 	PIXEL OF oI:aDialogs[1]
@ 170*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0029) 	    	SIZE 150*nTamBox,7 							PIXEL OF oI:aDialogs[1]//"Fax"
@ 170*nTamL ,110*nTamC1 MSGET oFax    VAR aSHST[8]			SIZE 040*nTamBox,8 Picture "@E 999999999"	PIXEL OF oI:aDialogs[1]
@ 190*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0030) 	    	SIZE 150*nTamBox,7 							PIXEL OF oI:aDialogs[1]//"Código de Distrito"
@ 190*nTamL ,110*ntamC1 MSGET oCodDis VAR aSHST[9]			SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oI:aDialogs[1]
@ 210*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0031) 	    	SIZE 150*nTamBox,7 							PIXEL OF oI:aDialogs[1]//"Código de Concelho"
@ 210*nTamL ,110*nTamC1 MSGET oCodCon VAR aSHST[10]			SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oI:aDialogs[1]
@ 230*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0032) 	    	SIZE 150*nTamBox,7 							PIXEL OF oI:aDialogs[1]//"Código de Actividade Económica (CAE-Ver.2.1)"
@ 230*nTamL ,110*nTamC1 MSGET oCAE    VAR aSHST[11]			SIZE 020*nTamBox,8 Picture "@E 99999" 		PIXEL OF oI:aDialogs[1]


@ 030*nTamL ,250*nTamC1	SAY   OemToAnsi(STR0033) 	        SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº Estabelecimentos - Continente"
@ 030*nTamL ,370*nTamC1 MSGET oNEstC  VAR aSHST[12] 		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oI:aDialogs[1]
@ 050*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0034) 			SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº Estabelecimentos - R.A. Açores"
@ 050*nTamL ,370*nTamC1	MSGET oNEstA  VAR aSHST[13]			SIZE 020*nTamBox,8  Picture "@E 9999"  	PIXEL OF oI:aDialogs[1]
@ 070*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0035) 			SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº Estabelecimentos - R.A. Madeira"
@ 070*nTamL ,370*nTamC1	MSGET oNEstM  VAR aSHST[14]			SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oI:aDialogs[1]
@ 090*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0036) 			SIZE 150*nTamBox,7							PIXEL OF oI:aDialogs[1]//"Nº de Trabalhadores do Quadro-H"
@ 090*nTamL ,370*nTamC1	MSGET oNPQH   VAR aSHST[15]			SIZE 020*nTamBox,8	Picture "@E 99999" 		PIXEL OF oI:aDialogs[1]
@ 110*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0037) 			SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº de Trabalhadores do Quadro-M"
@ 110*nTamL ,370*nTamC1	MSGET oNPQM   VAR aSHST[16]			SIZE 020*nTamBox,8	Picture "@E 99999" 		PIXEL OF oI:aDialogs[1]
@ 130*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0038) 	    	SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº de Trabalhadores não pertencentes ao Quadro-H"
@ 130*nTamL ,370*nTamC1	MSGET oNNPQH  VAR aSHST[17]			SIZE 020*nTamBox,8	Picture "@E 99999" 		PIXEL OF oI:aDialogs[1]
@ 150*nTamL ,250*nTamC1	SAY	  OemToAnsi(STR0039) 	    	SIZE 150*nTamBox,7 						PIXEL OF oI:aDialogs[1]//"Nº de Trabalhadores não pertencentes ao Quadro-M"
@ 150*nTamL ,370*nTamC1	MSGET oNNPQM  VAR aSHST[18]			SIZE 020*nTamBox,8	Picture "@E 99999" 		PIXEL OF oI:aDialogs[1]


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³EstSHST   ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo II - Estabelecimento               						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EstSHST(oTree,oDlgMain)
Local oNomEst,oEndEst,oLocEst,oCodPosE,oSufPosE,oLocPosE,oTelE,oFaxE,oCodDisE,oCodConE,oCAEE,oNPQHE,oNPQME,oNNPQHE,oNNPQME,oNCSS
oII	:= TFolder():New(012*nTamL,086*nTamC1,{STR0004},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 012*nTamL ,5  	TO  244*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" 					PIXEL OF oII:aDialogs[1]

@ 030*nTamL,010*nTamC1 	SAY   OemToAnsi(STR0040) 	        SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Nome ou designação social"
@ 030*nTamL,110*ntamC1	MSGET oNomEst  VAR aSHST[19]		SIZE 150*nTamBox,8		Picture "@!X70"   		PIXEL OF oII:aDialogs[1]
@ 050*nTamL,010*nTamC1	SAY	  OemToAnsi(STR0041) 			SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Endereço Estabelecimento"
@ 050*nTamL,110*nTamC1	MSGET oEndEst  VAR aSHST[20]		SIZE 150*nTamBox,8  	Picture "@!X60"   		PIXEL OF oII:aDialogs[1]
@ 070*nTamL,010*nTamC1	SAY	  OemToAnsi(STR0024) 			SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Localidade"
@ 070*nTamL,110*nTamC1	MSGET oLocESt  VAR aSHST[21]		SIZE 150*nTamBox,8		Picture "@!X40"   		PIXEL OF oII:aDialogs[1]
@ 090*nTamL,010*nTamC1	SAY	  OemToAnsi(STR0025) 	    	SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Codigo Postal"
@ 090*nTamL,110*nTamC1	MSGET oCodPosE VAR aSHST[22] 		SIZE 020*nTamBox,8		Picture "@E 9999" 		PIXEL OF oII:aDialogs[1]
@ 110*nTamL,010*nTamC1	SAY	  OemToAnsi(STR0026) 	    	SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Sufixo Postal"
@ 110*nTamL,110*nTamC1	MSGET oSufPosE VAR aSHST[23] 		SIZE 020*nTamBox,8		Picture "@E 999"  		PIXEL OF oII:aDialogs[1]
@ 130*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0027) 	    	SIZE 150*nTamBox,7 					  			PIXEL OF oII:aDialogs[1]//"Localidade Postal"
@ 130*nTamL,110*nTamC1	MSGET oLocPosE VAR aSHST[24] 		SIZE 150*nTamBox,8		Picture "@!X40" 		PIXEL OF oII:aDialogs[1]
@ 150*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0028) 	    	SIZE 150*nTamBox,7 								PIXEL OF oII:aDialogs[1]//"Telefone"
@ 150*nTamL,110*nTamC1	MSGET oTelE    VAR aSHST[25]		SIZE 040*nTamBox,8		Picture "@E 999999999" 	PIXEL OF oII:aDialogs[1]
@ 170*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0029) 	    	SIZE 150*nTamBox,7 								PIXEL OF oII:aDialogs[1]//"Fax"
@ 170*nTamL,110*nTamC1	MSGET oFaxE    VAR aSHST[26]		SIZE 040*nTamBox,8		Picture "@E 999999999"	PIXEL OF oII:aDialogs[1]
@ 190*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0030) 	    	SIZE 150*nTamBox,7 								PIXEL OF oII:aDialogs[1]//"Código de Distrito"
@ 190*nTamL,110*nTamC1	MSGET oCodDisE VAR aSHST[27] 		SIZE 020*nTamBox,8		Picture "@E 99" 		PIXEL OF oII:aDialogs[1]
@ 210*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0031) 	    	SIZE 150*nTamBox,7 								PIXEL OF oII:aDialogs[1]//"Código de Concelho"
@ 210*nTamL,110*nTamC1	MSGET oCodConE VAR aSHST[28] 		SIZE 020*nTamBox,8		Picture "@E 99" 		PIXEL OF oII:aDialogs[1]
@ 230*nTamL,010*nTamC1 	SAY	  OemToAnsi(STR0032) 	    	SIZE 150*nTamBox,7 								PIXEL OF oII:aDialogs[1]//"C.A.E."
@ 230*nTamL,110*nTamC1	MSGET oCAEE    VAR aSHST[29]		SIZE 020*nTamBox,8		Picture "@E 99999" 		PIXEL OF oII:aDialogs[1]

@ 030*nTamL,240*nTamC1	SAY	  OemToAnsi(STR0036) 			SIZE 150*nTamBox,7									PIXEL OF oII:aDialogs[1]//"Nº de Trabalhadores do Quadro-H"
@ 030*nTamL,360*nTamC1	MSGET oNPQHE   VAR aSHST[30] 		SIZE 020*nTamBox,8		Picture "@E 99999" 			PIXEL OF oII:aDialogs[1]
@ 050*nTamL,240*nTamC1	SAY	  OemToAnsi(STR0037) 			SIZE 150*nTamBox,7 									PIXEL OF oII:aDialogs[1]//"Nº de Trabalhadores do Quadro-M"
@ 050*nTamL,360*nTamC1	MSGET oNPQME   VAR aSHST[31] 		SIZE 020*nTamBox,8		Picture "@E 99999" 			PIXEL OF oII:aDialogs[1]
@ 070*nTamL,240*nTamC1	SAY	  OemToAnsi(STR0038) 	    	SIZE 150*nTamBox,7 									PIXEL OF oII:aDialogs[1]//"Nº de Trabalhadores não pertencentes ao Quadro-H"
@ 070*nTamL,360*nTamC1	MSGET oNNPQHE  VAR aSHST[32]		SIZE 020*nTamBox,8		Picture "@E 99999" 			PIXEL OF oII:aDialogs[1]
@ 090*nTamL,240*nTamC1	SAY	  OemToAnsi(STR0039) 	    	SIZE 150*nTamBox,7 									PIXEL OF oII:aDialogs[1]//"Nº de Trabalhadores não pertencentes ao Quadro-M"
@ 090*nTamL,360*nTamC1	MSGET oNNPQME  VAR aSHST[33]		SIZE 020*nTamBox,8		Picture "@E 99999" 			PIXEL OF oII:aDialogs[1]
@ 110*nTamL,240*nTamC1	SAY	  OemToAnsi(STR0043) 	    	SIZE 150*nTamBox,7 									PIXEL OF oII:aDialogs[1]//"Nº de Contribuinte Segurança Social"
@ 110*nTamL,360*nTamC1	MSGET oNCSS    VAR aSHST[34]		SIZE 040*nTamBox,8		Picture "@E 99999999999" 	PIXEL OF oII:aDialogs[1]

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³OrgSHST   ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo III - Organizacao SHST             						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function OrgSHST(oTree,oDlgMain)
Local aSHS:={"1 - "+STR0047,"2 - "+STR0048},aAtivSH:={"1 - "+STR0049,"2 - "+STR0050,"3 - "+STR0051,"4 - "+STR0052},aAtivS:={"1 - "+STR0049,"2 - "+STR0050,"3 - "+STR0051,"4 - "+STR0052}
If Alltrim(aSHST[35])$"1|2"
	aSHST[35]:=aSHS[Val(aSHST[35])]
Endif
If Alltrim(aSHST[36])$"1|2|3|4"
	aSHST[36]:=aAtivSH[Val(aSHST[36])]
Endif	
If Alltrim(aSHST[37])$"1|2|3|4"
	aSHST[37]:=aAtivS[Val(aSHST[37])]
Endif	

oIII	:= TFolder():New(012*nTamL,086*nTamC1,{STR0005},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 012*nTamL ,005*nTamC1	TO   244*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" PIXEL OF oIII:aDialogs[1]
@ 030*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0044) 	        SIZE 200*nTamBox,7 		PIXEL OF oIII:aDialogs[1]//"Segurança, Higiene, e Saúde - Conjunto/Separado"
@ 030*nTamL ,156*nTamC1	COMBOBOX aSHST[35]	Items aSHS 		SIZE 150*nTamBox,8		PIXEL OF oIII:aDialogs[1]
@ 050*nTamL ,010*nTamC1	SAY	  OemToAnsi(STR0045) 			SIZE 200*nTamBox,7 		PIXEL OF oIII:aDialogs[1]//"Atividade de Segurança e Higiene"
@ 050*nTamL ,156*nTamC1	COMBOBOX aSHST[36] 	Items aAtivSH 	SIZE 150*nTamBox,8  	PIXEL OF oIII:aDialogs[1]
@ 070*nTamL ,010*nTamC1	SAY	  OemToAnsi(STR0046) 			SIZE 200*nTamBox,7 		PIXEL OF oIII:aDialogs[1]//"Atividade de Saúde"
@ 070*nTamL ,156*nTamC1	COMBOBOX aSHST[37] 	Items aAtivS 	SIZE 150*nTamBox,8  	PIXEL OF oIII:aDialogs[1]
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³ ServIntExt³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo IV - Servicos Internos e Externos						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ServIntExt(oTree,oDlgMain)
Local aPastServ	 := {STR0053,STR0054}//"Servicos Internos"#"Servicos Externos"
Local oIMTrb,oIETrb,oIOEnf,oITSH,oIOPes,oINRes
Local oEMTrb,oEETrb,oEOEnf,oETSH,oEOPes,oENRes
Local nIMTrb:=0,nIETrb:=0,nIOEnf:=0,nITSH:=0,nIOPes:=0
Local nEMTrb:=0,nEETrb:=0,nEOEnf:=0,nETSH:=0,nEOPes:=0
Local cINRes:=Space(70),cENRes:=Space(70),cENEmp:=Space(70)
oIV	:= TFolder():New(012*nTamL,086*nTamC1,aPastServ,{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])
//========================================================================================================
//Servicos Internos
//========================================================================================================
//Pessoal de SHST
@ 002*nTamL ,005 TO  280*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL STR0055 		PIXEL OF oIV:aDialogs[1] //"Pessoal de SHST"

@ 014*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0056)		SIZE 100*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Médicos do Trabalho"
@ 014*nTamL ,080*nTamC1 MSGET oIMTrb VAR aSHST[38]	SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oIV:aDialogs[1]
@ 040*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0057) 	SIZE 100*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Enfermeiros do Trabalho"
@ 040*nTamL ,080*nTamC1 MSGET oIETrb VAR aSHST[39] 	SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oIV:aDialogs[1]
@ 060*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0058) 	SIZE 100*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Outros Enfermeiros"
@ 060*nTamL ,080*nTamC1 MSGET oIOEnf VAR aSHST[40] 	SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oIV:aDialogs[1]
@ 014*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0059) 	SIZE 200*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Técnicos Segurança e Higiene"
@ 014*nTamL ,250*nTamC1 MSGET oITSH  VAR aSHST[41] 	SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oIV:aDialogs[1]
@ 040*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0060) 	SIZE 200*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Outro Pessoal"
@ 040*nTamL ,250*nTamC1 MSGET oIOPes VAR aSHST[42]	SIZE 020*nTamBox,8 Picture "@E 99" 			PIXEL OF oIV:aDialogs[1]
@ 060*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0061)		SIZE 200*nTamBox,7 							PIXEL OF oIV:aDialogs[1]//"Nome do Responsável dos Serviços Internos"
@ 060*nTamL ,250*nTamC1 MSGET oINRes VAR aSHST[43] 	SIZE 140*nTamBox,8 Picture "@!X70" 			PIXEL OF oIV:aDialogs[1]
//Medicos do Trabalho
@ 090*nTamL ,010*nTamC1 TO  170*nTamL,(aGdCoord[4]-150)*nTamLC2 LABEL STR0056 		PIXEL OF oIV:aDialogs[1] //"Medicos do Trabalho"

Aadd(aIHMTrb,{STR0062,"cNMedTRB","@!X70"   ,70,/*decimal*/,"NaoVazio()","€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nome Medico Trabalho"
Aadd(aIHMTrb,{STR0063,"nNCedPro","@E 99999",5 ,0          ,/*valid*/   ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Cédula Profissional MT"
Aadd(aIHMTrb,{STR0064,"nNHorMen","@E 999"  ,3 ,0          ,/*valid*/   ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Horas Mensais"
If Len(aICMTrb)==0
	aAux := {}
	Aadd(aAux,Space(70))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aICMTrb,aAux)
Endif
oGetIM:= MsNewGetDados():New(110*nTamL,020*nTamC1,160*nTamL,(aGdCoord[4]-160)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oIV:aDialogs[1],aIHMTrb,aICMTrb)
//Tecnicos SHST
@ 190*nTamL,010*nTamC1 TO  270*nTamL,(aGdCoord[4]-150)*nTamLC2 LABEL STR0065 PIXEL OF oIV:aDialogs[1] //"Tecnicos do SHST"
Aadd(aIHTTrb,{STR0066,"cNTecTRB","@X70"    ,70,/*decimal*/,"NaoVazio()"     ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nome do Tecnico de Seguranca e Higiene"
Aadd(aIHTTrb,{STR0067,"nNCertif","@!"      ,1 ,0          ,"Pertence('035')","€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,"0="+STR0070+";3="+STR0071+";5="+STR0072,"0"})//"Nivel de Certificacao"
If Len(aICTTrb)==0
	aAux := {}
	Aadd(aAux,Space(70))
	Aadd(aAux,"0")
	Aadd(aAux,.F.)
	Aadd(aICTTrb,aAux)
Endif
oGetIT:= MsNewGetDados():New(210*nTamL,20*nTamC1,260*nTamL,(aGdCoord[4]-160)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oIV:aDialogs[1],aIHTTrb,aICTTrb)
//========================================================================================================
//Servicos eXternos
//========================================================================================================
//Pessoal de SHST
@ 002*nTamL ,005 TO 280*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL STR0055		PIXEL OF oIV:aDialogs[2]//"Pessoal de SHST"
@ 014*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0056) 	    SIZE 100*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Médicos Trabalho"
@ 014*nTamL ,080*nTamC1 MSGET oEMTrb VAR aSHST[44]		SIZE 020*nTamBox,8	Picture "@E 99" PIXEL OF oIV:aDialogs[2]
@ 040*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0057)			SIZE 100*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Enfermeiros do Trabalho"
@ 040*nTamL ,080*nTamC1 MSGET oEETrb VAR aSHST[45]		SIZE 020*nTamBox,8 Picture "@E 99" PIXEL OF oIV:aDialogs[2]
@ 060*nTamL ,010*nTamC1 SAY  OemToAnsi(STR0058)			SIZE 100*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Outros Enfermeiros"
@ 060*nTamL ,080*nTamC1 MSGET oEOEnf VAR aSHST[46]		SIZE 020*nTamBox,8	Picture "@E 99" PIXEL OF oIV:aDialogs[2]
@ 016*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0059) 	    SIZE 200*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Técnicos Segurança e Higiene"
@ 016*nTamL ,250*nTamC1 MSGET oETSH  VAR aSHST[47] 		SIZE 020*nTamBox,8	Picture "@E 99" PIXEL OF oIV:aDialogs[2]
@ 016*nTamL ,290*nTamC1 SAY  OemToAnsi(STR0060) 		SIZE 200*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Outro Pessoal"
@ 016*nTamL ,350*nTamC1 MSGET oEOPes VAR aSHST[48]  	SIZE 020*nTamBox,8 Picture "@E 99" PIXEL OF oIV:aDialogs[2]
@ 040*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0068) 		SIZE 200*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Nome Empresa(s) Prestadora(s)"
@ 040*nTamL ,250*nTamC1 MSGET oENEmp VAR aSHST[49]  	SIZE 150*nTamBox,8	Picture "@!X70" PIXEL OF oIV:aDialogs[2]
@ 060*nTamL ,130*nTamC1 SAY  OemToAnsi(STR0069) 		SIZE 200*nTamBox,7 				PIXEL OF oIV:aDialogs[2]//"Nome do Responsável dos Serviços Externos"
@ 060*nTamL ,250*nTamC1 MSGET oENRes VAR aSHST[50]  	SIZE 150*nTamBox,8	Picture "@!X70" PIXEL OF oIV:aDialogs[2]

//Medicos do Trabalho
@ 090*nTamL ,010*nTamC1 TO  170*nTamL,(aGdCoord[4]-150)*nTamLC2 LABEL STR0056 	PIXEL OF oIV:aDialogs[2] //"Medicos do Trabalho"
Aadd(aEHMTrb,{STR0062,"cNMedTRB","@X70"    ,70,/*decimal*/,"NaoVazio()","€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nome Medico Trabalho"
Aadd(aEHMTrb,{STR0063,"nNCedPro","@E 99999",5 ,0          ,/*valid*/   ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Cédula Profissional MT"
Aadd(aEHMTrb,{STR0064,"nNHorMen","@E 999"  ,3 ,0          ,/*valid*/   ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Horas Mensais"
If Len(aECMTrb)==0
	aAux := {}
	Aadd(aAux,Space(70))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aECMTrb,aAux)
Endif
oGetEM:= MsNewGetDados():New(110*nTamL,020*nTamC1,160*nTamL,(aGdCoord[4]-160)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oIV:aDialogs[2],aEHMTrb,aECMTrb)

//Tecnicos SHST
@ 190*nTamL,010*nTamC1 TO  270*nTamL,(aGdCoord[4]-150)*nTamLC2 LABEL STR0065 PIXEL OF oIV:aDialogs[2] //"Tecnicos do SHST"

Aadd(aEHTTrb,{STR0066,"cNTecTRB","@!X70"   ,70,/*decimal*/,"NaoVazio()"     ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nome do Tecnico de Seguranca e Higiene"
Aadd(aEHTTrb,{STR0067,"nNCertif","@!"      ,1 ,0          ,"Pertence('035')","€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,"0="+STR0070+";3="+STR0071+";5="+STR0072,"0"})//"Nivel de Certificacao"
If Len(aECTTrb)==0
	aAux := {}
	Aadd(aAux,Space(70))
	Aadd(aAux,"0")
	Aadd(aAux,.F.)
	Aadd(aECTTrb,aAux)
Endif
oGetET:= MsNewGetDados():New(210*nTamL,20*nTamC1,260*nTamL,(aGdCoord[4]-160)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oIV:aDialogs[2],aEHTTrb,aECTTrb)

oIV:Hide()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³PesEstSHST  ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo V - Pessoas no Estabelecimento     						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesEstSHST(oTree,oDlgMain)
Local oTM18H,oT1849H,oTM49H,oTHorNH,oTTFixH,oTTRotH,oTHNotH,oTOutHH,oTM18M,oT1849M,oTM49M,oTHorNM,oTTFixM,oTTRotM,oTHNotM,oTOutHM,oHorTot

oV	:= TFolder():New(012*nTamL,086*nTamC1,{STR0007},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 012*nTamL,005*nTamC1 TO  192*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" PIXEL OF oV:aDialogs[1]
@ 210*nTamL,005*nTamC1 TO  242*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" PIXEL OF oV:aDialogs[1]

@ 012*nTamL,110*nTamC1 SAY  OemToAnsi(STR0073) 			SIZE 050*nTamBox,7						   	PIXEL OF oV:aDialogs[1]//"Homem"
@ 012*nTamL,170*nTamC1 SAY  OemToAnsi(STR0074) 			SIZE 050*nTamBox,7 							PIXEL OF oV:aDialogs[1]//"Mulher"
@ 032*nTamL,010*nTamC1 SAY  OemToAnsi(STR0075) 	        SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. < 18 anos"
@ 052*nTamL,010*nTamC1 SAY  OemToAnsi(STR0076) 			SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. 18 a 49 anos"
@ 072*nTamL,010*nTamC1 SAY  OemToAnsi(STR0077) 			SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. > 49 anos"
@ 092*nTamL,010*nTamC1 SAY  OemToAnsi(STR0078) 	    	SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. Horário Normal"
@ 112*nTamL,010*nTamC1 SAY  OemToAnsi(STR0079) 	    	SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. Turno Fixo"
@ 132*nTamL,010*nTamC1 SAY  OemToAnsi(STR0080) 	    	SIZE 100*nTamBox,7 					  		PIXEL OF oV:aDialogs[1]//"Trab. Turno Rotativo"
@ 152*nTamL,010*nTamC1 SAY  OemToAnsi(STR0081) 	    	SIZE 100*nTamBox,7 							PIXEL OF oV:aDialogs[1]//"Trab. Horário Noturno"
@ 172*nTamL,010*nTamC1 SAY  OemToAnsi(STR0082) 	    	SIZE 100*nTamBox,7 							PIXEL OF oV:aDialogs[1]//"Trab. Outros Horários"
@ 220*nTamL,010*nTamC1 SAY  OemToAnsi(STR0083) 	    	SIZE 100*nTamBox,7 							PIXEL OF oV:aDialogs[1]//"Nº Total horas trabalhadas"


@ 032*nTamL ,110*nTamC1	MSGET oTM18H  VAR aSHST[51]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 032*nTamL ,170*nTamC1 MSGET oTM18M  VAR aSHST[59]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 052*nTamL ,110*nTamC1	MSGET oT1849H VAR aSHST[52]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 052*nTamL ,170*nTamC1	MSGET oT1849M VAR aSHST[60]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 072*nTamL ,110*nTamC1	MSGET oTM49H  VAR aSHST[53]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 072*nTamL ,170*nTamC1	MSGET oTM49M  VAR aSHST[61]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 092*nTamL ,110*nTamC1	MSGET oTHorNH VAR aSHST[54]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 092*nTamL ,170*nTamC1	MSGET oTHorNM VAR aSHST[62]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 112*nTamL ,110*nTamC1	MSGET oTTFixH VAR aSHST[55]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 112*nTamL ,170*nTamC1	MSGET oTTFixM VAR aSHST[63]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 132*nTamL ,110*nTamC1	MSGET oTTRotH VAR aSHST[56]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 132*nTamL ,170*nTamC1	MSGET oTTRotM VAR aSHST[64]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 152*nTamL ,110*nTamC1	MSGET oTHNotH VAR aSHST[57]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 152*nTamL ,170*nTamC1	MSGET oTHNotM VAR aSHST[65]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 172*nTamL ,110*nTamC1	MSGET oTOutHH VAR aSHST[58]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]
@ 172*nTamL ,170*nTamC1	MSGET oTOutHM VAR aSHST[66]	Valid Positivo() SIZE 20*nTamBox,8	Picture "@E 9999" 		PIXEL OF oV:aDialogs[1]

@ 220*nTamL ,110*nTamC1	MSGET oHorTot VAR aSHST[67]	Valid Positivo() SIZE 40*nTamBox,8	Picture "@E 999999999"	PIXEL OF oV:aDialogs[1]
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VISHST   ³ Autor ³ Marcos Kato		 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capitulo VI - Atividade SHST			     						 ³±±
±±³			 ³ Objetivos Programados/Riscos  		     						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VISHST(oTree,oDlgMain)
Local oObjPro1,oObjRis,oRiscH1,oRiscH2,oRiscH3,oRiscH4,oRiscH5,oRiscH6,oRiscH7,oRiscM1,oRiscM2,oRiscM3,oRiscM4,oRiscM5,oRiscM6,oRiscM7
Local oASForH,oASForM
Local oRCDes1,oRCDes2,oRCDes3,oRCDes4,oRCDes5,oRCDes6,oRCDes7
Local oRCFor1,oRCFor2,oRCFor3,oRCFor4,oRCFor5,oRCFor6,oRCFor7
Local oRCNAc1,oRCNAc2,oRCNAc3,oRCNAc4,oRCNAc5,oRCNAc6,oRCNAc7
//===========================================================================================
//Pasta 1 - Objetivos Programados                                                                      
//===========================================================================================
oVI	:= TFolder():New(012*nTamL,086*nTamC1,{STR0084+"/"+STR0085,STR0086,STR0091,STR0092},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])
@ 002*nTamL ,005*nTamC1   TO  072*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0084 					  		PIXEL OF oVI:aDialogs[1]//Objetivos Programados
@ 012*nTamL ,010*nTamC1   GET oObjPro1 Var aSHST[68] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[68]))>200,(MsgAlert(STR0084+"-"+STR0291+". "+STR0362+": "+ALLTRIM(Str(Len(alltrim(aSHST[68])))),STR0292),.F.),.T.) 	PIXEL OF  oVI:aDialogs[1]//caractere
oObjPro1:lWordWrap:= .T.
//oObjPro1:EnableHScroll( .T. )
oObjPro1:EnableVScroll( .T. )
//===========================================================================================
//Pasta 1 - Riscos
//===========================================================================================
@ 080*nTamL,005*nTamC1  TO  260*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0085			PIXEL OF oVI:aDialogs[1]//"Riscos"
@ 090*nTamL,060*nTamC1	SAY   OemToAnsi(STR0073) 	SIZE 050*nTamBox,7 	   					PIXEL OF oVI:aDialogs[1]//"Homem"
@ 090*nTamL,110*nTamC1	SAY   OemToAnsi(STR0074) 	SIZE 050*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Mulher"
@ 090*nTamL,250*nTamC1	SAY   OemToAnsi(STR0073) 	SIZE 050*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Homem"
@ 090*nTamL,300*nTamC1	SAY   OemToAnsi(STR0074) 	SIZE 050*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Mulher"

@ 100*nTamL ,010*nTamC1 SAY OemToAnsi(STR0100+"-1") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 120*nTamL ,010*nTamC1 SAY OemToAnsi(STR0100+"-2") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 140*nTamL ,010*nTamC1 SAY OemToAnsi(STR0100+"-3") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 160*nTamL ,010*nTamC1 SAY OemToAnsi(STR0100+"-4") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 100*nTamL ,200*nTamC1 SAY OemToAnsi(STR0100+"-5") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 120*nTamL ,200*nTamC1 SAY OemToAnsi(STR0100+"-6") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 140*nTamL ,200*nTamC1 SAY OemToAnsi(STR0100+"-7") 	SIZE 100*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Inform.Riscos"
@ 100*nTamL ,060*nTamC1 MSGET oRiscH1 VAR aSHST[69]`	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 100*nTamL ,110*nTamC1 MSGET oRiscM1 VAR aSHST[70] 	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 120*nTamL ,060*nTamC1 MSGET oRiscH2 VAR aSHST[71]	SIZE 020*nTamBox,8 Picture "@E 9999"  	PIXEL OF oVI:aDialogs[1]
@ 120*nTamL ,110*nTamC1 MSGET oRiscM2 VAR aSHST[72]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 140*nTamL ,060*nTamC1 MSGET oRiscH3 VAR aSHST[73]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 140*nTamL ,110*nTamC1 MSGET oRiscM3 VAR aSHST[74]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 160*nTamL ,060*nTamC1 MSGET oRiscH4 VAR aSHST[75]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 160*nTamL ,110*nTamC1 MSGET oRiscM4 VAR aSHST[76]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]

@ 100*nTamL ,250*nTamC1 MSGET oRiscH5 VAR aSHST[77]	SIZE 020*nTamBox,8 Picture "@E 9999"  	PIXEL OF oVI:aDialogs[1]
@ 100*nTamL ,300*nTamC1 MSGET oRiscM5 VAR aSHST[78]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 120*nTamL ,250*nTamC1 MSGET oRiscH6 VAR aSHST[79]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 120*nTamL ,300*nTamC1 MSGET oRiscM6 VAR aSHST[80]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 140*nTamL ,250*nTamC1 MSGET oRiscH7 VAR aSHST[81]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 140*nTamL ,300*nTamC1 MSGET oRiscM7 VAR aSHST[82]	SIZE 020*nTamBox,8 Picture "@E 9999" 	PIXEL OF oVI:aDialogs[1]
@ 180*nTamL ,010*nTamC1 SAY OemToAnsi(STR0088) 		SIZE 200*nTamBox,7 						PIXEL OF oVI:aDialogs[1]//"Meios utilizados para circulação da informação"
@ 190*nTamL ,010*nTamC1 GET oObjRis Var aSHST[83] 	MEMO  Size 360*nTamC1,40*nTamL; 
Valid Iif(Len(alltrim(aSHST[142]))>200,(MsgAlert(STR0088+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[142])))),STR0292),.F.),.T.) 	PIXEL OF oVI:aDialogs[1]
oObjRis:lWordWrap:= .T.
//oObjRis:EnableHScroll( .T. )
oObjRis:EnableVScroll( .T. )

//====================================================================================================================================
//Pasta 2 - Formação                                                                                                                            
//====================================================================================================================================
@ 002*nTamL ,005*nTamC1 TO  160*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL STR0089 PIXEL OF oVI:aDialogs[2] //"Ações de Formação"

Aadd(aHAcFor,{STR0101					,"cObAfor","@X100"  ,100,/*decimal*/,"NaoVazio()" ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Objetivos da Ação Formação"
Aadd(aHAcFor,{STR0102					,"nNAReal","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Ações realizadas"
Aadd(aHAcFor,{STR0103					,"nDurMed","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Duração média cada ação (horas)"
Aadd(aHAcFor,{STR0104					,"cDestin","@X100"  ,100,/*decimal*/,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Destinatários"
Aadd(aHAcFor,{STR0105+"("+STR0073+")"	,"nNPartH","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Participantes"#"Homem"
Aadd(aHAcFor,{STR0105+"("+STR0074+")"	,"nNPartM","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Participantes"#"Mulher"

If Len(aCAcFor)==0
	aAux := {}
	Aadd(aAux,Space(100))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,Space(100))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aCAcFor,aAux)
Endif
oGetAF:= MsNewGetDados():New(014*nTamL,010*nTamC1,120*nTamL,(aGdCoord[4]-150)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVI:aDialogs[2],aHAcFor,aCAcFor)
@ 180*nTamL ,005*nTamC1 	TO  280*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL STR0090 			PIXEL OF oVI:aDialogs[2] //"Sem ações de Formação"	@ 22-8  ,106-050 	SAY   OemToAnsi(STR0073) 		SIZE 50 ,7 						PIXEL OF oVIP2:aDialogs[1]//"Homem"
@ 200*nTamL ,080*nTamC1 	SAY   OemToAnsi(STR0073) 			SIZE 050*nTamBox,7						PIXEL OF oVI:aDialogs[2]//"Homem"
@ 200*nTamL ,140*nTamC1 	SAY   OemToAnsi(STR0074) 			SIZE 050*nTamBox,7						PIXEL OF oVI:aDialogs[2]//"Mulher"
@ 220*nTamL ,010*nTamC1 	SAY   OemToAnsi(STR0106)	 		SIZE 100*nTamBox,7						PIXEL OF oVI:aDialogs[2]//Nº Trab. Sem Formação
@ 220*nTamL ,080*nTamC1 	MSGET oASForH VAR aSHST[84]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[2]
@ 220*nTamL ,140*nTamC1 	MSGET oASForM VAR aSHST[85]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[2]
//====================================================================================================================================
//Pasta 3 - Formação a Pessoal de SHST
//====================================================================================================================================
@ 002*nTamL ,005 TO 160*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL "" 				PIXEL OF oVI:aDialogs[3]

Aadd(aHForPe,{STR0101					,"cObSHST","@X100"  ,100,/*decimal*/,"NaoVazio()" ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Objetivos da Ação Formação"
Aadd(aHForPe,{STR0102					,"nNASHST","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Ações realizadas"
Aadd(aHForPe,{STR0103					,"nDmSHST","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Duração média cada ação (horas)"
Aadd(aHForPe,{STR0105+"("+STR0073+")"	,"nPHSHST","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Participantes"#"Homem"
Aadd(aHForPe,{STR0105+"("+STR0074+")"	,"nPMSHST","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº Participantes"#"Mulher"

If Len(aCForPe)==0
	aAux := {}
	Aadd(aAux,Space(100))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aCForPe,aAux)
Endif
oGetFP:= MsNewGetDados():New(014*nTamL,010*nTamC1,100*nTamL,(aGdCoord[4]-150)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVI:aDialogs[3],aHForPe,aCForPe)
//====================================================================================================================================
//Pasta 4 - Consulta aos Trabalhadores
//====================================================================================================================================
@ 002*nTamL ,005*nTamC1 TO  260*nTamL,(aGdCoord[4]-130)*nTamLC2 LABEL STR0109  PIXEL OF oVI:aDialogs[4]//Razões Consulta


@ 030*nTamL ,010*nTamC1 SAY   "1" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 045*nTamL ,010*nTamC1 SAY   "2" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 060*nTamL ,010*nTamC1 SAY   "3" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 075*nTamL ,010*nTamC1 SAY   "4" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 090*nTamL ,010*nTamC1 SAY   "5" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 105*nTamL ,010*nTamC1 SAY   "6" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]
@ 120*nTamL ,010*nTamC1 SAY   "7" 		SIZE 50*nTamBox,7 								PIXEL OF oVI:aDialogs[4]

@ 015*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0104) 		SIZE 100*nTamBox,7 					PIXEL OF oVI:aDialogs[4]//"Destinatarios"
@ 015*nTamL ,186*nTamC1	SAY   OemToAnsi(STR0107) 		SIZE 100*nTamBox,7 					PIXEL OF oVI:aDialogs[4]//"Forma"
@ 015*nTamL ,346*nTamC1	SAY   OemToAnsi(STR0108) 		SIZE 100*nTamBox,7 					PIXEL OF oVI:aDialogs[4]//"Nº Ações"

@ 030*nTamL ,026*nTamC1	MSGET oRCDes1 VAR aSHST[86]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 030*nTamL ,186*nTamC1	MSGET oRCFor1 VAR aSHST[93]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 030*nTamL ,346*nTamC1	MSGET oRCNAc1 VAR aSHST[100]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 045*nTamL ,026*nTamC1	MSGET oRCDes2 VAR aSHST[87]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 045*nTamL ,186*nTamC1	MSGET oRCFor2 VAR aSHST[94]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 045*nTamL ,346*nTamC1	MSGET oRCNAc2 VAR aSHST[101]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 060*nTamL ,026*nTamC1	MSGET oRCDes3 VAR aSHST[88]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 060*nTamL ,186*nTamC1	MSGET oRCFor3 VAR aSHST[95]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 060*nTamL ,346*nTamC1	MSGET oRCNAc3 VAR aSHST[102]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 075*nTamL ,026*nTamC1	MSGET oRCDes4 VAR aSHST[89]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 075*nTamL ,186*nTamC1	MSGET oRCFor4 VAR aSHST[96]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 075*nTamL ,346*nTamC1	MSGET oRCNAc4 VAR aSHST[103]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 090*nTamL ,026*nTamC1	MSGET oRCDes5 VAR aSHST[90]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 090*nTamL ,186*nTamC1	MSGET oRCFor5 VAR aSHST[97]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 090*nTamL ,346*nTamC1	MSGET oRCNAc5 VAR aSHST[104]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 105*nTamL ,026*nTamC1	MSGET oRCDes6 VAR aSHST[91]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 105*nTamL ,186*nTamC1	MSGET oRCFor6 VAR aSHST[98]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 105*nTamL ,346*nTamC1	MSGET oRCNAc6 VAR aSHST[105]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 120*nTamL ,026*nTamC1	MSGET oRCDes7 VAR aSHST[92]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 120*nTamL ,186*nTamC1	MSGET oRCfor7 VAR aSHST[99]		SIZE 160*nTamBox,8	Picture "@!X100" 	PIXEL OF oVI:aDialogs[4]
@ 120*nTamL ,346*nTamC1	MSGET oRCNAc7 VAR aSHST[106]	SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVI:aDialogs[4]

@ 150*nTamL,10*nTamC1 SAY   OemToAnsi("1-"+STR0110) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Medidas de higiene e segurança a aplicar"
@ 160*nTamL,10*nTamC1 SAY   OemToAnsi("2-"+STR0111) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Outras medidas com reflexos na segurança,higiene e saúde do trabalho (SHST)"
@ 170*nTamL,10*nTamC1 SAY   OemToAnsi("3-"+STR0112) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Programação e organização da formação"
@ 180*nTamL,10*nTamC1 SAY   OemToAnsi("4-"+STR0113) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Designação de trabalhadores para a área da SHST"
@ 190*nTamL,10*nTamC1 SAY   OemToAnsi("5-"+STR0114+" "+STR0115) 	SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Designação de trabalhadores para a aplicação de medidas de primeiros socorros, combate a"#"incêndios e evacuação de trabalhadores"
@ 200*nTamL,10*nTamC1 SAY   OemToAnsi("6-"+STR0116) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Aquisição de EPI (equipamento de proteção individual)"
@ 210*nTamL,10*nTamC1 SAY   OemToAnsi("7-"+STR0117) 				SIZE 300*nTamBox,7			PIXEL OF oVI:aDialogs[4]//"Outras razões"
oVI:Hide()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIPart1	   ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VII-Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho ³±±
±±³			 ³ Parte I -Condições de trabalho e avaliação de riscos profissionais³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function VIIPart1(oTree,oDlgMain)
oVIIp1	:= TFolder():New(012*nTamL,086*nTamC1,{STR0093},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])//"Condições de trabalho e avaliação de riscos profissionais"

@ 002*nTamL ,005*nTamC1  TO  120*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0121 			  	PIXEL OF oVIIP1:aDialogs[1]//"Avaliação do risco e adoção de medidas na fase de projeto"
                                                      
aSHST[107]:=Iif(Alltrim(aSHST[107])=="0",aOK[1],aOK[2])
aSHST[112]:=Iif(Alltrim(aSHST[112])=="0",aOK[1],aOK[2])
aSHST[117]:=Iif(Alltrim(aSHST[117])=="0",aOK[1],aOK[2])
aSHST[122]:=Iif(Alltrim(aSHST[122])=="0",aOK[1],aOK[2])

@ 014*nTamL ,110*nTamC1 SAY   OemToAnsi(STR0123) 	        SIZE 100*nTamBox,7 	PIXEL OF oVIIP1:aDialogs[1]//"Intervenção"
@ 014*nTamL ,170*nTamC1	SAY	  OemToAnsi(STR0124+" 1") 		SIZE 100*nTamBox,7 	PIXEL OF oVIIP1:aDialogs[1]//"Natureza"
@ 014*nTamL ,230*nTamC1	SAY	  OemToAnsi(STR0124+" 2") 		SIZE 100*nTamBox,7 	PIXEL OF oVIIP1:aDialogs[1]//"Natureza"
@ 014*nTamL ,290*nTamC1	SAY	  OemToAnsi(STR0124+" 3") 		SIZE 100*nTamBox,7 	PIXEL OF oVIIP1:aDialogs[1]//"Natureza"
@ 014*nTamL ,350*nTamC1	SAY	  OemToAnsi(STR0124+" 4")		SIZE 100*nTamBox,7 	PIXEL OF oVIIP1:aDialogs[1]//"Natureza"

@ 030*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0125) 	        	SIZE 100*nTamBox,7 PIXEL OF oVIIP1:aDialogs[1]//"Instalações"
@ 030*nTamL ,110*nTamC1 COMBOBOX aSHST[107] Items aOk 			SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 030*nTamL ,170*nTamC1 COMBOBOX aSHST[108] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 030*nTamL ,230*nTamC1 COMBOBOX aSHST[109] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 030*nTamL ,290*nTamC1 COMBOBOX aSHST[110] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 030*nTamL ,350*nTamC1 COMBOBOX aSHST[111] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]

@ 050*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0126) 	        	SIZE 100*nTamBox,7 PIXEL OF oVIIP1:aDialogs[1]//"Equipamento"
@ 050*nTamL ,110*nTamC1 COMBOBOX aSHST[112] Items aOK 			SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 050*nTamL ,170*nTamC1 COMBOBOX aSHST[113] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 050*nTamL ,230*nTamC1 COMBOBOX aSHST[114] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 050*nTamL ,290*nTamC1 COMBOBOX aSHST[115] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 050*nTamL ,350*nTamC1 COMBOBOX aSHST[116] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]

@ 070*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0127) 	        SIZE 100*nTamBox,7 PIXEL OF oVIIP1:aDialogs[1]//"Processos de Trabalho"
@ 070*nTamL ,110*nTamC1 COMBOBOX aSHST[117] Items aOk 	 	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 070*nTamL ,170*nTamC1 COMBOBOX aSHST[118] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 070*nTamL ,230*nTamC1 COMBOBOX aSHST[119] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 070*nTamL ,290*nTamC1 COMBOBOX aSHST[120] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 070*nTamL ,350*nTamC1 COMBOBOX aSHST[121] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]

@ 090*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0128) 	        SIZE 100*nTamBox,7 PIXEL OF oVIIP1:aDialogs[1]//"Postos de Trabalho"
@ 090*nTamL ,110*nTamC1 COMBOBOX aSHST[122] Items aOk 	  	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 090*nTamL ,170*nTamC1 COMBOBOX aSHST[123] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 090*nTamL ,230*nTamC1 COMBOBOX aSHST[124] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 090*nTamL ,290*nTamC1 COMBOBOX aSHST[125] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]
@ 090*nTamL ,350*nTamC1 COMBOBOX aSHST[126] Items aNatureza	SIZE 050*nTamBox,8 PIXEL OF oVIIP1:aDialogs[1]

@ 130*nTamL,005*nTamC1 TO  260*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0122 				PIXEL OF oVIIP1:aDialogs[1]//"Auditorias internas e externas no âmbito da Segurança, Higiene e Saúde no Trabalho"
Aadd(aHAudit,{STR0129					,"cNomAud","@!X70"  ,70 ,/*decimal*/,"NaoVazio()" ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nome Empresa Auditora"
Aadd(aHAudit,{STR0130					,"nNumAud","@E 99" ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Nº de Auditorias"

If Len(aCAudit)==0
	aAux := {}
	Aadd(aAux,Space(70))
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aCAudit,aAux)
Endif
oGetAud:= MsNewGetDados():New(140*nTamL,010*nTamC1,240*nTamL,(aGdCoord[4]-150)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVIIP1:aDialogs[1],aHaudit,aCAudit)
oVIIP1:Hide()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIPart2	   ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VII-Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho ³±±
±±³			 ³ ParteII-Intervenções técnicas no controle do ambiente de trabalho ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                         
Static Function VIIPart2 (oTree,oDlgMain)//"Intervenções técnicas no controle do ambiente de trabalho"
Local oNAvalI1,oNAvalI2,oNAvalI3,oNAvalI4,oNAvalI5,oNAvalT1,oNAvalT2,oNAvalT3,oNAvalT4,oNAvalT5,oNAvalT6,oNAvalT7,oDAvalI5,oDAvalT7
Local oNorRefI1,oTecAvaI1,oPosTraI1,oNorRefI2,oTecAvaI2,oPosTraI2,oNorRefT1,oTecAvaT1,oPosTraT1,oNorRefT2,oTecAvaT2,oPosTraT2,oILDes12
Local oNrIlu,oTecAvIlu,oPostIlu,oNrAmT,oTecAvAmt,oPostAmt,oOutAFis ,oOutMFis,oOutAQui,oOutMQui,oNrQui,oTecAvQui,oOutABio,oOutMBio,oTecAvBio

aSHST[127]:=Iif(Alltrim(aSHST[127])=="0",aOK[1],aOK[2])
aSHST[128]:=Iif(Alltrim(aSHST[128])=="0",aOK[1],aOK[2])
aSHST[129]:=Iif(Alltrim(aSHST[129])=="0",aOK[1],aOK[2])
aSHST[130]:=Iif(Alltrim(aSHST[130])=="0",aOK[1],aOK[2])

aSHST[132]:=Iif(Alltrim(aSHST[132])=="A",aSituacao[1],aSituacao[2])
aSHST[134]:=Iif(Alltrim(aSHST[134])=="A",aSituacao[1],aSituacao[2])
aSHST[136]:=Iif(Alltrim(aSHST[136])=="A",aSituacao[1],aSituacao[2])
aSHST[138]:=Iif(Alltrim(aSHST[138])=="A",aSituacao[1],aSituacao[2])
aSHST[140]:=Iif(Alltrim(aSHST[140])=="A",aSituacao[1],aSituacao[2])
aSHST[146]:=Iif(Alltrim(aSHST[146])=="A",aSituacao[1],aSituacao[2])
aSHST[148]:=Iif(Alltrim(aSHST[148])=="A",aSituacao[1],aSituacao[2])
aSHST[150]:=Iif(Alltrim(aSHST[150])=="A",aSituacao[1],aSituacao[2])
aSHST[152]:=Iif(Alltrim(aSHST[152])=="A",aSituacao[1],aSituacao[2])
aSHST[154]:=Iif(Alltrim(aSHST[154])=="A",aSituacao[1],aSituacao[2])
aSHST[156]:=Iif(Alltrim(aSHST[156])=="A",aSituacao[1],aSituacao[2])
aSHST[159]:=Iif(Alltrim(aSHST[159])=="A",aSituacao[1],aSituacao[2])


oVIIP2	:= TFolder():New(012*nTamL,086*nTamC1,{STR0150,STR0162,STR0163,STR0185,STR0201},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])//"Iluminação"#"Ambiente Termico"#Agentes Fisicos#"Agentes químicos"#"Agentes biológicos"

//===================================================================================================================================
//Iluminacao                                                                                                                         
//===================================================================================================================================
@ 002*nTamL ,005*nTamC1 TO  045*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0137 	PIXEL OF oVIIP2:aDialogs[1]//"Tipo de Iluminação"
@ 014*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0138) 	    		SIZE 50*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Natural"
@ 014*nTamL ,060*nTamC1 COMBOBOX aSHST[127]	Items aOk 		SIZE 50*nTamBox,8	PIXEL OF oVIIP2:aDialogs[1]
@ 014*nTamL ,160*nTamC1 SAY   OemToAnsi(STR0139) 	    		SIZE 50*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Artificial"
@ 014*nTamL ,210*nTamC1 COMBOBOX aSHST[128]	Items aOk 		SIZE 50*nTamBox,8	PIXEL OF oVIIP2:aDialogs[1]
@ 030*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0140) 	    		SIZE 50*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Mista"
@ 030*nTamL ,060*nTamC1 COMBOBOX aSHST[129]	Items aOk		SIZE 50*nTamBox,8	PIXEL OF oVIIP2:aDialogs[1]
@ 030*nTamL ,160*nTamC1 SAY   OemToAnsi(STR0141)				SIZE 50*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Emergencial"
@ 030*nTamL ,210*nTamC1 COMBOBOX aSHST[130]	Items aOk 		SIZE 50*nTamBox,8	PIXEL OF oVIIP2:aDialogs[1]

@ 050*nTamL ,005*nTamC1 TO  125*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL STR0149 	PIXEL OF oVIIP2:aDialogs[1]//"Medidas Adotadas"
@ 060*nTamL ,130*nTamC1 SAY   OemToAnsi(STR0142) 	    		SIZE 080*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Nº de Avaliações"
@ 060*nTamL ,170*nTamC1 SAY   OemToAnsi(STR0143) 	    		SIZE 100*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Resultado"
@ 060*nTamL ,280*nTamC1 SAY   OemToAnsi(STR0142) 	    		SIZE 080*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Nº de Avaliações"
@ 060*nTamL ,320*nTamC1 SAY   OemToAnsi(STR0143) 	    		SIZE 100*nTamBox,7 	PIXEL OF oVIIP2:aDialogs[1]//"Resultado"

@ 070*nTamL ,030*nTamC1 SAY   OemToAnsi(STR0144) 	    		SIZE 100*nTamBox,7 						PIXEL OF oVIIP2:aDialogs[1]//"Mudança no sistema de iluminação"
@ 070*nTamL ,130*nTamC1 MSGET oNAvalI1 VAR aSHST[131]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[1]
@ 070*nTamL ,170*nTamC1 COMBOBOX aSHST[132] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[1]

@ 090*nTamL ,030*nTamC1 SAY   OemToAnsi(STR0145) 	    		SIZE 100*nTamBox,7 						PIXEL OF oVIIP2:aDialogs[1]//"Introdução de pausas no trabalho"
@ 090*nTamL ,130*nTamC1 MSGET oNAvalI2 VAR aSHST[133]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[1]
@ 090*nTamL ,170*nTamC1 COMBOBOX aSHST[134] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[1]
@ 110*nTamL ,030*nTamC1 SAY   OemToAnsi(STR0146)	    		SIZE 150*nTamBox,7 						PIXEL OF oVIIP2:aDialogs[1]//"Modificação da iluminação em função da tarefa"
@ 110*nTamL ,130*nTamC1 MSGET oNAvalI3 VAR aSHST[135]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[1]
@ 110*nTamL ,170*nTamC1 COMBOBOX aSHST[136] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[1]
@ 070*nTamL ,230*nTamC1 SAY   OemToAnsi(STR0147) 	    		SIZE 100*nTamBox,7 						PIXEL OF oVIIP2:aDialogs[1]//"Eliminação do efeito estroboscópio"
@ 070*nTamL ,280*nTamC1 MSGET oNAvalI4 VAR aSHST[137]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[1]
@ 070*nTamL ,320*nTamC1 COMBOBOX aSHST[138] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[1]
@ 090*nTamL ,230*nTamC1 SAY   OemToAnsi(STR0148) 	    		SIZE 100*nTamBox,7 						PIXEL OF oVIIP2:aDialogs[1]//"Outras (especifique)"
@ 090*nTamL ,280*nTamC1 MSGET oNAvalI5 VAR aSHST[139]			SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[1]
@ 090*nTamL ,320*nTamC1 COMBOBOX aSHST[140] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[1]
@ 110*nTamL ,230*nTamC1 MSGET oDAvalI5 VAR aSHST[141]			SIZE 140*nTamBox,8	Picture "@!X100" 	PIXEL OF oVIIP2:aDialogs[1]

@ 140*nTamL,010*nTamC1 SAY   OemToAnsi(STR0151) 	    		SIZE 150*nTamBox,7 				PIXEL OF oVIIP2:aDialogs[1]//"Normas de Referência utilizadas na Avaliação"
@ 150*nTamL,010*nTamC1 GET oNRIlu Var aSHST[142] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[142]))>200,(MsgAlert(STR0151+STR0137+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[142])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[1]	
oNrIlu:lWordWrap:= .T.
//oNRIlu:EnableHScroll( .T. )
oNrIlu:EnableVScroll( .T. )


@ 190*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0152) 	    	SIZE 150*nTamBox,7 									PIXEL OF oVIIP2:aDialogs[1]//"Técnicas de Avaliação utilizadas"
@ 200*nTamL ,010*nTamC1 GET oTecAvIlu Var aSHST[143] MEMO 	Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[143]))>200,(MsgAlert(STR0152+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[143])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[1]	
oTecAvIlu:lWordWrap:= .T.
//oTecAvIlu:EnableHScroll( .T. )
oTecAvIlu:EnableVScroll( .T. )


@ 240*nTamL , 010*nTamC1 SAY   OemToAnsi(STR0153) 	    	SIZE 150*nTamBox,7 									PIXEL OF oVIIP2:aDialogs[1]//"Postos de Trabalho com modificações"
@ 250*nTamL , 010*nTamC1 GET oPostIlu Var aSHST[144] MEMO 	Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[144]))>200,(MsgAlert(STR0153+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[144])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[1]	
oPostIlu:lWordWrap:= .T.
//oObjPro1:EnableHScroll( .T. )
oPostIlu:EnableVScroll( .T. )
//===================================================================================================================================
//Ambiente Termico
//===================================================================================================================================
@ 002*nTamL ,005*nTamC1 TO  300*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL ""				PIXEL OF oVIIP2:aDialogs[2]
@ 012*nTamL ,010*nTamC1 TO  137*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0149 		PIXEL OF oVIIP2:aDialogs[2]//"Medidas Adotadas"
@ 017*nTamL ,206*nTamC1	SAY   OemToAnsi(STR0142) 	    	SIZE 080*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Nº de Avaliações"
@ 017*nTamL ,266*nTamC1	SAY   OemToAnsi(STR0143) 	    	SIZE 100*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Resultado"

@ 027*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0156) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Substituição do equipamento de trabalho"
@ 027*nTamL ,206*nTamC1	MSGET oNAvalT1 VAR aSHST[145]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 027*nTamL ,256*nTamC1	COMBOBOX aSHST[146] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 042*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0157) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Modificações na organização do trabalho (pausas, etc.)"
@ 042*nTamL ,206*nTamC1	MSGET oNAvalT2 VAR aSHST[147]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 042*nTamL ,256*nTamC1	COMBOBOX aSHST[148] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 057*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0158)	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Substituição ou alteração das instalações"
@ 057*nTamL ,206*nTamC1	MSGET oNAvalT3 VAR aSHST[149]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 057*nTamL ,256*nTamC1	COMBOBOX aSHST[150] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 072*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0159) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Alteração dos sistemas de climatização"
@ 072*nTamL ,206*nTamC1	MSGET oNAvalT4 VAR aSHST[151]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 072*nTamL ,256*nTamC1	COMBOBOX aSHST[152] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 087*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0160) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Introdução de dispositivos de proteção contra as fontes de calor ou frio"
@ 087*nTamL ,206*nTamC1	MSGET oNAvalT5 VAR aSHST[153]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 087*nTamL ,256*nTamC1	COMBOBOX aSHST[154] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 102*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0161) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Adequação do equipamento de proteção individual"
@ 102*nTamL ,206*nTamC1	MSGET oNAvalT6 VAR aSHST[155]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 102*nTamL ,256*nTamC1	COMBOBOX aSHST[156] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 117*nTamL ,026*nTamC1	SAY   OemToAnsi(STR0148) 	    	SIZE 200*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Outras (especifique)"
@ 117*nTamL ,206*nTamC1	MSGET oNAvalT7 VAR aSHST[158]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP2:aDialogs[2]
@ 117*nTamL ,256*nTamC1	COMBOBOX aSHST[159] Items aSituacao	SIZE 050*nTamBox,8   					PIXEL OF oVIIP2:aDialogs[2]
@ 117*nTamL ,306*nTamC1	MSGET oDAvalT7 VAR aSHST[157]		SIZE 100*nTamBox,8	Picture "@!X100" 	PIXEL OF oVIIP2:aDialogs[2]

@ 140*nTamL ,010*nTamC1   SAY   OemToAnsi(STR0151) 	    SIZE 150*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Normas de Referência utilizadas na Avaliação"
@ 150*nTamL ,010*nTamC1   GET oNrAmT Var aSHST[160] MEMO 	Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[160]))>200,(MsgAlert(STR0151+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[160])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[2]		
oNrAmT:lWordWrap:= .T.
//oNrAmt:EnableHScroll( .T. )
oNrAmT:EnableVScroll( .T. )
             

@ 190*nTamL ,010*nTamC1   SAY   OemToAnsi(STR0152) 	   	SIZE 150*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Técnicas de Avaliação utilizadas"
@ 200*nTamL ,010*nTamC1   GET oTecAvAmT Var aSHST[161] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[161]))>200,(MsgAlert(STR0152+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[161])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[2]	
oTecAvAmt:lWordWrap:= .T.
//oTecAvAmt:EnableHScroll( .T. )
oTecAvAmt:EnableVScroll( .T. )


@ 240*nTamL ,010*nTamC1   SAY   OemToAnsi(STR0153) 	    	SIZE 150*nTamBox,7						PIXEL OF oVIIP2:aDialogs[2]//"Postos de Trabalho com modificações"
@ 250*nTamL ,010*nTamC1   GET oPostAmt Var aSHST[162] MEMO 	Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[162]))>200,(MsgAlert(STR0153+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[162])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[2]	
oPostAmt:lWordWrap:= .T.
//oPostAmt:EnableHScroll( .T. )
oPostAmt:EnableVScroll( .T. )

//===================================================================================================================================
//Agentes Fisicos                                                                                                                    
//===================================================================================================================================
@ 002*nTamL ,005*nTamC1  TO  300*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL ""		PIXEL OF oVIIP2:aDialogs[3]
@ 007*nTamL ,010*nTamC1  TO  140*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL "" 		PIXEL OF oVIIP2:aDialogs[3]

Aadd(aHAgFis,{STR0164					,"cCodAge","@!"     ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0169+";"+STR0170+";"+STR0171+";"+STR0172+";"+STR0173+";"+STR0174+";"+STR0175,/*relacao*/})//"Código do agente"
//"01-Ruído"#"02-Vibrações"#"03-Radiações ionizantes"#"04-Raios ultravioletas"#"05-Raios laser"#"06-Riscos eléctricos"#"07-Outros agentes"
Aadd(aHAgFis,{STR0165+"("+STR0073+")"	,"nTrbExH","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Homem"
Aadd(aHAgFis,{STR0165+"("+STR0074+")"	,"nTrbExM","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Mulher"
Aadd(aHAgFis,{"1-"+STR0166					,"cCdMed1","@!"     ,2  ,0          ,/*valid*/  ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0176+";"+STR0177+";"+STR0178+";"+STR0179+";"+STR0180+";"+STR0181})//"Códigos das medidas adotadas"
Aadd(aHAgFis,{"2-"+STR0166					,"cCdMed2","@!"       ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0176+";"+STR0177+";"+STR0178+";"+STR0179+";"+STR0180+";"+STR0181})//"Códigos das medidas adotadas"
Aadd(aHAgFis,{"3-"+STR0166					,"cCdMed3","@!"       ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0176+";"+STR0177+";"+STR0178+";"+STR0179+";"+STR0180+";"+STR0181})//"Códigos das medidas adotadas"
//"01-Eliminação/Redução do risco na fonte"#"02-Modificação das instalações"#"03-Substituição do equipamento de trabalho"
//"04-Organização do trabalho"#"05-Protecção coletiva"#"06-Protecção individual"#"07-Outras medidas"
Aadd(aHAgFis,{STR0167					,"cNAvaEf","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de avaliações efetuadas"
Aadd(aHAgFis,{STR0168					,"cResAva","@! XX"     ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,"01="+STR0154+";02="+STR0155,/*relacao*/})//"Resultado da ultima avaliação do ano"#"Adequada"#"Inadequada"

If Len(aCAgFis)==0
	aAux := {}
	Aadd(aAux,"  ")
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,"  ")
	Aadd(aAux,"  ")
	Aadd(aAux,"  ")
	Aadd(aAux,0)
	Aadd(aAux,"  ")
	Aadd(aAux,.F.)
	Aadd(aCAgFis,aAux)
Endif   
oGetAFis:= MsNewGetDados():New(014*nTamL,026*nTamC1,130*nTamL,(aGdCoord[4]-140)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVIIP2:aDialogs[3],aHAgFis,aCAgFis)

@ 150*nTamL ,010*nTamC1   TO  200*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0183 							PIXEL OF oVIIP2:aDialogs[3]//"Outros agentes identificados"
@ 160*nTamL ,026*nTamC1   GET oOutAFis Var aSHST[163] MEMO Size 340*nTamC1,030*nTamL;
Valid Iif(Len(alltrim(aSHST[163]))>200,(MsgAlert(STR0183+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(Alltrim(aSHST[163])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[3]
oOutAFis:lWordWrap:= .T.
//oOutMFis:EnableHScroll( .T. )
oOutAFis:EnableVScroll( .T. )


@ 210*nTamL ,010*nTamC1 TO  280*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0184 							PIXEL OF oVIIP2:aDialogs[3]//"Outras Medidas Adotadas"
@ 220*nTamL ,026*nTamC1 GET oOutMFis Var aSHST[164] MEMO Size 340*nTamC1,030*nTamL;
Valid Iif(Len(alltrim(aSHST[164]))>200,(MsgAlert(STR0184+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(Alltrim(aSHST[164])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[3]
oOutMFis:lWordWrap:= .T.
//oOutMFis:EnableHScroll( .T. )
oOutMFis:EnableVScroll( .T. )
//===================================================================================================================================
//Agentes Quimico                                                                                                                    
//===================================================================================================================================
@ 002*nTamL ,005*nTamC1 TO  280*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL ""		PIXEL OF oVIIP2:aDialogs[4]
@ 007*nTamL ,010*nTamC1 TO  060*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL "" 		PIXEL OF oVIIP2:aDialogs[4]

Aadd(aHAgQui,{STR0164					,"nIDAgeQ","@E 9999"   	,4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Codigo do agente"
Aadd(aHAgQui,{STR0188					,"cEINECQ","@!X10"     	,10 ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Código EINECS(n.° CE)"
Aadd(aHAgQui,{STR0189					,"cFRiscQ","@!XXX"     	,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Menção ou frase de risco"
Aadd(aHAgQui,{STR0165+"("+STR0073+")"	,"nTrbEQH","@E 9999"	,4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Homem"
Aadd(aHAgQui,{STR0165+"("+STR0074+")"	,"nTrbEQM","@E 9999"	,4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Mulher"
Aadd(aHAgQui,{STR0166					,"cCdMdQ1","@! XX"     	,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0190+";"+STR0191+";"+STR0192+";"+STR0193+";"+STR0194+";"+STR0195+";"+STR0196+";"+STR0197+";"+STR0198,/*relacao*/})//"Códigos das medidas adotadas"
//"01-Modificação das instalações"#"02-Armazenagem adequada"#"03-Rotulagem e embalagem adequada"
//"04-Substituição do equipamento de trabalho"#"05-Substituição de material"#"06-Organização de trabalhol"
//"07-Proteção coletiva#08-Proteção Individual#Outras"
Aadd(aHAgQui,{STR0167					,"nNAvaEQ","@E 999" 	,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de avaliações efetuadas"
Aadd(aHAgQui,{STR0168					,"cResAvQ","@! XX"     	,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,"01="+STR0154+";02="+STR0155,/*relacao*/})//"Resultado da ultima avaliação do ano"#"Adequada"#"Inadequada"

If Len(aCAgQui)==0
	aAux := {}
	Aadd(aAux,0)
	Aadd(aAux,Space(10))
	Aadd(aAux,Space(3))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,"00")
	Aadd(aAux,0)
	Aadd(aAux,"00")
	Aadd(aAux,.F.)
	Aadd(aCAgQui,aAux)
Endif
oGetAQui:= MsNewGetDados():New(010*nTamL,015*nTamC1,050*nTamL,(aGdCoord[4]-140)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVIIP2:aDialogs[4],aHAgQui,aCAgQui)

@ 070*nTamL  ,010*nTamC1   TO  110*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0186 							PIXEL OF oVIIP2:aDialogs[4]//"Outros agentes Quimicos"
@ 080*nTamL  ,015*nTamC1   GET oOutAQui Var aSHST[165] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[165]))>200,(MsgAlert(STR0186+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[165])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[4] 	
oOutAQui:lWordWrap:= .T.
oOutAQui:EnableVScroll( .T. )


@ 120*nTamL  ,010*nTamC1  TO  160*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0184 							PIXEL OF oVIIP2:aDialogs[4]//"Outras Medidas Adotadas"
@ 130*nTamL  ,015*nTamC1  GET oOutMQui Var aSHST[166] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[166]))>200,(MsgAlert(STR0184+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[166])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[4]
oOutMQui:lWordWrap:= .T.
oOutMQui:EnableVScroll( .T. )

@ 170*nTamL  ,010*nTamC1  TO  210*nTamL,(aGdCoord[4]-140)*nTamLC2 LABEL STR0199 								PIXEL OF oVIIP2:aDialogs[4]//"Normas de referência (Ag. Químicos)"
@ 180*nTamL  ,015*nTamC1  GET oNrQui Var aSHST[167] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[167]))>200,(MsgAlert(STR0199+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[167])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[4]
oNrQui:lWordWrap:= .T.
oNrQui:EnableVScroll( .T. )

@ 220*nTamL  ,010*nTamC1  TO  270*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0200 	   							PIXEL OF oVIIP2:aDialogs[4]//"Técnicas de avaliação (Ag. Químicos)"
@ 230*nTamL  ,015*nTamC1  GET oTecAvQui Var aSHST[168] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[168]))>200,(MsgAlert(STR0200+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[168])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[4]
oTecAvQui:lWordWrap:= .T.
oTecAvQui:EnableVScroll( .T. )

//===================================================================================================================================
//Agentes Biologicos                                                                                                                 
//===================================================================================================================================
@ 002*nTamL ,005*nTamC1  TO  280*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL ""		PIXEL OF oVIIP2:aDialogs[5]
@ 007*nTamL ,010*nTamC1  TO  100*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL "" 		PIXEL OF oVIIP2:aDialogs[5]
Aadd(aHAgBio,{STR0187					,"nIDAgeQ","@!X100" ,100,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Identificação do agente"
Aadd(aHAgBio,{STR0213					,"nIDAgeQ","@E 9"   ,1  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Classificação do agente"
Aadd(aHAgBio,{STR0165+"("+STR0073+")"	,"nTrbExH","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Homem"
Aadd(aHAgBio,{STR0165+"("+STR0074+")"	,"nTrbExM","@E 9999",4  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Número de trabalhadores expostos"#"Mulher"
Aadd(aHAgBio,{STR0166					,"cCdMed3","@!"     ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,;
STR0204+";"+STR0205+";"+STR0206+";"+STR0207+";"+STR0208+";"+STR0209+";"+STR0210+";"+STR0211+";"+STR0212,/*relacao*/})//"Códigos das medidas adotadas"
//"01-Substituição de agentes biológicos perigosos"#"02-Substituição ou modificação do processo de trabalho"#"03-Substituição do equipamento de trabalho"
//"04-04=Med. téc. controle para evitar ou minimizar a disseminação dos ag. biol. no local de trab."#"05-Limitação do número de trabalhadores expostos"
//"06-Proteção coletiva#07-Protecção individual"#"08-Recolha, armazenagem e evacuação de resíduos, após tratamento adequado"#09-Outras medidas
Aadd(aHAgBio,{STR0167					,"cNAvaEf","@E 999" ,3  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de avaliações efetuadas"
Aadd(aHAgBio,{STR0168					,"cResAva","@!"     ,2  ,0          ,/*valid*/    ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,"01="+STR0154+";02="+STR0155,/*relacao*/})//"Resultado da ultima avaliação do ano"#"Adequada"#"Inadequada"

If Len(aCAgBio)==0
	aAux := {}
	Aadd(aAux,Space(100))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,"00")
	Aadd(aAux,0)
	Aadd(aAux,"00")
	Aadd(aAux,.F.)
	Aadd(aCAgBio,aAux)
Endif
oGetABio:= MsNewGetDados():New(010*nTamL,015*nTamC1,060*nTamL,(aGdCoord[4]-140)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVIIP2:aDialogs[5],aHAgBio,aCAgBio)


@ 110*nTamL ,010*nTamC1   TO  150*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0214 								PIXEL OF oVIIP2:aDialogs[5]//"Outras Agentes identificados (Ag.biológicos)"
@ 120*nTamL ,015*nTamC1   GET oOutABio Var aSHST[169] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[169]))>200,(MsgAlert(STR0214+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[169])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[5]
oOutABio:lWordWrap:= .T.
oOutABio:EnableVScroll( .T. )

@ 160*nTamL ,010*nTamC1   TO  200*nTamL,aGdCoord[4]-140*nTamLC2  LABEL STR0215				 								PIXEL OF oVIIP2:aDialogs[5]// "Outras medidas adotadas (Ag.biológicos)"
@ 170*nTamL ,015*nTamC1   GET oOutMBio Var aSHST[170] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[170]))>200,(MsgAlert(STR0215+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[170])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[5]
oOutMBio:lWordWrap:= .T.
oOutMBio:EnableVScroll( .T. )


@ 210*nTamL ,010*nTamC1   TO  260*nTamL,(aGdCoord[4]-140)*nTamLC2  LABEL STR0203 							PIXEL OF oVIIP2:aDialogs[5]//"Referências e  técnicas de avaliação (Dec.Lei 84/97)"
@ 220*nTamL ,015*nTamC1   GET oTecAvBio Var aSHST[171] MEMO Size 360*nTamC1,020*nTamL;
Valid Iif(Len(alltrim(aSHST[171]))>200,(MsgAlert(STR0203+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[171])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP2:aDialogs[5]
oTecAvBio:lWordWrap:= .T.
oTecAvBio:EnableVScroll( .T. )

oVIIP2:Hide()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIPart3	   ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VII-Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho ³±±
±±³			 ³ ParteIII - Interv.caract.locais de trab. e práticas de trabalho   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                         
Static Function VIIPart3(oTree,oDlgMain)//"Intervenção nas características dos locais de trabalho e práticas de trabalho"
Local oIntDes12
Local oComb01,oComb02,oComb03,oComb04,oComb05,oComb06,oComb07,oComb08,oComb09,oComb10,oComb11,oComb12
aSHST[172]:=Iif(Alltrim(aSHST[172])=="0",aOK[1],aOK[2])
aSHST[173]:=Iif(Alltrim(aSHST[173])=="0",aOK[1],aOK[2])
aSHST[174]:=Iif(Alltrim(aSHST[174])=="0",aOK[1],aOK[2])
aSHST[175]:=Iif(Alltrim(aSHST[175])=="0",aOK[1],aOK[2])
aSHST[176]:=Iif(Alltrim(aSHST[176])=="0",aOK[1],aOK[2])
aSHST[177]:=Iif(Alltrim(aSHST[177])=="0",aOK[1],aOK[2])
aSHST[178]:=Iif(Alltrim(aSHST[178])=="0",aOK[1],aOK[2])
aSHST[179]:=Iif(Alltrim(aSHST[179])=="0",aOK[1],aOK[2])
aSHST[180]:=Iif(Alltrim(aSHST[180])=="0",aOK[1],aOK[2])
aSHST[181]:=Iif(Alltrim(aSHST[181])=="0",aOK[1],aOK[2])
aSHST[182]:=Iif(Alltrim(aSHST[182])=="0",aOK[1],aOK[2])
aSHST[184]:=Iif(Alltrim(aSHST[184])=="0",aOK[1],aOK[2])


oVIIP3:= TFolder():New(012*nTamL,086*nTamC1,{STR0096},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])
@ 002*nTamL ,005*nTamC1 TO 280*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL "" 		  		PIXEL OF oVIIP3:aDialogs[1]
@ 015*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0216) 						SIZE 300*nTamBox,7	  		PIXEL OF oVIIP3:aDialogs[1]//"01. Mecanismos para paragem de emergência"
@ 015*nTamL ,346*nTamC1 COMBOBOX oComb01 Var aSHST[172]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 030*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0217) 						SIZE 300*nTamBox,7	  		PIXEL OF oVIIP3:aDialogs[1]//"02. Sistemas de extração de poeiras, gases, vapores, fumos e névoas"
@ 030*nTamL ,346*nTamC1 COMBOBOX oComb02 Var aSHST[173]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 045*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0218) 						SIZE 300*nTamBox,7   		PIXEL OF oVIIP3:aDialogs[1]//"03. Dispositivos de proteção dos elementos móveis em rotação ou translação"
@ 045*nTamL ,346*nTamC1 COMBOBOX oComb03 Var aSHST[174]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 060*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0219) 	    				SIZE 300*nTamBox,7   		PIXEL OF oVIIP3:aDialogs[1]//"04. Dispositivos que permitam isolar as máquinas e outro equipamento de trabalho de cada uma das suas fontes de energia"
@ 060*nTamL ,346*nTamC1 COMBOBOX oComb04 Var aSHST[175]	Items aOk 		SIZE 050*nTamBox,8 			PIXEL OF oVIIP3:aDialogs[1]
@ 075*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0220) 	    				SIZE 300*nTamBox,7	  		PIXEL OF oVIIP3:aDialogs[1]//"05. Dispositivos que permitam que os trabalhos de manutenção se façam com o equipamento parado"
@ 075*nTamL ,346*nTamC1 COMBOBOX oComb05 Var aSHST[176]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 090*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0221) 	    				SIZE 300*nTamBox,7	  		PIXEL OF oVIIP3:aDialogs[1]//"06. Protecções contra contactos diretos ou indirectos com a electricidade"
@ 090*nTamL ,346*nTamC1 COMBOBOX oComb06 Var aSHST[177]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 105*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0222) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"07. Aplicação de estruturas de proteção contra o risco de capotamento, em máquinas móveis"
@ 105*nTamL ,346*nTamC1 COMBOBOX oComb07 Var aSHST[178]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 120*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0223) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"08. Aplicação de estruturas de proteção contra o risco de queda de materiais"
@ 120*nTamL ,346*nTamC1 COMBOBOX oComb08 Var aSHST[179]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 135*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0224) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"09. Dispositivos de proteção que impeçam que cargas se soltem ou caiam"
@ 135*nTamL ,346*nTamC1 COMBOBOX oComb09 Var aSHST[180]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 150*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0225) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"10. Dispositivos de prevenção dos riscos associados a trabalhos com equipamentos dotados de visor"
@ 150*nTamL ,346*nTamC1 COMBOBOX oComb10 Var aSHST[181]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 165*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0226) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"11. Beneficiações ergonómicas nos equipamentos de trabalhos utilizados"
@ 165*nTamL ,346*nTamC1 COMBOBOX oComb11 Var aSHST[182]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 180*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0227) 	    				SIZE 300*nTamBox,7			PIXEL OF oVIIP3:aDialogs[1]//"12. Outras (especifique)"
@ 180*nTamL ,346*nTamC1 COMBOBOX oComb12 Var aSHST[184]	Items aOk 		SIZE 050*nTamBox,8			PIXEL OF oVIIP3:aDialogs[1]
@ 195*nTamL ,010*nTamC1 MSGET  oIntDes12 VAR aSHST[183]					SIZE 300*nTamBox,8	Picture "@!X100" 	PIXEL OF oVIIP3:aDialogs[1]
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIPart4	   ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VII-Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho ³±±
±±³			 ³ Parte IV - Interv.Caract. dos locais de trab. e prát. de trabalho ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function VIIPart4(oTree,oDlgMain)
Local oDPrvRMH, oDPrvRMM,oDPrvRPH, oDPrvRPM,oDPrvREH, oDPrvREM,oOutDH  ,oOutDM  ,oOutEsp
Local oIPDes11
oVIIP4	:= TFolder():New(012*nTamL,086*nTamC1,{STR0239,STR0240,STR0251},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])//"Intervenção nas características dos locais de trabalho"#Intervenção nas práticas de trabalho#dispositivos

@ 002*nTamL ,005*nTamC1 TO 260*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL "" 		  	PIXEL OF oVIIP4:aDialogs[1]//Medidas Adotadas
@ 005*nTamL ,306*nTamC1 SAY OemToAnsi(STR0073)				SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"Homem"
@ 005*nTamL ,356*nTamC1 SAY OemToAnsi(STR0074)				SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"Mulher"

@ 015*nTamL ,010*nTamC1 SAY OemToAnsi(STR0228)	 			SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP4:aDialogs[1]//"01. Sistemas de prevenção do risco de incêndio"
@ 015*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[185]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 015*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[186]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]

@ 030*nTamL ,010*nTamC1 SAY OemToAnsi(STR0229) 				SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"02. Sistemas de prevenção do risco de explosão"
@ 030*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[187]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 030*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[188]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 045*nTamL ,010*nTamC1 SAY OemToAnsi(STR0230) 				SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"03. Dispositivos que evitem a queda de pessoas"
@ 045*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[189]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 045*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[190]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 060*nTamL ,010*nTamC1 SAY OemToAnsi(STR0231) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"04. Dispositivos que evitem riscos associados a trabalhos de escavações"
@ 060*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[191]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 060*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[192]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 075*nTamL ,010*nTamC1 SAY OemToAnsi(STR0232) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"05. Dispositivos que evitem riscos associados a trabalhos subterrâneos"
@ 075*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[193]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 075*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[194]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 090*nTamL ,010*nTamC1 SAY OemToAnsi(STR0233) 	    		SIZE 300*nTamBox,7 					  	PIXEL OF oVIIP4:aDialogs[1]//"06. Dispositivos que evitem riscos associados a superfícies perigosas, designadamente as derrapantes"
@ 090*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[195]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 090*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[196]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 105*nTamL ,010*nTamC1 SAY OemToAnsi(STR0234) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"07. Adoção de medidas de prevenção nos trabalhos em espaços confinados ou de reduzidas dimensões"
@ 105*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[197]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 105*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[198]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 120*nTamL ,010*nTamC1 SAY OemToAnsi(STR0235) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"08. Dispositivos que evitem a queda de materiais ou objetos"
@ 120*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[199]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 120*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[200]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 135*nTamL ,010*nTamC1 SAY OemToAnsi(STR0236) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"09. Sistemas de extração de poeiras, gases, fumo e névoas"
@ 135*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[201]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 135*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[202]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 150*nTamL ,010*nTamC1 SAY OemToAnsi(STR0237) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"10. Alterações na sinalização de segurança no trabalho"
@ 150*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[203]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 150*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[204]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 165*nTamL ,010*nTamC1 SAY OemToAnsi(STR0238) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"11. Condições de armazenagem adequada de substâncias ou preparações perigosas"
@ 165*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[205]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 165*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[206]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 180*nTamL ,010*nTamC1 SAY OemToAnsi(STR0227) 	    		SIZE 300*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[1]//"12. Outras (especifique)"
@ 180*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[207]		SIZE 020*nTamBox,8	Picture "@E 9999" 	PIXEL OF oVIIP4:aDialogs[1]
@ 180*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[208]		SIZE 020*nTamBox,8	Picture "@E 9999"	PIXEL OF oVIIP4:aDialogs[1]
@ 195*nTamL ,010*nTamC1 MSGET oILDes12 VAR aSHST[209]		SIZE 200*nTamBox,8	Picture "@!X100" 	PIXEL OF oVIIP4:aDialogs[1]

@ 002*nTamL ,005*nTamC1 TO  280*nTamL,(aGdCoord[4]-130)*nTamLC2  LABEL "" 							PIXEL OF oVIIP4:aDialogs[2]
@ 005*nTamL ,306*nTamC1 SAY OemToAnsi(STR0073)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"Homem"
@ 005*nTamL ,356*nTamC1 SAY OemToAnsi(STR0074)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"Mulher"
@ 015*nTamL ,010*nTamC1 SAY OemToAnsi(STR0241) 			SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"01. Trabalho precário"
@ 015*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[210]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 015*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[211]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 030*nTamL ,010*nTamC1 SAY OemToAnsi(STR0242) 			SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"02. Trabalho em cadeia"
@ 030*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[212]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 030*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[213]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 045*nTamL ,010*nTamC1 SAY OemToAnsi(STR0243) 			SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"03. Trabalho monótono/repetitivo"
@ 045*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[214]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 045*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[215]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 060*nTamL ,010*nTamC1 SAY OemToAnsi(STR0244) 	    	SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"04. Ritmo de trabalho"
@ 060*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[216]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 060*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[217]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 075*nTamL ,010*nTamC1 SAY OemToAnsi(STR0245) 	    	SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"05. Trabalho suplementar"
@ 075*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[218]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 075*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[219]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 090*nTamL ,010*nTamC1 SAY OemToAnsi(STR0246) 	    	SIZE 300*nTamBox,7 					  		PIXEL OF oVIIP4:aDialogs[2]//"06. Trabalho por turnos"
@ 090*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[220]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 090*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[221]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 105*nTamL ,010*nTamC1 SAY OemToAnsi(STR0247) 	    	SIZE 300*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"07. Trabalho noturno"
@ 105*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[222]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 105*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[223]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 120*nTamL ,010*nTamC1 SAY OemToAnsi(STR0248) 	    	SIZE 300*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"08. Violência (física, assédio sexual, discriminação, etc.)"
@ 120*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[224]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 120*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[225]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 135*nTamL ,010*nTamC1 SAY OemToAnsi(STR0249) 	    	SIZE 300*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"09. Trabalho de menores"
@ 135*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[226]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 135*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[227]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 150*nTamL ,010*nTamC1 SAY OemToAnsi(STR0250) 	    	SIZE 300*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"10. Trabalho de grávidas, puérperas ou latantes"
@ 150*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[228]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 150*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[229]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 165*nTamL ,010*nTamC1 SAY "11. "+OemToAnsi(STR0148) 	SIZE 300*nTamBox,7 							PIXEL OF oVIIP4:aDialogs[2]//"11. Outras (especifique)"
@ 165*nTamL ,306*nTamC1 MSGET oDPrvRMH VAR aSHST[230]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[2]
@ 165*nTamL ,356*nTamC1 MSGET oDPrvRMM VAR aSHST[231]	SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[2]
@ 180*nTamL ,010*nTamC1 MSGET oIPDes11 VAR aSHST[232]	SIZE 300*nTamBox,8	Picture "@!X100" 		PIXEL OF oVIIP4:aDialogs[2]
//==========================================================================================================================================
//Dispositivos
//==========================================================================================================================================
@ 002*nTamL ,005*nTamC1	TO 040*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0252			PIXEL OF oVIIP4:aDialogs[3]//"Disp. Prev.Riscos Mov.Manual"
@ 010*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0073)			SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Homem"
@ 010*nTamL ,110*nTamC1 SAY   OemToAnsi(STR0074)			SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Mulher"
@ 020*nTamL ,010*nTamC1 MSGET oDPrvRMH VAR aSHST[233]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
@ 020*nTamL ,110*nTamC1 MSGET oDPrvRMM VAR aSHST[234]		SIZE 020*nTamBox,8	Picture "@E 9999"		PIXEL OF oVIIP4:aDialogs[3]

@ 050*nTamL ,005*nTamC1 TO 090*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0253 			PIXEL OF oVIIP4:aDialogs[3]//"Disp. Prev.Riscos Posturas"
@ 060*nTamL ,010*nTamC1 SAY   OemToAnsi(STR0073)			SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Homem"
@ 060*nTamL ,110*nTamC1 SAY   OemToAnsi(STR0074)			SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Mulher"
@ 070*nTamL ,010*nTamC1 MSGET oDPrvRPH VAR aSHST[235]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
@ 070*nTamL ,110*nTamC1 MSGET oDPrvRPM VAR aSHST[236]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]

@ 100*nTamL ,005*nTamC1 TO 140*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0254			PIXEL OF oVIIP4:aDialogs[3]//"Disp. Prev.Riscos Equip.c/Visor"
@ 110*nTamL ,010*nTamC1 SAY OemToAnsi(STR0073)				SIZE 100*nTamBox,7							PIXEL OF oVIIP4:aDialogs[3]//"Homem"
@ 110*nTamL ,110*nTamC1 SAY OemToAnsi(STR0074)				SIZE 100*nTamBox,7							PIXEL OF oVIIP4:aDialogs[3]//"Mulher"
@ 120*nTamL ,010*nTamC1 MSGET oDPrvRPH VAR aSHST[237]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
@ 120*nTamL ,110*nTamC1 MSGET oDPrvREM VAR aSHST[238]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
                                                                
@ 150*nTamL ,005*nTamC1 TO 280*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0255 			PIXEL OF oVIIP4:aDialogs[3]//"Outros Dispositivos"
@ 160*nTamL ,010*nTamC1 SAY OemToAnsi(STR0073)				SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Homem"
@ 160*nTamL ,110*nTamC1 SAY OemToAnsi(STR0074)				SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Mulher"
@ 170*nTamL ,010*nTamC1 MSGET oOutDH   VAR aSHST[239]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
@ 170*nTamL ,110*nTamC1 MSGET oOutDM   VAR aSHST[240]		SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP4:aDialogs[3]
@ 190*nTamL ,010*nTamC1 SAY OemToAnsi(STR0148)				SIZE 100*nTamBox,7 						PIXEL OF oVIIP4:aDialogs[3]//"Outras (especifique)"
@ 200*nTamL ,010*nTamC1 MSGET oOutEsp  VAR aSHST[241]		SIZE 300*nTamBox,8	Picture "@!X100" 		PIXEL OF oVIIP4:aDialogs[3]
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIPart5	   ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VII-Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
                                               
Static Function VIIPart5(oTree,oDlgMain)
Local oRisFisH, oRisFisM,oRisQuiH, oRisQuiM,oRisBioH, oRisBioM,oRisAltH,oRisAltM,oRisSotH,oRisSotM,oRisMatH,oRisMatM,oRisEleH,oRisEleM
Local oRisETH,oRisETM,oRisOutH,oRisOutM,oRisOutE,oOutMRis,oRisExist
aSHST[294]:=Iif(Alltrim(aSHST[294])=="0",aOK[1],aOK[2])
aSHST[295]:=Iif(Alltrim(aSHST[295])=="0",aOK[1],aOK[2])
aSHST[296]:=Iif(Alltrim(aSHST[296])=="0",aOK[1],aOK[2])
aSHST[297]:=Iif(Alltrim(aSHST[297])=="0",aOK[1],aOK[2])
aSHST[298]:=Iif(Alltrim(aSHST[298])=="0",aOK[1],aOK[2])
aSHST[299]:=Iif(Alltrim(aSHST[299])=="0",aOK[1],aOK[2])
aSHST[300]:=Iif(Alltrim(aSHST[300])=="0",aOK[1],aOK[2])

oVIIP5	:= TFolder():New(012*nTamL,086*nTamC1,{STR0256,STR0257+"-"+STR0258,STR0257+"-"+STR0293+"/"+STR0149},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])//"Medidas de proteção coletiva"#Medidas de proteção individual - "Tipos de EPI utilizados"#
@ 002*nTamL ,005*nTamC1 TO  280*nTaml ,(aGdCoord[4]-130)*nTamLC2   LABEL "" 	  		PIXEL OF oVIIP5:aDialogs[1]
@ 005*nTamL ,010*nTamC1 TO  190*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL STR0290		PIXEL OF oVIIP5:aDialogs[1]//"Risco profissional em causa"
@ 020*nTamL ,256*nTamC1 SAY OemToAnsi(STR0281)			SIZE 100*nTamBox,7							PIXEL OF oVIIP5:aDialogs[1]//"N.° de trabalhadores"
@ 030*nTamL ,256*nTamC1 SAY OemToAnsi(STR0073)			SIZE 100*nTamBox,7							PIXEL OF oVIIP5:aDialogs[1]//"Homem"
@ 030*nTamL ,306*nTamC1 SAY OemToAnsi(STR0074)			SIZE 100*nTamBox,7							PIXEL OF oVIIP5:aDialogs[1]//"Mulher"
@ 040*nTamL ,026*nTamC1 SAY OemToAnsi(STR0282)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//01.Risco físico
@ 040*nTamL ,256*nTamC1 MSGET oRisFisH VAR aSHST[242]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 040*nTamL ,306*nTamC1 MSGET oRisFisM VAR aSHST[243]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 055*nTamL ,026*nTamC1 SAY OemToAnsi(STR0283)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//02. Risco químico
@ 055*nTamL ,256*nTamC1 MSGET oRisQuiH VAR aSHST[244]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 055*nTamL ,306*nTamC1 MSGET oRisQuiM VAR aSHST[245]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 070*nTamL ,026*nTamC1 SAY OemToAnsi(STR0284)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//03. Risco biológico
@ 070*nTamL ,256*nTamC1 MSGET oRisBioH VAR aSHST[246]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 070*nTamL ,306*nTamC1 MSGET oRisBioM VAR aSHST[247]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 085*nTamL ,026*nTamC1 SAY OemToAnsi(STR0285)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//04. Risco de queda em altura
@ 085*nTamL ,256*nTamC1 MSGET oRisAltH VAR aSHST[248]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 085*nTamL ,306*nTamC1 MSGET oRisAltM VAR aSHST[249]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 100*nTamL ,026*nTamC1 SAY OemToAnsi(STR0286)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//05. Risco de soterramento
@ 100*nTamL ,256*nTamC1 MSGET oRisSotH VAR aSHST[250]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 100*nTamL ,306*nTamC1 MSGET oRisSotM VAR aSHST[251]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 115*nTamL ,026*nTamC1 SAY OemToAnsi(STR0287)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//06. Risco de queda de materiais ou objectos
@ 115*nTamL ,256*nTamC1 MSGET oRisMatH VAR aSHST[252]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 115*nTamL ,306*nTamC1 MSGET oRisMatM VAR aSHST[253]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 130*nTamL ,026*nTamC1 SAY OemToAnsi(STR0288)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//07. Risco eléctrico
@ 130*nTamL ,256*nTamC1 MSGET oRisEleH VAR aSHST[254]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 130*nTamL ,306*nTamC1 MSGET oRisEleM VAR aSHST[255]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 145*nTamL ,026*nTamC1 SAY OemToAnsi(STR0289)			SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//08. Risco associado à utilização de equipamentos de trabalhos
@ 145*nTamL ,256*nTamC1 MSGET oRisETH  VAR aSHST[256]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 145*nTamL ,306*nTamC1 MSGET oRisETM  VAR aSHST[257]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 160*nTamL ,026*nTamC1 SAY OemToAnsi("09. "+STR0148)	SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[1]//09. outras(especifique)
@ 160*nTamL ,256*nTamC1 MSGET oRisOutH VAR aSHST[258]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 160*nTamL ,306*nTamC1 MSGET oRisOutM VAR aSHST[259]	SIZE 020*nTamBox,8	Picture "@E 9999" 		PIXEL OF oVIIP5:aDialogs[1]
@ 175*nTamL ,026*nTamC1 MSGET oRisOutE VAR aSHST[260]	SIZE 300*nTamBox,8	Picture "@!X100" 		PIXEL OF oVIIP5:aDialogs[1]

@ 200*nTamL ,010*nTamC1 TO  260*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL STR0184		PIXEL OF oVIIP5:aDialogs[1]////"Outras Medidas Adotadas"
@ 210*nTamL ,015*nTamC1 GET oOutMRis Var aSHST[261] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[261]))>200,(MsgAlert(STR0184+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[261])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP5:aDialogs[1]
oOutMRis:lWordWrap:= .T.
oOutMRis:EnableVScroll( .T. )


@ 002*nTamL,005*nTamC1 TO  300*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL ""			  	PIXEL OF oVIIP5:aDialogs[2]
@ 020*nTamL,256*nTamC1	SAY   OemToAnsi(STR0281)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"N.° de trabalhadores"
@ 030*nTamL,256*nTamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"Homem"
@ 030*nTamL,306*nTamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"Mulher"
@ 045*nTamL,026*nTamC1	SAY   OemToAnsi(STR0259)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"01. Proteção da cabeça"
@ 045*nTamL,256*nTamC1	MSGET oRisFisH VAR aSHST[262]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 045*nTamL,306*nTamC1	MSGET oRisFisM VAR aSHST[263]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 060*nTamL,026*nTamC1	SAY   OemToAnsi(STR0260)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"02. Proteção dos ouvidos"
@ 060*nTamL,256*nTamC1	MSGET oRisQuiH VAR aSHST[264]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 060*nTamL,306*nTamC1	MSGET oRisQuiM VAR aSHST[265]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 075*nTamL,026*nTamC1	SAY   OemToAnsi(STR0261)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"03. Proteção dos olhos e da face"
@ 075*nTamL,256*nTamC1	MSGET oRisBioH VAR aSHST[266]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 075*nTamL,306*nTamC1	MSGET oRisBioM VAR aSHST[267]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 090*nTamL,026*nTamC1	SAY   OemToAnsi(STR0262)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"04. Proteção das vias respiratórias"
@ 090*nTamL,256*nTamC1	MSGET oRisAltH VAR aSHST[268]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 090*nTamL,306*nTamC1	MSGET oRisAltM VAR aSHST[269]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 105*nTamL,026*nTamC1	SAY   OemToAnsi(STR0263)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"05. Proteção das mãos e dos braços"
@ 105*nTamL,256*nTamC1	MSGET oRisSotH VAR aSHST[270]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 105*nTamL,306*nTamC1	MSGET oRisSotM VAR aSHST[271]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 120*nTamL,026*nTamC1	SAY   OemToAnsi(STR0264)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"06. Proteção dos pés e das pernas"
@ 120*nTamL,256*nTamC1	MSGET oRisMatH VAR aSHST[272]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 120*nTamL,306*nTamC1	MSGET oRisMatM VAR aSHST[273]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 135*nTamL,026*nTamC1	SAY   OemToAnsi(STR0265)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"07. Proteção da pele"
@ 135*nTamL,256*nTamC1	MSGET oRisEleH VAR aSHST[274]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 135*nTamL,306*nTamC1	MSGET oRisEleM VAR aSHST[275]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 150*nTamL,026*nTamC1	SAY   OemToAnsi(STR0266)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"08. Proteção do tronco e do abdómen"
@ 150*nTamL,256*nTamC1	MSGET oRisETH  VAR aSHST[276]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 150*nTamL,306*nTamC1	MSGET oRisETM  VAR aSHST[277]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 165*nTamL,026*nTamC1	SAY   OemToAnsi(STR0267)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"09. Proteção de todo o corpo"
@ 165*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[278]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 165*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[279]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 180*nTamL,026*nTamC1	SAY   OemToAnsi(STR0268)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"10. Proteção contra o frio"
@ 180*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[280]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 180*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[281] 	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 195*nTamL,026*nTamC1	SAY   OemToAnsi(STR0269)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"11. Proteção contra intempéries"
@ 195*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[282]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 195*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[283]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 210*nTamL,026*nTamC1	SAY   OemToAnsi(STR0270)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"12. Proteção contra quedas em altura"
@ 210*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[284]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 210*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[285]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 225*nTamL,026*nTamC1	SAY   OemToAnsi(STR0271)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"13. Proteção em trabalhos subaquáticos"
@ 225*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[286]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 225*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[287]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 240*nTamL,026*nTamC1	SAY   OemToAnsi(STR0272)		SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//"14. Proteção em situações de trabalho hiperbárico"
@ 240*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[288]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 240*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[289]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 255*nTamL,026*nTamC1	SAY   OemToAnsi("15. "+STR0148)	SIZE 100*nTamBox,7 							PIXEL OF oVIIP5:aDialogs[2]//15. Outras(especifique)
@ 255*nTamL,256*nTamC1	MSGET oRisOutH VAR aSHST[290]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 255*nTamL,306*nTamC1	MSGET oRisOutM VAR aSHST[291]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIP5:aDialogs[2]
@ 270*nTamL,026*nTamC1	MSGET oRisOutE VAR aSHST[292]	SIZE 300*nTamBox,8	Picture "@!X100" 			PIXEL OF oVIIP5:aDialogs[2]

@ 002*nTamL,005*nTamC1  TO  070*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0273	  	PIXEL OF oVIIP5:aDialogs[3]//"Riscos existentes no posto de trabalho que exigem a utilização de EPI, especifique:"
@ 012*nTamL,026*nTamC1  GET oRisExist Var aSHST[293] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[293]))>200,(MsgAlert(STR0273+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[293])))),STR0292),.F.),.T.) 	PIXEL OF oVIIP5:aDialogs[3]
oRisExist:lWordWrap:= .T.
oRisExist:EnableVScroll( .T. )


@ 080*nTamL ,005*nTamC1  TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0274 		  	PIXEL OF oVIIP5:aDialogs[3]//"Medidas adotadas em matéria de proteção individual"
@ 090*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0275) 			SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"01. Evitar ou reduzir a necessidade de utilização de EPI por adoção de medidas de organização do trabalho"
@ 090*nTamL ,346*nTamC1 COMBOBOX aSHST[294]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 105*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0276) 			SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"02. Evitar ou reduzir a necessidade de utilização de EPI por adoção de medidas de proteção coletiva"
@ 105*nTamL ,346*nTamC1 COMBOBOX aSHST[295]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 120*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0277) 			SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"03. Aquisição de novos EPI"
@ 120*nTamL ,346*nTamC1 COMBOBOX aSHST[296]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 135*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0278) 	    	SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"04. Consulta dos trabalhadores sobre a utilização de EPI"
@ 135*nTamL ,346*nTamC1 COMBOBOX aSHST[297]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 150*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0279) 	    	SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"05. Verificação da conservação de EPI"
@ 150*nTamL ,346*nTamC1 COMBOBOX aSHST[298]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 165*nTamL ,010*nTamC1 SAY	  OemToAnsi(STR0280) 	    	SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"06. Formação e informação dos trabalhadores sobre a utilização de EPI"
@ 165*nTamL ,346*nTamC1 COMBOBOX aSHST[299]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 180*nTamL ,010*nTamC1 SAY	  OemToAnsi("07. "+STR0148)    	SIZE 300*nTamBox,7 				  		PIXEL OF oVIIP5:aDialogs[3]//"07. Outras(Especifique)"
@ 180*nTamL ,346*nTamC1 COMBOBOX aSHST[300]	Items aOk 		SIZE 050*nTamBox,8							PIXEL OF oVIIP5:aDialogs[3]
@ 195*nTamL ,010*nTamC1 MSGET oRisOutE VAR aSHST[301]		SIZE 300*nTamBox,8	Picture "@!X100" 		PIXEL OF oVIIP5:aDialogs[3]

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIIPart1     ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VIII-Atividade desenvolvida no Âmbito da Saude no Trabalho		 ³±±
±±³			 ³ Parte I - Desenvolvidas											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VIIIPart1(oTree,oDlgMain)
Local ExAdm1H,ExAdm1M,ExAdn2H,ExAdm2M,ExAdm3H,ExAdm3M
Local ExPer1H,ExPer1M,ExPer2H,ExPer2M,ExPer3H,ExPer3M
Local oEx1Oc1H,oEx1Oc1M,oEx1Oc2H,oEx1Oc2M,oEx1Oc3H,oEx1Oc3M
Local oEx2Oc1H,oEx2Oc1M,oEx2Oc2H,oEx2Oc2M,oEx2Oc3H,oEx2Oc3M
Local oEx3Oc1H,oEx3Oc1M,oEx3Oc2H,oEx3Oc2M,oEx3Oc3H,oEx3Oc3M
Local oEx4Oc1H,oEx4Oc1M,oEx4Oc2H,oEx4Oc2M,oEx4Oc3H,oEx4Oc3M
Local oEx5Oc1H,oEx5Oc1M,oEx5Oc2H,oEx5Oc2M,oEx5Oc3H,oEx5Oc3M
Local oEx6Oc1H,oEx6Oc1M,oEx6Oc2H,oEx6Oc2M,oEx6Oc3H,oEx6Oc3M
Local oEx7Oc1H,oEx7Oc1M,oEx7Oc2H,oEx7Oc2M,oEx7Oc3H,oEx7Oc3M
Local oEx8Oc1H,oEx8Oc1M,oEx8Oc2H,oEx8Oc2M,oEx8Oc3H,oEx8Oc3M
Local oEx9Oc1H,oEx9Oc1M,oEx9Oc2H,oEx9Oc2M,oEx9Oc3H,oEx9Oc3M
Local oExaSan1,oExaSan2,oExaUri1,oExaUri2,oExaRxt1,oExaRxt2,oExaAud1,oExaAud2,oExaOut1,oExaOut2
Local oDesVac

oVIIIP1	:= TFolder():New(012*ntamL,086*nTamC1,{STR0294,STR0328+"-"+STR0297,STR0301+"/"+STR0311},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 002*nTamL ,005*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//

@ 015*nTamL ,186*nTamC1 TO  030*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//
@ 015*nTamL ,010*nTamC1 TO  040*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//
@ 030*nTamL ,186*nTamC1 TO  250*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//
@ 030*nTamL ,246*nTamC1 TO  250*nTamL ,Iif(nHRes <= 1024,(aGdCoord[4]-200),(aGdCoord[4]-320))*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//
@ 015*nTamL ,010*nTamC1 TO  250*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[1]//


@ 020*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0372)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//""Exames"
@ 020*nTamL ,266*nTamC1 SAY   OemToAnsi(STR0327)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"Escalões etários"

@ 030*nTamL ,206*nTamC1 SAY   OemToAnsi(STR0298)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"< 18 anos"
@ 030*nTamL ,266*nTamC1 SAY   OemToAnsi(STR0299)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"Entre 18 e 49 anos"
@ 030*nTamL ,346*nTamC1	SAY   OemToAnsi(STR0300)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//">49 anos"

@ 050*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0295)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"Exames Admissão"
@ 060*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"Homem"
@ 060*nTamL ,206*nTamC1	MSGET oExAdm1H VAR aSHST[302]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 060*nTamL ,276*nTamC1	MSGET oExAdm2H VAR aSHST[304]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 060*nTamL ,346*nTamC1	MSGET oExAdm3H VAR aSHST[306]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 070*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7								PIXEL OF oVIIIP1:aDialogs[1]//"Mulher"
@ 070*nTamL ,206*nTamC1	MSGET oExAdm1M VAR aSHST[303]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 070*nTamL ,276*nTamC1	MSGET oExAdm2M VAR aSHST[305]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 070*nTamL ,346*nTamC1	MSGET oExAdm3M VAR aSHST[307]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]

@ 090*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0296)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Exames Periódicos"
@ 100*nTamL ,160*nTamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Homem"
@ 100*nTamL ,206*nTamC1	MSGET oExPer1H VAR aSHST[308]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 100*nTamL ,276*nTamC1	MSGET oExPer2H VAR aSHST[310]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 100*nTamL ,346*nTamC1	MSGET oExPer3H VAR aSHST[312]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 110*nTamL ,160*nTamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Mulher"
@ 110*nTamL ,206*nTamC1	MSGET oExPer1M VAR aSHST[309]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 110*nTamL ,276*nTamC1	MSGET oExPer2M VAR aSHST[311]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 110*nTamL ,346*nTamC1	MSGET oExPer3M VAR aSHST[313]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]

@ 130*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0297)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Exames Ocasionais"
@ 140*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0318)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"01. Mudança de posto de trabalho"
@ 150*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Homem"
@ 150*nTamL ,206*nTamC1	MSGET oEx1Oc1H VAR aSHST[314]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 150*nTamL ,276*nTamC1	MSGET oEx1Oc2H VAR aSHST[316]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 150*nTamL ,346*nTamC1	MSGET oEx1Oc3H VAR aSHST[318]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 160*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Mulher"
@ 160*nTamL ,206*nTamC1	MSGET oEx1Oc1M VAR aSHST[315]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 160*nTamL ,276*nTamC1	MSGET oEx1Oc2M VAR aSHST[317]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 160*nTamL ,346*nTamC1	MSGET oEx1Oc3M VAR aSHST[319]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 170*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0319)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"02. Alterações no posto de trabalho"
@ 180*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Homem"
@ 180*nTamL ,206*nTamC1	MSGET oEx2Oc1H VAR aSHST[320]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 180*nTamL ,276*nTamC1	MSGET oEx2Oc2H VAR aSHST[322]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 180*nTamL ,346*nTamC1	MSGET oEx2Oc3H VAR aSHST[324]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 190*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Mulher"
@ 190*nTamL ,206*nTamC1	MSGET oEx2Oc1M VAR aSHST[321]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 190*nTamL ,276*nTamC1	MSGET oEx2Oc2M VAR aSHST[323]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 190*nTamL ,346*nTamC1	MSGET oEx2Oc3M VAR aSHST[325]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 200*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0320)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"03. Regresso ao trabalho após ausência superior a 30 dias"
@ 210*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Homem"
@ 210*nTamL ,206*nTamC1	MSGET oEx3Oc1H VAR aSHST[326]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 210*nTamL ,276*nTamC1	MSGET oEx3Oc2H VAR aSHST[328]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 210*nTamL ,346*nTamC1	MSGET oEx3Oc3H VAR aSHST[330]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 220*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[1]//"Mulher"
@ 220*nTamL ,206*nTamC1	MSGET oEx3Oc1M VAR aSHST[327]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 220*nTamL ,276*nTamC1	MSGET oEx3Oc3M VAR aSHST[329]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]
@ 220*nTamL ,346*nTamC1	MSGET oEx3Oc3M VAR aSHST[331]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[1]

@ 002*nTamL ,005*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//

@ 015*nTamL ,186*nTamC1 TO  030*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//
@ 015*nTamL ,010*nTamC1 TO  040*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//
@ 030*nTamL ,186*nTamC1 TO  250*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//
@ 030*nTamL ,246*nTamC1 TO  250*nTamL ,Iif(nHRes <= 1024,(aGdCoord[4]-200),(aGdCoord[4]-320))*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//
@ 015*nTamL ,010*nTamC1 TO  250*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[2]//


@ 020*nTamL ,266*nTamC1 SAY   OemToAnsi(STR0327)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Escalões etários"
@ 020*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0372)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//""Exames"
@ 030*nTamL ,206*nTamC1 SAY   OemToAnsi(STR0298)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"< 18 anos"
@ 030*nTamL ,266*nTamC1 SAY   OemToAnsi(STR0299)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Entre 18 e 49 anos"
@ 030*nTamL ,346*nTamC1	SAY   OemToAnsi(STR0300)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//">49 anos"
@ 040*nTamL ,026*nTamC1 SAY   OemToAnsi(STR0297)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Exames Ocasionais"
@ 050*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0321)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"04. Iniciativa do médico"
@ 060*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 060*nTamL ,206*nTamC1	MSGET oEx4Oc1H VAR aSHST[332]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 060*nTamL ,276*nTamC1	MSGET oEx4Oc2H VAR aSHST[334]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 060*nTamL ,346*nTamC1	MSGET oEx4Oc3H VAR aSHST[336]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 070*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 070*nTamL ,206*nTamC1	MSGET oEx4Oc1M VAR aSHST[333]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 070*nTamL ,276*nTamC1	MSGET oEx4Oc2M VAR aSHST[335]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 070*nTamL ,346*nTamC1	MSGET oEx4Oc3M VAR aSHST[337] 	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 080*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0322)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"05. Pedido do trabalhador"
@ 090*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 090*nTamL ,206*nTamC1	MSGET oEx5Oc1H VAR aSHST[338]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 090*nTamL ,276*nTamC1	MSGET oEx5Oc2H VAR aSHST[340]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 090*nTamL ,346*nTamC1	MSGET oEx5Oc3H VAR aSHST[342]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 100*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 100*nTamL ,206*nTamC1	MSGET oEx5Oc1M VAR aSHST[339]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 100*nTamL ,276*nTamC1	MSGET oEx5Oc2M VAR aSHST[341]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 100*nTamL ,346*nTamC1	MSGET oEx5Oc3M VAR aSHST[343]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 110*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0323)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"06. Acidente de trabalho"
@ 120*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 120*nTamL ,206*nTamC1	MSGET oEx6Oc1H VAR aSHST[344]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 120*nTamL ,276*nTamC1	MSGET oEx6Oc2H VAR aSHST[346]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 120*nTamL ,346*nTamC1	MSGET oEx6Oc3H VAR aSHST[348]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 130*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 130*nTamL ,206*nTamC1	MSGET oEx6Oc1M VAR aSHST[345]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 130*nTamL ,276*nTamC1	MSGET oEx6Oc1M VAR aSHST[347]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 130*nTamL ,346*nTamC1	MSGET oEx6Oc1M VAR aSHST[349]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 140*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0324)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"07. Doença súbita"
@ 150*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 150*nTamL ,206*nTamC1	MSGET oEx7Oc1H VAR aSHST[350]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 150*nTamL ,276*nTamC1	MSGET oEx7Oc2H VAR aSHST[352]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 150*nTamL ,346*nTamC1	MSGET oEx7Oc3H VAR aSHST[354]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 160*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 160*nTamL ,206*nTamC1	MSGET oEx7Oc1M VAR aSHST[351]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 160*nTamL ,276*nTamC1	MSGET oEx7Oc2M VAR aSHST[353]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 160*nTamL ,346*nTamC1	MSGET oEx7Oc3M VAR aSHST[355]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]

@ 170*nTamL ,046*nTamC1 SAY   OemToAnsi(STR0325)		SIZE 150*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"08. Por cessação do contrato de trabalho"
@ 180*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 180*nTamL ,206*nTamC1	MSGET oEx8Oc1H VAR aSHST[356]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 180*nTamL ,276*nTamC1	MSGET oEx8Oc2H VAR aSHST[358]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 180*nTamL ,346*nTamC1	MSGET oEx8Oc3H VAR aSHST[360]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 190*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)  		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 190*nTamL ,206*nTamC1	MSGET oEx8Oc1M VAR aSHST[357]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 190*nTamL ,276*nTamC1	MSGET oEx8Oc2M VAR aSHST[359]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 190*nTamL ,346*nTamC1	MSGET oEx8Oc3M VAR aSHST[361]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]

@ 200*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0326)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"09. Outras razões"
@ 210*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Homem"
@ 210*nTamL ,206*nTamC1	MSGET oEx9Oc1H VAR aSHST[362]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 210*nTamL ,276*nTamC1	MSGET oEx9Oc2H VAR aSHST[364]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 210*nTamL ,346*nTamC1	MSGET oEx9Oc3H VAR aSHST[366]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 220*nTamL ,160*ntamC1	SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[2]//"Mulher"
@ 220*nTamL ,206*nTamC1	MSGET oEx9Oc1M VAR aSHST[363]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 220*nTamL ,276*nTamC1	MSGET oEx9Oc2M VAR aSHST[365]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]
@ 220*nTamL ,346*nTamC1	MSGET oEx9Oc3M VAR aSHST[367]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[2]

@ 002*nTamL ,005*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL ""		  	PIXEL OF oVIIIP1:aDialogs[3]//

@ 015*nTamL ,010*nTamC1 TO  030*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[3]//
@ 030*nTamL ,010*nTamC1 TO  040*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[3]//
@ 040*nTamL ,010*nTamC1 TO  100*nTamL ,(aGdCoord[4]-150)*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[3]//
@ 030*nTamL ,150*nTamC1 TO  100*nTamL ,Iif(nHRes <= 1024,(aGdCoord[4]-250),(aGdCoord[4]-360))*nTamLC2   LABEL "" 	   			  	PIXEL OF oVIIIP1:aDialogs[3]//

@ 020*nTamL ,046*nTamC1	SAY   OemToAnsi(STR0301)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exames complementares realizados"
@ 030*nTamL ,036*nTamC1	SAY   OemToAnsi(STR0302)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Tipo de exame"
@ 030*nTamL ,176*nTamC1	SAY   OemToAnsi(STR0309)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Total Exames"
@ 030*nTamL ,286*nTamC1	SAY   OemToAnsi(STR0308)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exames obrigatórios""
@ 040*nTamL ,056*nTamC1	SAY   OemToAnsi(STR0303)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exame Sangue"
@ 040*nTamL ,186*nTamC1	MSGET oExaSan1 VAR aSHST[368]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 040*nTamL ,296*nTamC1	MSGET oExaSan2 VAR aSHST[369]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 050*nTamL ,056*nTamC1	SAY   OemToAnsi(STR0304)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exame Urina"
@ 050*nTamL ,186*nTamC1	MSGET oExaUri1 VAR aSHST[370]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 050*nTamL ,296*nTamC1	MSGET oExaUri2 VAR aSHST[371]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 060*nTamL ,056*nTamC1	SAY   OemToAnsi(STR0305)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exame Rx Tórax"
@ 060*nTamL ,186*nTamC1	MSGET oExaRxt1 VAR aSHST[372]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 060*nTamL ,296*nTamC1	MSGET oExaRxt2 VAR aSHST[373]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 070*nTamL	,056*nTamC1	SAY   OemToAnsi(STR0306)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exame Audiograma"
@ 070*nTamL	,186*nTamC1	MSGET oExaAud1 VAR aSHST[374]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 070*nTamL	,296*nTamC1	MSGET oExaAud2 VAR aSHST[375]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 080*nTamL ,056*nTamC1	SAY   OemToAnsi(STR0307)		SIZE 100*nTamBox,7 							PIXEL OF oVIIIP1:aDialogs[3]//"Exame Outros"
@ 080*nTamL ,186*nTamC1	MSGET oExaOut1 VAR aSHST[376]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]
@ 080*nTamL ,296*nTamC1	MSGET oExaOut2 VAR aSHST[377]	SIZE 020*nTamBox,8	Picture "@E 9999" 			PIXEL OF oVIIIP1:aDialogs[3]



@ 130*nTamL ,010*nTamC1    TO  260*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL STR0310		PIXEL OF oVIIIP1:aDialogs[3]//"Ações de imunização"
Aadd(aHAcoImu,{STR0311				,"cTipVac","@!X100"  ,100,/*decimal*/,/*Valid*/     ,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Tipo de vacinações"
Aadd(aHAcoImu,{STR0312				,"nNInoc" ,"@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de inoculações"
Aadd(aHAcoImu,{STR0281+"-"+STR0360	,"nNTrbH" ,"@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de trabalhadores"#"H"
Aadd(aHAcoImu,{STR0281+"-"+STR0361	,"nNTrbM" ,"@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"N.° de trabalhadores"#"M"

If Len(aCAcoImu)==0
	aAux := {}
	Aadd(aAux,Space(100))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aCAcoImu,aAux)
Endif
oGetAI:= MsNewGetDados():New(140*nTamL,020*nTamC1,200*nTamL,(aGdCoord[4]-150)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oVIIIP1:aDialogs[3],aHAcoImu,aCAcoImu)
oVIIIP1:Hide()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³VIIIPart2     ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VIII-Atividade desenvolvida no Âmbito da Saude no Trabalho		 ³±±
±±³			 ³ Parte 2 - Promocao da Saude										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VIIIPart2(oTree,oDlgMain)
Local oAtvDen,oNAcoes,oNTrabH,oNTrabM,oPrinTem 

oVIIIP2	:= TFolder():New(012*ntamL,086*nTamC1,{STR0313},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])//#"Promoção da saúde e educação para a saúde no trabalho"

@ 002*nTamL  ,005*nTamC1 TO  060*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0314 	  		PIXEL OF oVIIIP2:aDialogs[1]//"Atividades desenvolvidas"
@ 012*nTamL  ,015*nTamC1 GET oAtvDen   Var aSHST[378] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[378]))>200,(MsgAlert(STR0314+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(alltrim(Len(aSHST[378])))),STR0292),.F.),.T.) 	PIXEL OF oVIIIP2:aDialogs[1]
oAtvDen:lWordWrap:= .T.
oAtvDen:EnableVScroll( .T. )



@ 070*nTamL,005*nTamC1 TO  110*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0315		  		PIXEL OF oVIIIP2:aDialogs[1]//"N.° de ações de educação para a saúde realizadas"
@ 090*nTamL,026*nTamC1 MSGET oNAcoes VAR aSHST[379]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oVIIIP2:aDialogs[1]

@ 120*nTamL,005*nTamC1 TO  160*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0316		  		PIXEL OF oVIIIP2:aDialogs[1]//"N.° de trabalhadores abrangidos"
@ 140*nTamL,026*nTamC1 SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 								PIXEL OF oVIIIP2:aDialogs[1]//"Homem"
@ 140*nTamL,066*nTamC1 MSGET oNTrabH VAR aSHST[380]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oVIIIP2:aDialogs[1]
@ 140*nTamL,106*nTamC1 SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 								PIXEL OF oVIIIP2:aDialogs[1]//"Mulher"
@ 140*nTamL,146*nTamC1 MSGET oNTrabM VAR aSHST[381]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oVIIIP2:aDialogs[1]

@ 170*nTamL,005*nTamC1 TO  260*nTamL  ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0317		  		PIXEL OF oVIIIP2:aDialogs[1]//"Principais temas abordados"
@ 190*nTamL,026*nTamC1 GET oPrinTem Var aSHST[382] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[382]))>200,(MsgAlert(STR0317+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[382])))),STR0256),.F.),.T.) 	PIXEL OF oVIIIP2:aDialogs[1]
oPrinTem:lWordWrap:= .T.
oPrinTem:EnableVScroll( .T. )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³AcidTrbDP    ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IX-Acidentes de Trabalho e Doenças Profissionais 				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AcidTrbDP(oTree,oDlgMain)             
Local oAcTrb,oDoeProf,oPosTrbF,oProMed
oIX	:= TFolder():New(012*ntamL,086*nTamC1,{STR0330,STR0332,STR0354+"/"+STR0359},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 002*nTamL ,010*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL ""					PIXEL OF oIX:aDialogs[1]

@ 010*nTamL ,015*nTamC1 TO  260*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[1]//
@ 025*nTamL ,015*nTamC1 TO  038*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[1]//
@ 025*nTamL ,160*nTamC1 TO  260*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[1]//
@ 025*nTamL ,200*nTamC1 TO  260*nTamL , Iif(nHRes <= 1024,(aGdCoord[4]-180),(aGdCoord[4]-340))*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[1]//
@ 025*nTamL ,240*nTamC1 TO  260*nTamL , Iif(nHRes <= 1024,(aGdCoord[4]-220),(aGdCoord[4]-300))*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[1]//
@ 025*nTamL ,100*nTamC1 TO  260*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 		  			PIXEL OF oIX:aDialogs[1]//

@ 015*nTamL ,045*nTamC1 SAY   OemToAnsi(STR0331)	SIZE 200*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"Acidentes de trabalho no local e no tempo de trabalho"
@ 027*nTamL ,160*nTamC1	SAY   OemToAnsi(STR0335)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"Inferior a 1 dia"
@ 027*nTamL ,210*nTamC1	SAY   OemToAnsi(STR0336)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"1 a 3 dias de baixa"
@ 027*nTamL ,260*nTamC1	SAY   OemToAnsi(STR0337)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"4 a 30 dias de baixa"
@ 027*nTamL ,310*nTamC1	SAY   OemToAnsi(STR0338)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"Superior a 30 dias de baixa"
@ 027*nTamL ,360*nTamC1	SAY   OemToAnsi(STR0339)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"Mortal"


@ 040*nTamL ,100*nTamC1 SAY   OemToAnsi(STR0343)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de acidentes de trabalho"
@ 040*nTamL ,150*nTamC1 SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"

@ 040*nTamL ,165*nTamC1 MSGET oAcTrb 	VAR aSHST[383]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 040*nTamL ,215*nTamC1 MSGET oAcTrb 	VAR aSHST[385]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 040*nTamL ,260*nTamC1 MSGET oAcTrb 	VAR aSHST[387]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 040*nTamL ,310*nTamC1 MSGET oAcTrb	VAR aSHST[389]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 040*nTamL ,360*nTamC1 MSGET oRisOutH VAR aSHST[391]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 050*nTamL ,150*nTamC1 SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"M"
@ 050*nTamL ,165*nTamC1 MSGET oAcTrb	VAR aSHST[384]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 050*nTamL ,215*nTamC1 MSGET oAcTrb	VAR aSHST[386]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 050*nTamL ,260*nTamC1 MSGET oAcTrb	VAR aSHST[388]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 050*nTamL ,310*nTamC1 MSGET oAcTrb	VAR aSHST[390]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 050*nTamL ,360*nTamC1 MSGET oAcTrb	VAR aSHST[392]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 060*nTamL ,020*nTamC1 SAY   OemToAnsi(STR0340)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"Nas instalações da empresa"
@ 070*nTamL ,100*nTamC1	SAY   OemToAnsi(STR0344)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de dias de trabalho perdido"
@ 070*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"
@ 070*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[393]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 070*nTamL ,260*nTamC1	MSGET oAcTrb	VAR aSHST[395]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 070*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[397]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 080*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"M"
@ 080*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[394]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 080*nTamL ,260*nTamC1	MSGET oAcTrb	VAR aSHST[396]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 080*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[398]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]


@ 110*nTamL	,100*nTamC1	SAY   OemToAnsi(STR0343)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de acidentes de trabalho"
@ 110*nTamL	,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"
@ 110*nTamL	,165*nTamC1	MSGET oAcTrb	VAR aSHST[399]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 110*nTamL	,215*nTamC1	MSGET oAcTrb	VAR aSHST[401]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 110*nTamL	,260*nTamC1	MSGET oAcTrb	VAR aSHST[403]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 110*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[405]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 110*nTamL ,360*nTamC1	MSGET oAcTrb	VAR aSHST[407]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 120*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"M"
@ 120*nTamL ,165*nTamC1	MSGET oAcTrb	VAR aSHST[400]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 120*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[402]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 120*nTamL ,260*nTamC1	MSGET oAcTrb	VAR aSHST[404]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 120*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[406]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 120*nTamL ,360*nTamC1	MSGET oAcTrb	VAR aSHST[408]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 130*nTamL	,020*nTamC1	SAY   OemToAnsi(STR0341)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"Fora das instalações da empresa"
@ 140*nTamL ,100*nTamC1	SAY   OemToAnsi(STR0344)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de dias de trabalho perdido"
@ 140*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"
@ 140*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[409]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 140*nTamL ,260*nTamC1	MSGET oAcTrb	VAR aSHST[411]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 140*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[413]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 150*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0361)  		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"M"
@ 150*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[410]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 150*nTamL ,260*nTamC1	MSGET oAcTrb	VAR aSHST[412]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 150*nTamL ,310*nTamC1	MSGET oAcTrb	VAR aSHST[414]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]


@ 190*nTamL	,100*nTamC1	SAY   OemToAnsi(STR0343)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de acidentes de trabalho"
@ 190*nTamL	,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"
@ 190*nTamL	,165*nTamC1	MSGET oAcTrb	VAR aSHST[415]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 190*nTamL	,215*nTamC1	MSGET oAcTrb	VAR aSHST[417]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 190*nTamL	,260*nTamC1	MSGET oAcTrb	VAR aSHST[419]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 190*nTamL	,310*nTamC1	MSGET oAcTrb	VAR aSHST[421]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 190*nTamL	,360*nTamC1	MSGET oAcTrb	VAR aSHST[423]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 200*nTamL	,150*nTamC1	SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7	   								PIXEL OF oIX:aDialogs[1]//"M"
@ 200*nTamL	,165*nTamC1	MSGET oAcTrb	VAR aSHST[416]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 200*nTamL	,215*nTamC1	MSGET oAcTrb	VAR aSHST[418]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 200*nTamL	,260*nTamC1	MSGET oAcTrb	VAR aSHST[420]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 200*nTamL	,310*nTamC1	MSGET oAcTrb	VAR aSHST[422]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 200*nTamL	,360*nTamC1	MSGET oAcTrb	VAR aSHST[424]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 210*nTamL	,020*nTamC1	SAY   OemToAnsi(STR0342)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"Nos meios de transporte"
@ 220*nTamL	,100*nTamC1 SAY   OemToAnsi(STR0344)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"N.° de dias de trabalho perdido"
@ 220*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[1]//"H"
@ 220*nTamL ,215*nTamC1	MSGET oAcTrb	VAR aSHST[425]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 220*nTamL	,260*nTamC1	MSGET oAcTrb	VAR aSHST[427]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 220*nTamL	,310*nTamC1	MSGET oAcTrb	VAR aSHST[429]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 230*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0361)  		SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[1]//"M"
@ 230*nTamL	,215*nTamC1	MSGET oAcTrb	VAR aSHST[426]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 230*nTamL	,260*nTamC1	MSGET oAcTrb	VAR aSHST[428]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]
@ 230*nTamL	,310*nTamC1	MSGET oAcTrb	VAR aSHST[430]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[1]


@ 002*nTamL ,010*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2   LABEL ""					PIXEL OF oIX:aDialogs[2]

@ 010*nTamL ,015*nTamC1 TO  100*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[2]//
@ 025*nTamL ,015*nTamC1 TO  038*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[2]//
@ 025*nTamL ,160*nTamC1 TO  100*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[2]//
@ 025*nTamL ,200*nTamC1 TO  100*nTamL , Iif(nHRes <= 1024,(aGdCoord[4]-180),(aGdCoord[4]-340))*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[2]//
@ 025*nTamL ,240*nTamC1 TO  100*nTamL , Iif(nHRes <= 1024,(aGdCoord[4]-220),(aGdCoord[4]-300))*nTamLC2   LABEL "" 				  	PIXEL OF oIX:aDialogs[2]//
@ 038*nTamL ,100*nTamC1 TO  100*nTamL ,(aGdCoord[4]-140)*nTamLC2   LABEL "" 		  			PIXEL OF oIX:aDialogs[2]//

@ 015*nTamL ,045*nTamC1 SAY   OemToAnsi(STR0331)	SIZE 200*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"Acidentes de trabalho no local e no tempo de trabalho"
@ 027*nTamL ,160*nTamC1	SAY   OemToAnsi(STR0335)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"Inferior a 1 dia"
@ 027*nTamL ,210*nTamC1	SAY   OemToAnsi(STR0336)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"1 a 3 dias de baixa"
@ 027*nTamL ,260*nTamC1	SAY   OemToAnsi(STR0337)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"4 a 30 dias de baixa"
@ 027*nTamL ,310*nTamC1	SAY   OemToAnsi(STR0338)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"Superior a 30 dias de baixa"
@ 027*nTamL ,360*nTamC1	SAY   OemToAnsi(STR0339)	SIZE 100*nTamBox,7 									PIXEL OF oIX:aDialogs[2]//"Mortal"

@ 040*nTamL ,100*nTamC1 SAY   OemToAnsi(STR0343)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"N.° de acidentes de trabalho"
@ 040*nTamL ,150*nTamC1 SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"H"

@ 040*nTamL ,165*nTamC1 MSGET oDoeProf  VAR aSHST[431]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 040*nTamL ,215*nTamC1 MSGET oDoeProf	VAR aSHST[433]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 040*nTamL ,260*nTamC1 MSGET oDoeProf	VAR aSHST[435]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 040*nTamL ,310*nTamC1 MSGET oDoeProf	VAR aSHST[437]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 040*nTamL ,360*nTamC1 MSGET oDoeProf  VAR aSHST[439]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 050*nTamL ,150*nTamC1 SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"M"
@ 050*nTamL ,165*nTamC1 MSGET oDoeProf	VAR aSHST[432]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 050*nTamL ,215*nTamC1 MSGET oDoeProf	VAR aSHST[434]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 050*nTamL ,260*nTamC1 MSGET oDoeProf	VAR aSHST[436]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 050*nTamL ,310*nTamC1 MSGET oDoeProf	VAR aSHST[438]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 050*nTamL ,360*nTamC1 MSGET oDoeProf	VAR aSHST[440]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 060*nTamL ,020*nTamC1 SAY   OemToAnsi(STR0340)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"Nas instalações da empresa"
@ 070*nTamL ,100*nTamC1	SAY   OemToAnsi(STR0344)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"N.° de dias de trabalho perdido"
@ 070*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0360)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"H"
@ 070*nTamL ,215*nTamC1	MSGET oDoeProf	VAR aSHST[441]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 070*nTamL ,260*nTamC1	MSGET oDoeProf	VAR aSHST[443]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 070*nTamL ,310*nTamC1	MSGET oDoeProf	VAR aSHST[445]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 080*nTamL ,150*nTamC1	SAY   OemToAnsi(STR0361)		SIZE 100*nTamBox,7									PIXEL OF oIX:aDialogs[2]//"M"
@ 080*nTamL ,215*nTamC1	MSGET oDoeProf	VAR aSHST[442]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 080*nTamL ,260*nTamC1	MSGET oDoeProf	VAR aSHST[444]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 080*nTamL ,310*nTamC1	MSGET oDoeProf	VAR aSHST[446]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]



@ 110*nTamL,015*nTamC1 TO  190*nTamL ,(aGdCoord[4]-140)*nTamLC2  LABEL STR0346	  			PIXEL OF oIX:aDialogs[2]//"Número de acidentes de trabalho"
@ 120*nTamL,110*nTamC1 SAY   OemToAnsi(STR0073)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"Homem"
@ 120*nTamL,210*nTamC1 SAY   OemToAnsi(STR0074)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"Mulher"
@ 120*nTamL,020*nTamC1 SAY   OemToAnsi(STR0347)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"Tipo de horário"
@ 130*nTamL,020*nTamC1 SAY   OemToAnsi(STR0348)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"01. Horário normal"
@ 140*nTamL,020*nTamC1 SAY   OemToAnsi(STR0349)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"02. Horário de turno fixo'
@ 150*nTamL,020*nTamC1 SAY   OemToAnsi(STR0350)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"03. Horário de turno rotativo"
@ 160*nTamL,020*nTamC1 SAY   OemToAnsi(STR0351)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"04. Horário noturno"
@ 170*nTamL,020*nTamC1 SAY   OemToAnsi(STR0352)		SIZE 100*nTamBox,7 								PIXEL OF oIX:aDialogs[2]//"05. Outro horário"
@ 130*nTamL,110*nTamC1 MSGET oDoeProf  VAR aSHST[447]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 130*nTamL,210*nTamC1 MSGET oDoeProf  VAR aSHST[448]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 140*nTamL,110*nTamC1 MSGET oDoeProf  VAR aSHST[449] 	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 140*nTamL,210*nTamC1 MSGET oDoeProf  VAR aSHST[450]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 150*nTamL,110*nTamC1 MSGET oDoeProf  VAR aSHST[451]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 150*nTamL,210*nTamC1 MSGET oDoeProf  VAR aSHST[452]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 160*nTamL,110*nTamC1 MSGET oDoeProf  VAR aSHST[453]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 160*nTamL,210*nTamC1 MSGET oDoeProf  VAR aSHST[454]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 170*nTamL,110*nTamC1 MSGET oDoeProf  VAR aSHST[455]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]
@ 170*nTamL,210*nTamC1 MSGET oDoeProf  VAR aSHST[456]	SIZE 020*nTamBox,8	Picture "@E 9999" 				PIXEL OF oIX:aDialogs[2]


@ 200*nTamL,015*nTamC1 TO  260*nTamL  ,(aGdCoord[4]-130)*nTamLC2   LABEL STR0353			  	PIXEL OF oIX:aDialogs[2]//"Postos de trabalho onde os acidentes de trabalho são mais frequentes"
@ 210*nTamL,030*nTamC1 GET oPosTrbF Var aSHST[457] MEMO Size 320*nTamC1,040*nTamL;
Valid Iif(Len(alltrim(aSHST[457]))>200,(MsgAlert(STR0353+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[457])))),STR0292),.F.),.T.) 		PIXEL OF oIX:aDialogs[2]
oPosTrbF:lWordWrap:= .T.
oPosTrbF:EnableVScroll( .T. )

@ 002*nTamL ,010*nTamC1   TO  130*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0354 				PIXEL OF oIX:aDialogs[3]//"Doenças Prof. de partic. obrig."
Aadd(aHCodDoe,{STR0355					  ,"cCodDoe","@E 9999" ,4  ,0          ,/*Valid*/ 		,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Cód.Doença Prof."
Aadd(aHCodDoe,{STR0354					  ,"nDesDoe","@!X100"  ,100,/*decimal*/,/*Valid*/  		,"€€€€€€€€€€€€€€","C",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Especificação da doença"
Aadd(aHCodDoe,{STR0357+STR0363+"-"+STR0360,"nNPartH","@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Part.#N.° Casos Ano"#"H"
Aadd(aHCodDoe,{STR0358+STR0363+"-"+STR0360,"nNConfH","@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Conf.#N.° Casos Ano"#"H"
Aadd(aHCodDoe,{STR0357+STR0363+"-"+STR0361,"nNPartM","@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Part.#N.° Casos Ano"#"M"
Aadd(aHCodDoe,{STR0358+STR0363+"-"+STR0361,"nNConfM","@E 9999" ,4  ,0          ,/*valid*/    	,"€€€€€€€€€€€€€€","N",/*F3*/,/*context*/,/*cbox*/,/*relacao*/})//"Conf.#N.° Casos Ano"#"M"

If Len(aCCodDoe)==0
	aAux := {}
	Aadd(aAux,0)
	Aadd(aAux,Space(150))
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,0)
	Aadd(aAux,.F.)
	Aadd(aCCodDoe,aAux)
Endif
oGetCD:= MsNewGetDados():New(015*nTamL,015*nTamC1,080*nTamL,(aGdCoord[4]-150)*nTamLC2,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,999,,,,oIX:aDialogs[3],aHCodDoe,aCCodDoe)
@ 150*nTamL ,010*nTamC1 TO  240*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL STR0120  			PIXEL OF oIX:aDialogs[3]//"Projetos e medidas para melhoria da situação existente no domínio da segurança, higiene e saúde no trabalho"
@ 160*nTamL ,030*nTamC1 GET oProMed Var aSHST[458] MEMO Size 360*nTamC1,40*nTamL;
Valid Iif(Len(alltrim(aSHST[458]))>200,(MsgAlert(STR0120+"-"+STR0291+". "+STR0362+": "+Alltrim(Str(Len(alltrim(aSHST[458])))),STR0292),.F.),.T.) 	PIXEL OF oIX:aDialogs[3]
oProMed:lWordWrap:= .T.
oProMed:EnableVScroll( .T. )

oIX:Hide()
Return                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³MsgSHST      ³ Autor ³ Marcos Kato	 		  	³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mensagem 										 				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MsgSHST(oTree,oDlgMain)

oVIIMsg:=TFolder():New(012*ntamL,086*nTamC1,{STR0009},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 012*nTamL	,005*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2	LABEL ""						PIXEL OF oVIIMsg:aDialogs[1]
oVIIMsg:Hide()

oVIIIMsg:=TFolder():New(012*ntamL,086*nTamC1,{STR0010},{},oDlgMain,,,,.T.,.F.,aAdvSize[3]-095,aAdvSize[6])

@ 012*nTamL	,005*nTamC1 TO  280*nTamL ,(aGdCoord[4]-130)*nTamLC2  LABEL ""						PIXEL OF oVIIIMsg:aDialogs[1]
oVIIIMsg:Hide()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³ProcSHST   ³ Autor ³ Marcos Kato	 		  		³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Armazena os dados no array						  				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcSHST()
Local nCont:=1
//=======================================================================
//Ordem do Array - Capitulo,Tipo Registro,Campo,Sequencia,Tipo e Conteudo
//=======================================================================
//Capitulo I
//=======================================================================
Aadd(aProcSHST,{"I"   ,"D100","C012","001","C","100"   })
Aadd(aProcSHST,{"I"   ,"D100","C013","001","C",aSHST[1]})
Aadd(aProcSHST,{"I"   ,"D100","C014","001","C",aSHST[2]})
Aadd(aProcSHST,{"I"   ,"D100","C015","001","C",aSHST[3]})
Aadd(aProcSHST,{"I"   ,"D100","C016","001","N",aSHST[4]})
Aadd(aProcSHST,{"I"   ,"D100","C017","001","N",aSHST[5]})
Aadd(aProcSHST,{"I"   ,"D100","C018","001","C",aSHST[6]})
Aadd(aProcSHST,{"I"   ,"D100","C019","001","N",aSHST[7]})
Aadd(aProcSHST,{"I"   ,"D100","C020","001","N",aSHST[8]})
Aadd(aProcSHST,{"I"   ,"D100","C021","001","N",aSHST[9]})
Aadd(aProcSHST,{"I"   ,"D100","C022","001","N",aSHST[10]})
Aadd(aProcSHST,{"I"   ,"D100","C023","001","N",aSHST[11]})
Aadd(aProcSHST,{"I"   ,"D100","C024","001","N",aSHST[12]})
Aadd(aProcSHST,{"I"   ,"D100","C025","001","N",aSHST[13]})
Aadd(aProcSHST,{"I"   ,"D100","C026","001","N",aSHST[14]})
Aadd(aProcSHST,{"I"   ,"D100","C027","001","N",aSHST[15]})
Aadd(aProcSHST,{"I"   ,"D100","C028","001","N",aSHST[16]})
Aadd(aProcSHST,{"I"   ,"D100","C029","001","N",aSHST[17]})
Aadd(aProcSHST,{"I"   ,"D100","C030","001","N",aSHST[18]})
//=======================================================================
//Capitulo II
//=======================================================================
Aadd(aProcSHST,{"II"  ,"D200","C031","001","C","200"    })
Aadd(aProcSHST,{"II"  ,"D200","C032","001","C",aSHST[19]})
Aadd(aProcSHST,{"II"  ,"D200","C033","001","C",aSHST[20]})
Aadd(aProcSHST,{"II"  ,"D200","C034","001","C",aSHST[21]})
Aadd(aProcSHST,{"II"  ,"D200","C035","001","N",aSHST[22]})
Aadd(aProcSHST,{"II"  ,"D200","C036","001","N",aSHST[23]})
Aadd(aProcSHST,{"II"  ,"D200","C037","001","C",aSHST[24]})
Aadd(aProcSHST,{"II"  ,"D200","C038","001","N",aSHST[25]})
Aadd(aProcSHST,{"II"  ,"D200","C039","001","N",aSHST[26]})
Aadd(aProcSHST,{"II"  ,"D200","C040","001","N",aSHST[27]})
Aadd(aProcSHST,{"II"  ,"D200","C041","001","N",aSHST[28]})
Aadd(aProcSHST,{"II"  ,"D200","C042","001","N",aSHST[29]})
Aadd(aProcSHST,{"II"  ,"D200","C043","001","N",aSHST[30]})
Aadd(aProcSHST,{"II"  ,"D200","C044","001","N",aSHST[31]})
Aadd(aProcSHST,{"II"  ,"D200","C045","001","N",aSHST[32]})
Aadd(aProcSHST,{"II"  ,"D200","C046","001","N",aSHST[33]})
Aadd(aProcSHST,{"II"  ,"D200","C047","001","N",aSHST[34]})
//=======================================================================
//Capitulo III
//=======================================================================
Aadd(aProcSHST,{"III" ,"D210","C048","001","N","210"	})
Aadd(aProcSHST,{"III" ,"D210","C049","001","N",Substr(aSHST[35],1,1)})
Aadd(aProcSHST,{"III" ,"D210","C050","001","N",Substr(aSHST[36],1,1)})
Aadd(aProcSHST,{"III" ,"D210","C051","001","N",Substr(aSHST[37],1,1)})
//=======================================================================
//Capitulo IV
//=======================================================================
Aadd(aProcSHST,{"IV"  ,"D220","C052","001","C","220"})
Aadd(aProcSHST,{"IV"  ,"D220","C053","001","N",aSHST[38]})
Aadd(aProcSHST,{"IV"  ,"D220","C054","001","N",aSHST[39]})
Aadd(aProcSHST,{"IV"  ,"D220","C055","001","N",aSHST[40]})
Aadd(aProcSHST,{"IV"  ,"D220","C056","001","N",aSHST[41]})
Aadd(aProcSHST,{"IV"  ,"D220","C057","001","N",aSHST[42]})
Aadd(aProcSHST,{"IV"  ,"D220","C058","001","N",aSHST[43]})
Aadd(aProcSHST,{"IV"  ,"M221","C059","000","C","221"})
aICMTrb:=oGetIM:aCols
For nCont:=1 To Len(aICMTrb)
	If !Empty(aICMTrb[nCont][1]) .And. !(aICMTrb[nCont][4])
		Aadd(aProcSHST,{"IV" ,"M221","C060",StrZero(nCont,3),"C",aICMTrb[nCont][1]})
		Aadd(aProcSHST,{"IV" ,"M221","C061",StrZero(nCont,3),"N",aICMTrb[nCont][2]})
		Aadd(aProcSHST,{"IV" ,"M221","C062",StrZero(nCont,3),"N",aICMTrb[nCont][3]})
	Else
		Aadd(aDelSHST,{"IV" ,"M221","C060",StrZero(nCont,3),"C",aICMTrb[nCont][1]})
		Aadd(aDelSHST,{"IV" ,"M221","C061",StrZero(nCont,3),"N",aICMTrb[nCont][2]})
		Aadd(aDelSHST,{"IV" ,"M221","C062",StrZero(nCont,3),"N",aICMTrb[nCont][3]})
	Endif
Next                        
Aadd(aProcSHST,{"IV " ,"M222","C063","000","C","222"})
aICTTrb:=oGetIT:aCols
For nCont:=1 To Len(aICTTrb) 
	If !Empty(aICTTrb[nCont][1]).And. !(aICTTrb[nCont][3])
		Aadd(aProcSHST,{"IV" ,"M222","C064",StrZero(nCont,3),"C",aICTTrb[nCont][1]})
		Aadd(aProcSHST,{"IV" ,"M222","C065",StrZero(nCont,3),"N",aICTTrb[nCont][2]})
	Else
		Aadd(aDelSHST,{"IV" ,"M222","C064",StrZero(nCont,3),"C",aICTTrb[nCont][1]})
		Aadd(aDelSHST,{"IV" ,"M222","C065",StrZero(nCont,3),"N",aICTTrb[nCont][2]})
	Endif
Next
Aadd(aProcSHST,{"IV"  ,"D223","C066","001","C","223"})
Aadd(aProcSHST,{"IV"  ,"D223","C067","001","C",aSHST[49]})
Aadd(aProcSHST,{"IV"  ,"D223","C068","001","N",aSHST[44]})
Aadd(aProcSHST,{"IV"  ,"D223","C069","001","N",aSHST[45]})
Aadd(aProcSHST,{"IV"  ,"D223","C070","001","N",aSHST[46]})
Aadd(aProcSHST,{"IV"  ,"D223","C071","001","N",aSHST[47]})
Aadd(aProcSHST,{"IV"  ,"D223","C072","001","N",aSHST[48]})
Aadd(aProcSHST,{"IV"  ,"D223","C073","001","C",aSHST[50]})
Aadd(aProcSHST,{"IV"  ,"M224","C074","000","C","224"})
aECMTrb:=oGetEM:aCols
For nCont:=1 To Len(aECMTrb)       
	If !Empty(aECMTrb[nCont][1]).And.!(aECMTrb[nCont][4])
		Aadd(aProcSHST,{"IV" ,"M224","C075",StrZero(nCont,3),"C",aECMTrb[nCont][1]})
		Aadd(aProcSHST,{"IV" ,"M224","C076",StrZero(nCont,3),"N",aECMTrb[nCont][2]})
		Aadd(aProcSHST,{"IV" ,"M224","C077",StrZero(nCont,3),"N",aECMTrb[nCont][3]})
	Else
		Aadd(aDelSHST,{"IV" ,"M224","C075",StrZero(nCont,3),"C",aECMTrb[nCont][1]})
		Aadd(aDelSHST,{"IV" ,"M224","C076",StrZero(nCont,3),"N",aECMTrb[nCont][2]})
		Aadd(aDelSHST,{"IV" ,"M224","C077",StrZero(nCont,3),"N",aECMTrb[nCont][3]})
	Endif	
Next                        
Aadd(aProcSHST,{"IV"  ,"M225","C078","000","C","225"})
aECTTrb:=oGetET:aCols
For nCont:=1 To Len(aECTTrb)    
	If !Empty(aECTTrb[nCont][1]).And.!(aECTTrb[nCont][3])
		Aadd(aProcSHST,{"IV" ,"M225","C079",StrZero(nCont,3),"C",aECTTrb[nCont][1]})
		Aadd(aProcSHST,{"IV" ,"M225","C080",StrZero(nCont,3),"N",aECTTrb[nCont][2]})
	Else
		Aadd(aDelSHST,{"IV" ,"M225","C079",StrZero(nCont,3),"C",aECTTrb[nCont][1]})
		Aadd(aDelSHST,{"IV" ,"M225","C080",StrZero(nCont,3),"N",aECTTrb[nCont][2]})
    Endif
Next
//=======================================================================
//Capitulo V
//=======================================================================
Aadd(aProcSHST,{"V"  ,"D230","C081","001","C","230"})
Aadd(aProcSHST,{"V"  ,"D230","C082","001","N",aSHST[51]})
Aadd(aProcSHST,{"V"  ,"D230","C083","001","N",aSHST[59]})
Aadd(aProcSHST,{"V"  ,"D230","C084","001","N",aSHST[52]})
Aadd(aProcSHST,{"V"  ,"D230","C085","001","N",aSHST[60]})
Aadd(aProcSHST,{"V"  ,"D230","C086","001","N",aSHST[53]})
Aadd(aProcSHST,{"V"  ,"D230","C087","001","N",aSHST[61]})
Aadd(aProcSHST,{"V"  ,"D230","C088","001","N",aSHST[54]})
Aadd(aProcSHST,{"V"  ,"D230","C089","001","N",aSHST[62]})
Aadd(aProcSHST,{"V"  ,"D230","C090","001","N",aSHST[55]})
Aadd(aProcSHST,{"V"  ,"D230","C091","001","N",aSHST[63]})
Aadd(aProcSHST,{"V"  ,"D230","C092","001","N",aSHST[56]})
Aadd(aProcSHST,{"V"  ,"D230","C093","001","N",aSHST[64]})
Aadd(aProcSHST,{"V"  ,"D230","C094","001","N",aSHST[57]})
Aadd(aProcSHST,{"V"  ,"D230","C095","001","N",aSHST[65]})
Aadd(aProcSHST,{"V"  ,"D230","C096","001","N",aSHST[58]})
Aadd(aProcSHST,{"V"  ,"D230","C097","001","N",aSHST[66]})
Aadd(aProcSHST,{"V"  ,"D230","C098","001","N",aSHST[67]})
//=======================================================================
//Capitulo VI
//=======================================================================
Aadd(aProcSHST,{"VI"  ,"V240","C099","000","C","240<INI>"})
If LEN(Alltrim(aSHST[68]))>100
	Aadd(aProcSHST,{"VI"  ,"V240","C099","001","C",Substr(Alltrim(aSHST[68]),1,100)})
	Aadd(aProcSHST,{"VI"  ,"V240","C099","002","C",Substr(Alltrim(aSHST[68]),101,100)})		
Else
	Aadd(aProcSHST,{"VI"  ,"V240","C099","001","C",Alltrim(aSHST[68])})
Endif
Aadd(aProcSHST,{"VI"  ,"V240","C099","999","C","</FIM>"})
Aadd(aProcSHST,{"VI"  ,"D241","C100","001","C","241"	})
Aadd(aProcSHST,{"VI"  ,"D241","C101","001","N",aSHST[69]})
Aadd(aProcSHST,{"VI"  ,"D241","C102","001","N",aSHST[70]})
Aadd(aProcSHST,{"VI"  ,"D241","C103","001","N",aSHST[71]})
Aadd(aProcSHST,{"VI"  ,"D241","C104","001","N",aSHST[72]})
Aadd(aProcSHST,{"VI"  ,"D241","C105","001","N",aSHST[73]})
Aadd(aProcSHST,{"VI"  ,"D241","C106","001","N",aSHST[74]})
Aadd(aProcSHST,{"VI"  ,"D241","C107","001","N",aSHST[75]})
Aadd(aProcSHST,{"VI"  ,"D241","C108","001","N",aSHST[76]})
Aadd(aProcSHST,{"VI"  ,"D241","C109","001","N",aSHST[77]})
Aadd(aProcSHST,{"VI"  ,"D241","C110","001","N",aSHST[78]})
//Aadd(aProcSHST,{"VI"  ,"D241","C111","001","N",aSHST[79]})//No Documento a informacao do risco nao contem o Tipo Homem do item 6
Aadd(aProcSHST,{"VI"  ,"D241","C112","001","N",aSHST[80]})
Aadd(aProcSHST,{"VI"  ,"D241","C113","001","N",aSHST[81]})
Aadd(aProcSHST,{"VI"  ,"D241","C114","001","N",aSHST[82]})
Aadd(aProcSHST,{"VI"  ,"V242","C115","000","C","242<INI>"})
If Len(Alltrim(aSHST[83]))>100
	Aadd(aProcSHST,{"VI"  ,"V242","C115","001","C",Substr(Alltrim(aSHST[83]),1,100)})
	Aadd(aProcSHST,{"VI"  ,"V242","C115","002","C",Substr(Alltrim(aSHST[83]),101,100)})		
Else
	Aadd(aProcSHST,{"VI"  ,"V242","C115","001","C",Alltrim(aSHST[83])})
Endif
Aadd(aProcSHST,{"VI"  ,"V242","C115","999","C","</FIM>"})
Aadd(aProcSHST,{"VI"  ,"M243","C116","000","C","243"})
aCAcFor:=oGetAF:aCols
For nCont:=1 To Len(aCAcFor)
	If !Empty(aCAcFor[nCont][1]) .And. !(aCAcFor[nCont][7])
		Aadd(aProcSHST,{"VI" ,"M243","C117",StrZero(nCont,3),"C",aCAcFor[nCont][1]+Space(100-Len(aCAcFor[nCont][1]))})
		Aadd(aProcSHST,{"VI" ,"M243","C118",StrZero(nCont,3),"N",aCAcFor[nCont][2]})
		Aadd(aProcSHST,{"VI" ,"M243","C119",StrZero(nCont,3),"N",aCAcFor[nCont][3]})
		Aadd(aProcSHST,{"VI" ,"M243","C120",StrZero(nCont,3),"C",aCAcFor[nCont][4]+Space(100-Len(aCAcFor[nCont][4]))})
		Aadd(aProcSHST,{"VI" ,"M243","C121",StrZero(nCont,3),"N",aCAcFor[nCont][5]})
		Aadd(aProcSHST,{"VI" ,"M243","C122",StrZero(nCont,3),"N",aCAcFor[nCont][6]})
	Else
		Aadd(aDelSHST,{"VI" ,"M243","C117",StrZero(nCont,3),"C",aCAcFor[nCont][1]+Space(100-Len(aCAcFor[nCont][1]))})
		Aadd(aDelSHST,{"VI" ,"M243","C118",StrZero(nCont,3),"N",aCAcFor[nCont][2]})
		Aadd(aDelSHST,{"VI" ,"M243","C119",StrZero(nCont,3),"N",aCAcFor[nCont][3]})
		Aadd(aDelSHST,{"VI" ,"M243","C120",StrZero(nCont,3),"C",aCAcFor[nCont][4]+Space(100-Len(aCAcFor[nCont][4]))})
		Aadd(aDelSHST,{"VI" ,"M243","C121",StrZero(nCont,3),"N",aCAcFor[nCont][5]})
		Aadd(aDelSHST,{"VI" ,"M243","C122",StrZero(nCont,3),"N",aCAcFor[nCont][6]})
	Endif	
Next                                                  
Aadd(aProcSHST,{"VI"  ,"D244","C123","001","C","244"})
Aadd(aProcSHST,{"VI"  ,"D244","C124","001","N",aSHST[84]})
Aadd(aProcSHST,{"VI"  ,"D244","C125","001","N",aSHST[85]})

Aadd(aProcSHST,{"VI"  ,"M245","C126","000","C","245"})

aCForPe:=oGetFP:aCols
For nCont:=1 To Len(aCForPe)
	If !Empty(aCForPe[nCont][1]).And.!(aCForPe[nCont][6])
		Aadd(aProcSHST,{"IV" ,"M245","C127",StrZero(nCont,3),"C",aCForPe[nCont][1]+Space(100-Len(aCForPe[nCont][1]))})
		Aadd(aProcSHST,{"IV" ,"M245","C128",StrZero(nCont,3),"N",aCForPe[nCont][2]})
		Aadd(aProcSHST,{"IV" ,"M245","C129",StrZero(nCont,3),"N",aCForPe[nCont][3]})
		Aadd(aProcSHST,{"IV" ,"M245","C130",StrZero(nCont,3),"N",aCForPe[nCont][4]})
		Aadd(aProcSHST,{"IV" ,"M245","C131",StrZero(nCont,3),"N",aCForPe[nCont][5]})
	Else 
		Aadd(aDelSHST,{"IV" ,"M245","C127",StrZero(nCont,3),"C",aCForPe[nCont][1]+Space(100-Len(aCForPe[nCont][1]))})
		Aadd(aDelSHST,{"IV" ,"M245","C128",StrZero(nCont,3),"N",aCForPe[nCont][2]})
		Aadd(aDelSHST,{"IV" ,"M245","C129",StrZero(nCont,3),"N",aCForPe[nCont][3]})
		Aadd(aDelSHST,{"IV" ,"M245","C130",StrZero(nCont,3),"N",aCForPe[nCont][4]})
		Aadd(aDelSHST,{"IV" ,"M245","C131",StrZero(nCont,3),"N",aCForPe[nCont][5]})
	Endif	
Next                                                 
Aadd(aProcSHST,{"VI"  ,"D246","C132","001","C","246"})
Aadd(aProcSHST,{"VI"  ,"D246","C133","001","C",aSHST[86]})
Aadd(aProcSHST,{"VI"  ,"D246","C134","001","C",aSHST[93]})
Aadd(aProcSHST,{"VI"  ,"D246","C135","001","N",aSHST[100]})
Aadd(aProcSHST,{"VI"  ,"D246","C136","001","C",aSHST[87]})
Aadd(aProcSHST,{"VI"  ,"D246","C137","001","C",aSHST[94]})
Aadd(aProcSHST,{"VI"  ,"D246","C138","001","N",aSHST[101]})
Aadd(aProcSHST,{"VI"  ,"D246","C139","001","C",aSHST[88]})
Aadd(aProcSHST,{"VI"  ,"D246","C140","001","C",aSHST[95]})
Aadd(aProcSHST,{"VI"  ,"D246","C141","001","N",aSHST[102]})
Aadd(aProcSHST,{"VI"  ,"D246","C142","001","C",aSHST[89]})
Aadd(aProcSHST,{"VI"  ,"D246","C143","001","C",aSHST[96]})
Aadd(aProcSHST,{"VI"  ,"D246","C144","001","N",aSHST[103]})
Aadd(aProcSHST,{"VI"  ,"D246","C145","001","C",aSHST[90]})
Aadd(aProcSHST,{"VI"  ,"D246","C146","001","C",aSHST[97]})
Aadd(aProcSHST,{"VI"  ,"D246","C147","001","N",aSHST[104]})
Aadd(aProcSHST,{"VI"  ,"D246","C148","001","C",aSHST[91]})
Aadd(aProcSHST,{"VI"  ,"D246","C149","001","C",aSHST[98]})
Aadd(aProcSHST,{"VI"  ,"D246","C150","001","N",aSHST[105]})
Aadd(aProcSHST,{"VI"  ,"D246","C151","001","C",aSHST[92]})
Aadd(aProcSHST,{"VI"  ,"D246","C152","001","C",aSHST[99]})
Aadd(aProcSHST,{"VI"  ,"D246","C153","001","N",aSHST[106]})
//===============================================================================
//Capitulo VII -  Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho  
//Parte 1 - Condições de trabalho e avaliação de riscos profissionais
//===============================================================================
Aadd(aProcSHST,{"VII" ,"D250","C154","001","C","250"})
Aadd(aProcSHST,{"VII" ,"D250","C155","001","N",Substr(aSHST[107],1,1)})
Aadd(aProcSHST,{"VII" ,"D250","C156","001","N",Iif(Substr(aSHST[107],1,1)=="0",0,aSHST[108])})
Aadd(aProcSHST,{"VII" ,"D250","C157","001","N",Iif(Substr(aSHST[107],1,1)=="0",0,aSHST[109])})
Aadd(aProcSHST,{"VII" ,"D250","C158","001","N",Iif(Substr(aSHST[107],1,1)=="0",0,aSHST[110])})
Aadd(aProcSHST,{"VII" ,"D250","C159","001","N",Iif(Substr(aSHST[107],1,1)=="0",0,aSHST[111])})
Aadd(aProcSHST,{"VII" ,"D250","C160","001","N",Substr(aSHST[112],1,1)})
Aadd(aProcSHST,{"VII" ,"D250","C161","001","N",Iif(Substr(aSHST[112],1,1)=="0",0,aSHST[113])})
Aadd(aProcSHST,{"VII" ,"D250","C162","001","N",Iif(Substr(aSHST[112],1,1)=="0",0,aSHST[114])})
Aadd(aProcSHST,{"VII" ,"D250","C163","001","N",Iif(Substr(aSHST[112],1,1)=="0",0,aSHST[115])})
Aadd(aProcSHST,{"VII" ,"D250","C164","001","N",Iif(Substr(aSHST[112],1,1)=="0",0,aSHST[116])})
Aadd(aProcSHST,{"VII" ,"D250","C165","001","N",Substr(aSHST[117],1,1)})
Aadd(aProcSHST,{"VII" ,"D250","C166","001","N",Iif(Substr(aSHST[117],1,1)=="0",0,aSHST[118])})
Aadd(aProcSHST,{"VII" ,"D250","C167","001","N",Iif(Substr(aSHST[117],1,1)=="0",0,aSHST[119])})
Aadd(aProcSHST,{"VII" ,"D250","C168","001","N",Iif(Substr(aSHST[117],1,1)=="0",0,aSHST[120])})
Aadd(aProcSHST,{"VII" ,"D250","C169","001","N",Iif(Substr(aSHST[117],1,1)=="0",0,aSHST[121])})
Aadd(aProcSHST,{"VII" ,"D250","C170","001","N",Substr(aSHST[122],1,1)})
Aadd(aProcSHST,{"VII" ,"D250","C171","001","N",Iif(Substr(aSHST[122],1,1)=="0",0,aSHST[123])})
Aadd(aProcSHST,{"VII" ,"D250","C172","001","N",Iif(Substr(aSHST[122],1,1)=="0",0,aSHST[124])})
Aadd(aProcSHST,{"VII" ,"D250","C173","001","N",Iif(Substr(aSHST[122],1,1)=="0",0,aSHST[125])})
Aadd(aProcSHST,{"VII" ,"D250","C174","001","N",Iif(Substr(aSHST[122],1,1)=="0",0,aSHST[126])})
Aadd(aProcSHST,{"VII" ,"M251","C175","000","C","251"})

aCAudit:=oGetAud:aCols
For nCont:=1 To Len(aCAudit)   
	If !Empty(aCAudit[nCont][1]).And.!(aCAudit[nCont][3])
		Aadd(aProcSHST,{"VII" ,"M251","C176",StrZero(nCont,3),"C",aCAudit[nCont][1]+Space(70-Len(aCAudit[nCont][1]))})
		Aadd(aProcSHST,{"VII" ,"M251","C177",StrZero(nCont,3),"N",aCAudit[nCont][2]})
	Else
		Aadd(aDelSHST,{"VII" ,"M251","C176",StrZero(nCont,3),"C",aCAudit[nCont][1]+Space(70-Len(aCAudit[nCont][1]))})
		Aadd(aDelSHST,{"VII" ,"M251","C177",StrZero(nCont,3),"N",aCAudit[nCont][2]})
	Endif	

Next                                                                            
//===============================================================================
//Capitulo VII -  Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho  
//Parte 2 - Intervenções técnicas no controle do ambiente de trabalho
//===============================================================================
Aadd(aProcSHST,{"VII" ,"D252","C178","001","C","252"})     
Aadd(aProcSHST,{"VII" ,"D252","C179","001","N",Substr(aSHST[127],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C180","001","N",Substr(aSHST[128],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C181","001","N",Substr(aSHST[129],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C182","001","N",Substr(aSHST[130],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C183","001","N",aSHST[131]})
Aadd(aProcSHST,{"VII" ,"D252","C184","001","C",Substr(aSHST[132],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C185","001","N",aSHST[133]})
Aadd(aProcSHST,{"VII" ,"D252","C186","001","C",Substr(aSHST[134],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C187","001","N",aSHST[135]})
Aadd(aProcSHST,{"VII" ,"D252","C188","001","C",Substr(aSHST[136],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C189","001","N",aSHST[137]})
Aadd(aProcSHST,{"VII" ,"D252","C190","001","C",Substr(aSHST[138],1,1)})
Aadd(aProcSHST,{"VII" ,"D252","C191","001","C",aSHST[141]})
Aadd(aProcSHST,{"VII" ,"D252","C192","001","N",aSHST[139]})
Aadd(aProcSHST,{"VII" ,"D252","C193","001","C",Substr(aSHST[140],1,1)})
Aadd(aProcSHST,{"VII" ,"V253","C194","000","C","253<INI>"})
If Len(Alltrim(aSHST[142]))>100
	Aadd(aProcSHST,{"VII"  ,"V253","C194","001","C",Substr(Alltrim(aSHST[142]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V253","C194","002","C",Substr(Alltrim(aSHST[142]),101,100)})		
Else
	Aadd(aProcSHST,{"VII"  ,"V253","C194","001","C",Alltrim(aSHST[142])})
Endif
Aadd(aProcSHST,{"VII" ,"V253","C194","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"V254","C195","000","C","254<INI>"})
If Len(Alltrim(aSHST[143]))>100
	Aadd(aProcSHST,{"VII"  ,"V254","C195","001","C",Substr(Alltrim(aSHST[143]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V254","C195","002","C",Substr(Alltrim(aSHST[143]),101,100)})		
Else
	Aadd(aProcSHST,{"VII"  ,"V254","C195","001","C",Alltrim(aSHST[143])})
Endif                              
Aadd(aProcSHST,{"VII" ,"V254","C195","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"V255","C196","000","C","255<INI>"})
If Len(Alltrim(aSHST[144]))>100
	Aadd(aProcSHST,{"VII"  ,"V255","C196","001","C",Substr(Alltrim(aSHST[144]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V255","C196","002","C",Substr(Alltrim(aSHST[144]),101,100)})		
Else
	Aadd(aProcSHST,{"VII"  ,"V255","C196","001","C",Alltrim(aSHST[144])})
Endif                                                                            
Aadd(aProcSHST,{"VII" ,"V255","C196","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"D256","C197","001","C","256"})
Aadd(aProcSHST,{"VII" ,"D256","C198","001","N",aSHST[145]})
Aadd(aProcSHST,{"VII" ,"D256","C199","001","C",Substr(aSHST[146],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C200","001","N",aSHST[147]})
Aadd(aProcSHST,{"VII" ,"D256","C201","001","C",Substr(aSHST[148],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C202","001","N",aSHST[149]})
Aadd(aProcSHST,{"VII" ,"D256","C203","001","C",Substr(aSHST[150],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C204","001","N",aSHST[151]})
Aadd(aProcSHST,{"VII" ,"D256","C205","001","C",Substr(aSHST[152],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C206","001","N",aSHST[153]})
Aadd(aProcSHST,{"VII" ,"D256","C207","001","C",Substr(aSHST[154],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C208","001","N",aSHST[155]})
Aadd(aProcSHST,{"VII" ,"D256","C209","001","C",Substr(aSHST[156],1,1)})
Aadd(aProcSHST,{"VII" ,"D256","C210","001","C",aSHST[157]})
Aadd(aProcSHST,{"VII" ,"D256","C211","001","N",aSHST[158]})
Aadd(aProcSHST,{"VII" ,"D256","C212","001","C",Substr(aSHST[159],1,1)})

                                                                                 
Aadd(aProcSHST,{"VII" ,"V257","C213","000","C","257<INI>"})                      
If Len(Alltrim(aSHST[160]))>100
	Aadd(aProcSHST,{"VII"  ,"V257","C213","001","C",Substr(Alltrim(aSHST[160]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V257","C213","002","C",Substr(Alltrim(aSHST[160]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V257","C213","001","C",Alltrim(aSHST[160])})
Endif                                                      
Aadd(aProcSHST,{"VII" ,"V257","C213","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"V258","C214","000","C","258<INI>"})
If Len(Alltrim(aSHST[161]))>100
	Aadd(aProcSHST,{"VII"  ,"V258","C214","001","C",Substr(Alltrim(aSHST[161]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V258","C214","002","C",Substr(Alltrim(aSHST[161]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V258","C214","001","C",Alltrim(aSHST[161])})
Endif	
Aadd(aProcSHST,{"VII" ,"V258","C214","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"V259","C215","000","C","259<INI>"})
If Len(Alltrim(aSHST[162]))>100
	Aadd(aProcSHST,{"VII"  ,"V259","C215","001","C",Substr(Alltrim(aSHST[162]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V259","C215","002","C",Substr(Alltrim(aSHST[162]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V259","C215","001","C",Alltrim(aSHST[162])})
Endif                              
Aadd(aProcSHST,{"VII" ,"V259","C215","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"M25A","C216","000","C","25A"})
aCAgFis:=oGetAFis:aCols
For nCont:=1 To Len(aCAgFis)   
	If !Empty(aCAgFis[nCont][1]).And.!(aCAgFis[nCont][9])
		Aadd(aProcSHST,{"VII" ,"M25A","C217",StrZero(nCont,3),"C",aCAgFis[nCont][1]})
		Aadd(aProcSHST,{"VII" ,"M25A","C218",StrZero(nCont,3),"N",aCAgFis[nCont][2]})
		Aadd(aProcSHST,{"VII" ,"M25A","C219",StrZero(nCont,3),"N",aCAgFis[nCont][3]})
		Aadd(aProcSHST,{"VII" ,"M25A","C220",StrZero(nCont,3),"C",aCAgFis[nCont][4]})
		Aadd(aProcSHST,{"VII" ,"M25A","C221",StrZero(nCont,3),"C",aCAgFis[nCont][5]})
		Aadd(aProcSHST,{"VII" ,"M25A","C222",StrZero(nCont,3),"C",aCAgFis[nCont][6]})
		Aadd(aProcSHST,{"VII" ,"M25A","C223",StrZero(nCont,3),"N",aCAgFis[nCont][7]})								
		Aadd(aProcSHST,{"VII" ,"M25A","C224",StrZero(nCont,3),"C",aCAgFis[nCont][8]})
	Else
		Aadd(aDelSHST,{"VII" ,"M25A","C217",StrZero(nCont,3),"C",aCAgFis[nCont][1]})
		Aadd(aDelSHST,{"VII" ,"M25A","C218",StrZero(nCont,3),"N",aCAgFis[nCont][2]})
		Aadd(aDelSHST,{"VII" ,"M25A","C219",StrZero(nCont,3),"N",aCAgFis[nCont][3]})
		Aadd(aDelSHST,{"VII" ,"M25A","C220",StrZero(nCont,3),"C",aCAgFis[nCont][4]})
		Aadd(aDelSHST,{"VII" ,"M25A","C221",StrZero(nCont,3),"C",aCAgFis[nCont][5]})
		Aadd(aDelSHST,{"VII" ,"M25A","C222",StrZero(nCont,3),"C",aCAgFis[nCont][6]})
		Aadd(aDelSHST,{"VII" ,"M25A","C223",StrZero(nCont,3),"N",aCAgFis[nCont][7]})								
		Aadd(aDelSHST,{"VII" ,"M25A","C224",StrZero(nCont,3),"C",aCAgFis[nCont][8]})
	Endif	
	
Next                        

Aadd(aProcSHST,{"VII" ,"V25B","C225","000","C","25B<INI>"})                         
If Len(Alltrim(aSHST[163]))>100
	Aadd(aProcSHST,{"VII"  ,"V25B","C225","001","C",Substr(Alltrim(aSHST[163]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25B","C225","002","C",Substr(Alltrim(aSHST[163]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25B","C225","001","C",Alltrim(aSHST[163])})
Endif
Aadd(aProcSHST,{"VII" ,"V25B","C225","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"V25C","C226","000","C","25C<INI>"})
If Len(Alltrim(aSHST[164]))>100
	Aadd(aProcSHST,{"VII"  ,"V25C","C226","001","C",Substr(Alltrim(aSHST[164]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25C","C226","002","C",Substr(Alltrim(aSHST[164]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25C","C226","001","C",Alltrim(aSHST[164])})
Endif	
Aadd(aProcSHST,{"VII" ,"V25C","C226","999","C","</FIM>"})

Aadd(aProcSHST,{"VII" ,"M25D","C227","000","C","25D"})
aCAgQui:=oGetAQui:aCols
For nCont:=1 To Len(aCAgQui)   
	If !Empty(aCAgQui[nCont][1]).And.!(aCAgQui[nCont][9])
		Aadd(aProcSHST,{"VII" ,"M25D","C228",StrZero(nCont,3),"N",aCAgQui[nCont][1]})
		Aadd(aProcSHST,{"VII" ,"M25D","C229",StrZero(nCont,3),"C",aCAgQui[nCont][2]+Space(10-Len(aCAgQui[nCont][2]))})
		Aadd(aProcSHST,{"VII" ,"M25D","C230",StrZero(nCont,3),"C",aCAgQui[nCont][3]+Space(3-Len(aCAgQui[nCont][3]))})
		Aadd(aProcSHST,{"VII" ,"M25D","C231",StrZero(nCont,3),"N",aCAgQui[nCont][4]})
		Aadd(aProcSHST,{"VII" ,"M25D","C232",StrZero(nCont,3),"N",aCAgQui[nCont][5]})
		Aadd(aProcSHST,{"VII" ,"M25D","C233",StrZero(nCont,3),"C",aCAgQui[nCont][6]})
		Aadd(aProcSHST,{"VII" ,"M25D","C234",StrZero(nCont,3),"N",aCAgQui[nCont][7]})								
		Aadd(aProcSHST,{"VII" ,"M25D","C235",StrZero(nCont,3),"C",aCAgQui[nCont][8]})		
	Else
		Aadd(aDelSHST,{"VII" ,"M25D","C228",StrZero(nCont,3),"N",aCAgQui[nCont][1]})
		Aadd(aDelSHST,{"VII" ,"M25D","C229",StrZero(nCont,3),"C",aCAgQui[nCont][2]+Space(10-Len(aCAgQui[nCont][2]))})
		Aadd(aDelSHST,{"VII" ,"M25D","C230",StrZero(nCont,3),"C",aCAgQui[nCont][3]+Space(3-Len(aCAgQui[nCont][3]))})
		Aadd(aDelSHST,{"VII" ,"M25D","C231",StrZero(nCont,3),"N",aCAgQui[nCont][4]})
		Aadd(aDelSHST,{"VII" ,"M25D","C232",StrZero(nCont,3),"N",aCAgQui[nCont][5]})
		Aadd(aDelSHST,{"VII" ,"M25D","C233",StrZero(nCont,3),"C",aCAgQui[nCont][6]})
		Aadd(aDelSHST,{"VII" ,"M25D","C234",StrZero(nCont,3),"N",aCAgQui[nCont][7]})								
		Aadd(aDelSHST,{"VII" ,"M25D","C235",StrZero(nCont,3),"C",aCAgQui[nCont][8]})		
	Endif	
Next     
Aadd(aProcSHST,{"VII" ,"V25E","C236","000","C","25E<INI>"})                                            
If Len(Alltrim(aSHST[165]))>100
	Aadd(aProcSHST,{"VII"  ,"V25E","C236","001","C",Substr(Alltrim(aSHST[165]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25E","C236","002","C",Substr(Alltrim(aSHST[165]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25E","C236","001","C",Alltrim(aSHST[165])})
Endif
Aadd(aProcSHST,{"VII" ,"V25E","C236","999","C","</FIM>"})             

Aadd(aProcSHST,{"VII" ,"V25F","C237","000","C","25F<INI>"})             
If Len(Alltrim(aSHST[166]))>100
	Aadd(aProcSHST,{"VII"  ,"V25F","C237","001","C",Substr(Alltrim(aSHST[166]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25F","C237","002","C",Substr(Alltrim(aSHST[166]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25F","C237","001","C",Alltrim(aSHST[166])})
Endif	
Aadd(aProcSHST,{"VII" ,"V25F","C237","999","C","</FIM>"})             

Aadd(aProcSHST,{"VII" ,"V25G","C238","000","C","25G<INI>"})             
If Len(Alltrim(aSHST[167]))>100
	Aadd(aProcSHST,{"VII"  ,"V25G","C238","001","C",Substr(Alltrim(aSHST[167]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25G","C238","002","C",Substr(Alltrim(aSHST[167]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25G","C238","001","C",Alltrim(aSHST[167])})
Endif                       
Aadd(aProcSHST,{"VII" ,"V25G","C238","999","C","</FIM>"})                          
Aadd(aProcSHST,{"VII" ,"V25H","C239","000","C","25H<INI>"})             
If Len(Alltrim(aSHST[168]))>100
	Aadd(aProcSHST,{"VII"  ,"V25H","C239","001","C",Substr(Alltrim(aSHST[168]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25H","C239","002","C",Substr(Alltrim(aSHST[168]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25H","C239","001","C",Alltrim(aSHST[168])})
Endif	                           
Aadd(aProcSHST,{"VII" ,"V25H","C239","999","C","</FIM>"})             
Aadd(aProcSHST,{"VII" ,"M25I","C240","000","C","25I"})
aCAgBio:=oGetABio:aCols
For nCont:=1 To Len(aCAgBio)   
	If !Empty(aCAgBio[nCont][1]).And.!(aCAgBio[nCont][8])
		Aadd(aProcSHST,{"VII" ,"M25I","C241",StrZero(nCont,3),"C",aCAgBio[nCont][1]+Space(100-Len(aCAgBio[nCont][1]))})
		Aadd(aProcSHST,{"VII" ,"M25I","C242",StrZero(nCont,3),"N",aCAgBio[nCont][2]})
		Aadd(aProcSHST,{"VII" ,"M25I","C243",StrZero(nCont,3),"N",aCAgBio[nCont][3]})
		Aadd(aProcSHST,{"VII" ,"M25I","C244",StrZero(nCont,3),"N",aCAgBio[nCont][4]})
		Aadd(aProcSHST,{"VII" ,"M25I","C245",StrZero(nCont,3),"C",aCAgBio[nCont][5]})
		Aadd(aProcSHST,{"VII" ,"M25I","C246",StrZero(nCont,3),"N",aCAgBio[nCont][6]})
		Aadd(aProcSHST,{"VII" ,"M25I","C247",StrZero(nCont,3),"C",aCAgBio[nCont][7]})								
	Else
		Aadd(aDelSHST,{"VII" ,"M25I","C241",StrZero(nCont,3),"C",aCAgBio[nCont][1]+Space(100-Len(aCAgBio[nCont][1]))})
		Aadd(aDelSHST,{"VII" ,"M25I","C242",StrZero(nCont,3),"N",aCAgBio[nCont][2]})
		Aadd(aDelSHST,{"VII" ,"M25I","C243",StrZero(nCont,3),"N",aCAgBio[nCont][3]})
		Aadd(aDelSHST,{"VII" ,"M25I","C244",StrZero(nCont,3),"N",aCAgBio[nCont][4]})
		Aadd(aDelSHST,{"VII" ,"M25I","C245",StrZero(nCont,3),"C",aCAgBio[nCont][5]})
		Aadd(aDelSHST,{"VII" ,"M25I","C246",StrZero(nCont,3),"N",aCAgBio[nCont][6]})
		Aadd(aDelSHST,{"VII" ,"M25I","C247",StrZero(nCont,3),"C",aCAgBio[nCont][7]})								
	Endif
Next                                                 
Aadd(aProcSHST,{"VII" ,"V25J","C248","000","C","25J<INI>"})             
If Len(Alltrim(aSHST[169]))>100
	Aadd(aProcSHST,{"VII"  ,"V25J","C248","001","C",Substr(Alltrim(aSHST[169]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25J","C248","002","C",Substr(Alltrim(aSHST[169]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25J","C248","001","C",Alltrim(aSHST[169])})
Endif	                    
Aadd(aProcSHST,{"VII" ,"V25J","C248","999","C","</FIM>"})             
Aadd(aProcSHST,{"VII" ,"V25K","C249","000","C","25K<INI>"})             
If Len(Alltrim(aSHST[170]))>100
	Aadd(aProcSHST,{"VII"  ,"V25K","C249","001","C",Substr(Alltrim(aSHST[170]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25K","C249","002","C",Substr(Alltrim(aSHST[170]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"VII"  ,"V25K","C249","001","C",Alltrim(aSHST[170])})
Endif                              
Aadd(aProcSHST,{"VII" ,"V25K","C249","999","C","</FIM>"})             
Aadd(aProcSHST,{"VII" ,"V25L","C250","000","C","25L<INI>"})             
If Len(Alltrim(aSHST[171]))>100
	Aadd(aProcSHST,{"VII"  ,"V25L","C250","001","C",Substr(Alltrim(aSHST[171]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25L","C250","002","C",Substr(Alltrim(aSHST[171]),101,100)})		
Else                                  
	Aadd(aProcSHST,{"VII"  ,"V25L","C250","001","C",Alltrim(aSHST[171])})
Endif	                           
Aadd(aProcSHST,{"VII" ,"V25L","C250","999","C","</FIM>"})                        
//===============================================================================
//Capitulo VII -  Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho  
//Parte 3- Interv.caract.locais de trab. e práticas de trabalho
//===============================================================================
Aadd(aProcSHST,{"VII" ,"D25M","C251","001","C","25M"})
Aadd(aProcSHST,{"VII" ,"D25M","C252","001","N",Substr(aSHST[172],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C253","001","N",Substr(aSHST[173],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C254","001","N",Substr(aSHST[174],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C255","001","N",Substr(aSHST[175],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C256","001","N",Substr(aSHST[176],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C257","001","N",Substr(aSHST[177],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C258","001","N",Substr(aSHST[178],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C259","001","N",Substr(aSHST[179],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C260","001","N",Substr(aSHST[180],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C261","001","N",Substr(aSHST[181],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C262","001","N",Substr(aSHST[182],1,1)})
Aadd(aProcSHST,{"VII" ,"D25M","C263","001","C",aSHST[183]})
Aadd(aProcSHST,{"VII" ,"D25M","C264","001","N",Substr(aSHST[184],1,1)})
//===============================================================================
//Capitulo VII -  Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho  
//Parte 4 - Interv.Caract. dos locais de trab. e prát. de trabalho 
//===============================================================================
Aadd(aProcSHST,{"VII" ,"D25N","C265","001","C","25N"})
Aadd(aProcSHST,{"VII" ,"D25N","C266","001","N",aSHST[185]})
Aadd(aProcSHST,{"VII" ,"D25N","C267","001","N",aSHST[186]})
Aadd(aProcSHST,{"VII" ,"D25N","C268","001","N",aSHST[187]})
Aadd(aProcSHST,{"VII" ,"D25N","C269","001","N",aSHST[188]})
Aadd(aProcSHST,{"VII" ,"D25N","C270","001","N",aSHST[189]})
Aadd(aProcSHST,{"VII" ,"D25N","C271","001","N",aSHST[190]})
Aadd(aProcSHST,{"VII" ,"D25N","C272","001","N",aSHST[191]})
Aadd(aProcSHST,{"VII" ,"D25N","C273","001","N",aSHST[192]})
Aadd(aProcSHST,{"VII" ,"D25N","C274","001","N",aSHST[193]})
Aadd(aProcSHST,{"VII" ,"D25N","C275","001","N",aSHST[194]})
Aadd(aProcSHST,{"VII" ,"D25N","C276","001","N",aSHST[195]})
Aadd(aProcSHST,{"VII" ,"D25N","C277","001","N",aSHST[196]})
Aadd(aProcSHST,{"VII" ,"D25N","C278","001","N",aSHST[197]})
Aadd(aProcSHST,{"VII" ,"D25N","C279","001","N",aSHST[198]})
Aadd(aProcSHST,{"VII" ,"D25N","C280","001","N",aSHST[199]})
Aadd(aProcSHST,{"VII" ,"D25N","C281","001","N",aSHST[200]})
Aadd(aProcSHST,{"VII" ,"D25N","C282","001","N",aSHST[201]})
Aadd(aProcSHST,{"VII" ,"D25N","C283","001","N",aSHST[202]})
Aadd(aProcSHST,{"VII" ,"D25N","C284","001","N",aSHST[203]})
Aadd(aProcSHST,{"VII" ,"D25N","C285","001","N",aSHST[204]})
Aadd(aProcSHST,{"VII" ,"D25N","C286","001","N",aSHST[205]})
Aadd(aProcSHST,{"VII" ,"D25N","C287","001","N",aSHST[206]})
Aadd(aProcSHST,{"VII" ,"D25N","C288","001","C",aSHST[209]})
Aadd(aProcSHST,{"VII" ,"D25N","C289","001","N",aSHST[207]})
Aadd(aProcSHST,{"VII" ,"D25N","C290","001","N",aSHST[208]})   
Aadd(aProcSHST,{"VII" ,"D25N","C291","001","N",aSHST[210]})
Aadd(aProcSHST,{"VII" ,"D25N","C292","001","N",aSHST[211]})
Aadd(aProcSHST,{"VII" ,"D25N","C293","001","N",aSHST[212]})
Aadd(aProcSHST,{"VII" ,"D25N","C294","001","N",aSHST[213]})
Aadd(aProcSHST,{"VII" ,"D25N","C295","001","N",aSHST[214]})
Aadd(aProcSHST,{"VII" ,"D25N","C296","001","N",aSHST[215]})
Aadd(aProcSHST,{"VII" ,"D25N","C297","001","N",aSHST[216]})
Aadd(aProcSHST,{"VII" ,"D25N","C298","001","N",aSHST[217]})
Aadd(aProcSHST,{"VII" ,"D25N","C299","001","N",aSHST[218]})
Aadd(aProcSHST,{"VII" ,"D25N","C300","001","N",aSHST[219]})
Aadd(aProcSHST,{"VII" ,"D25N","C301","001","N",aSHST[220]})
Aadd(aProcSHST,{"VII" ,"D25N","C302","001","N",aSHST[221]})
Aadd(aProcSHST,{"VII" ,"D25N","C303","001","N",aSHST[222]})
Aadd(aProcSHST,{"VII" ,"D25N","C304","001","N",aSHST[223]})
Aadd(aProcSHST,{"VII" ,"D25N","C305","001","N",aSHST[224]})
Aadd(aProcSHST,{"VII" ,"D25N","C306","001","N",aSHST[225]})
//Aadd(aProcSHST,{"VII" ,"D25N","C307","001","N",aSHST[226]})//No documento nao comtempla na intervencao na pratica do trabalho o tipo homem do item 10
Aadd(aProcSHST,{"VII" ,"D25N","C308","001","N",aSHST[227]})
Aadd(aProcSHST,{"VII" ,"D25N","C309","001","N",aSHST[228]})
Aadd(aProcSHST,{"VII" ,"D25N","C310","001","N",aSHST[229]})
Aadd(aProcSHST,{"VII" ,"D25N","C311","001","C",aSHST[232]})
Aadd(aProcSHST,{"VII" ,"D25N","C312","001","N",aSHST[230]})
Aadd(aProcSHST,{"VII" ,"D25N","C313","001","N",aSHST[231]})
Aadd(aProcSHST,{"VII" ,"D25N","C314","001","N",aSHST[233]})
Aadd(aProcSHST,{"VII" ,"D25N","C315","001","N",aSHST[234]})
Aadd(aProcSHST,{"VII" ,"D25N","C316","001","N",aSHST[235]})
Aadd(aProcSHST,{"VII" ,"D25N","C317","001","N",aSHST[236]})
Aadd(aProcSHST,{"VII" ,"D25N","C318","001","N",aSHST[237]})
Aadd(aProcSHST,{"VII" ,"D25N","C319","001","N",aSHST[238]})
Aadd(aProcSHST,{"VII" ,"D25N","C320","001","C",aSHST[241]})
Aadd(aProcSHST,{"VII" ,"D25N","C321","001","N",aSHST[239]})
Aadd(aProcSHST,{"VII" ,"D25N","C322","001","N",aSHST[240]})
//===============================================================================
//Capitulo VII -  Ativ. desenv. nos Dominios da Segurança e Higiene no Trabalho  
//Parte 5 - Medidas de proteção coletiva de protecção individual
//===============================================================================
Aadd(aProcSHST,{"VII" ,"D25O","C323","001","C","25O"})
Aadd(aProcSHST,{"VII" ,"D25O","C324","001","N",aSHST[242]})
Aadd(aProcSHST,{"VII" ,"D25O","C325","001","N",aSHST[243]})
Aadd(aProcSHST,{"VII" ,"D25O","C326","001","N",aSHST[244]})
Aadd(aProcSHST,{"VII" ,"D25O","C327","001","N",aSHST[245]})
Aadd(aProcSHST,{"VII" ,"D25O","C328","001","N",aSHST[246]})
Aadd(aProcSHST,{"VII" ,"D25O","C329","001","N",aSHST[247]})
Aadd(aProcSHST,{"VII" ,"D25O","C330","001","N",aSHST[248]})
Aadd(aProcSHST,{"VII" ,"D25O","C331","001","N",aSHST[249]})
Aadd(aProcSHST,{"VII" ,"D25O","C332","001","N",aSHST[250]})
Aadd(aProcSHST,{"VII" ,"D25O","C333","001","N",aSHST[251]})
Aadd(aProcSHST,{"VII" ,"D25O","C334","001","N",aSHST[252]})
Aadd(aProcSHST,{"VII" ,"D25O","C335","001","N",aSHST[253]})
Aadd(aProcSHST,{"VII" ,"D25O","C336","001","N",aSHST[254]})
Aadd(aProcSHST,{"VII" ,"D25O","C337","001","N",aSHST[255]})
Aadd(aProcSHST,{"VII" ,"D25O","C338","001","N",aSHST[256]})
Aadd(aProcSHST,{"VII" ,"D25O","C339","001","N",aSHST[257]})
Aadd(aProcSHST,{"VII" ,"D25O","C340","001","C",aSHST[260]})
Aadd(aProcSHST,{"VII" ,"D25O","C341","001","N",aSHST[258]})
Aadd(aProcSHST,{"VII" ,"D25O","C342","001","N",aSHST[259]})
Aadd(aProcSHST,{"VII" ,"D25O","C343","001","N",aSHST[262]})
Aadd(aProcSHST,{"VII" ,"D25O","C344","001","N",aSHST[263]})
Aadd(aProcSHST,{"VII" ,"D25O","C345","001","N",aSHST[264]})
Aadd(aProcSHST,{"VII" ,"D25O","C346","001","N",aSHST[265]})
Aadd(aProcSHST,{"VII" ,"D25O","C347","001","N",aSHST[266]})
Aadd(aProcSHST,{"VII" ,"D25O","C348","001","N",aSHST[267]})
Aadd(aProcSHST,{"VII" ,"D25O","C349","001","N",aSHST[268]})
Aadd(aProcSHST,{"VII" ,"D25O","C350","001","N",aSHST[269]})
Aadd(aProcSHST,{"VII" ,"D25O","C351","001","N",aSHST[270]})
Aadd(aProcSHST,{"VII" ,"D25O","C352","001","N",aSHST[271]})
Aadd(aProcSHST,{"VII" ,"D25O","C353","001","N",aSHST[272]})
Aadd(aProcSHST,{"VII" ,"D25O","C354","001","N",aSHST[273]})
Aadd(aProcSHST,{"VII" ,"D25O","C355","001","N",aSHST[274]})
Aadd(aProcSHST,{"VII" ,"D25O","C356","001","N",aSHST[275]})
Aadd(aProcSHST,{"VII" ,"D25O","C357","001","N",aSHST[276]})
Aadd(aProcSHST,{"VII" ,"D25O","C358","001","N",aSHST[277]})
Aadd(aProcSHST,{"VII" ,"D25O","C359","001","N",aSHST[278]})
Aadd(aProcSHST,{"VII" ,"D25O","C360","001","N",aSHST[279]})
Aadd(aProcSHST,{"VII" ,"D25O","C361","001","N",aSHST[280]})
Aadd(aProcSHST,{"VII" ,"D25O","C362","001","N",aSHST[281]})
Aadd(aProcSHST,{"VII" ,"D25O","C363","001","N",aSHST[282]})
Aadd(aProcSHST,{"VII" ,"D25O","C364","001","N",aSHST[283]})
Aadd(aProcSHST,{"VII" ,"D25O","C365","001","N",aSHST[284]})
Aadd(aProcSHST,{"VII" ,"D25O","C366","001","N",aSHST[285]})
Aadd(aProcSHST,{"VII" ,"D25O","C367","001","N",aSHST[286]})
Aadd(aProcSHST,{"VII" ,"D25O","C368","001","N",aSHST[287]})
Aadd(aProcSHST,{"VII" ,"D25O","C369","001","N",aSHST[288]})
Aadd(aProcSHST,{"VII" ,"D25O","C370","001","N",aSHST[289]})
Aadd(aProcSHST,{"VII" ,"D25O","C371","001","C",aSHST[292]})
Aadd(aProcSHST,{"VII" ,"D25O","C372","001","N",aSHST[290]})
Aadd(aProcSHST,{"VII" ,"D25O","C373","001","N",aSHST[291]})

Aadd(aProcSHST,{"VII" ,"D25O","C374","001","N",Substr(aSHST[294],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C375","001","N",Substr(aSHST[295],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C376","001","N",Substr(aSHST[296],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C377","001","N",Substr(aSHST[297],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C378","001","N",Substr(aSHST[298],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C379","001","N",Substr(aSHST[299],1,1)})
Aadd(aProcSHST,{"VII" ,"D25O","C380","001","C",aSHST[301]})
Aadd(aProcSHST,{"VII" ,"D25O","C381","001","N",Substr(aSHST[300],1,1)})

Aadd(aProcSHST,{"VII" ,"V25P","C382","000","C","25P<INI>"})             
If Len(Alltrim(aSHST[261]))>100
	Aadd(aProcSHST,{"VII"  ,"V25P","C382","001","C",Substr(Alltrim(aSHST[261]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25P","C382","002","C",Substr(Alltrim(aSHST[261]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"VII"  ,"V25P","C382","001","C",Alltrim(aSHST[261])})
Endif                     
Aadd(aProcSHST,{"VII" ,"V25P","C382","999","C","</FIM>"})             
Aadd(aProcSHST,{"VII" ,"V25Q","C383","000","C","25Q<INI>"})             
If Len(Alltrim(aSHST[293]))>100
	Aadd(aProcSHST,{"VII"  ,"V25Q","C383","001","C",Substr(Alltrim(aSHST[293]),1,100)})
	Aadd(aProcSHST,{"VII"  ,"V25Q","C383","002","C",Substr(Alltrim(aSHST[293]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"VII"  ,"V25Q","C383","001","C",Alltrim(aSHST[293])})
Endif                                                                                        
Aadd(aProcSHST,{"VII" ,"V25Q","C383","999","C","</FIM>"})             
//===============================================================================
//Capitulo VIII - Atividade desenvolvida no Âmbito da Saude no Trabalho		
//Parte 1 - Desenvolvidas
//===============================================================================
Aadd(aProcSHST,{"VIII","D260","C384","001","C","260"})
Aadd(aProcSHST,{"VIII","D260","C385","001","N",aSHST[302]})
Aadd(aProcSHST,{"VIII","D260","C386","001","N",aSHST[303]})
Aadd(aProcSHST,{"VIII","D260","C387","001","N",aSHST[304]})
Aadd(aProcSHST,{"VIII","D260","C388","001","N",aSHST[305]})
Aadd(aProcSHST,{"VIII","D260","C389","001","N",aSHST[306]})
Aadd(aProcSHST,{"VIII","D260","C390","001","N",aSHST[307]})
Aadd(aProcSHST,{"VIII","D260","C391","001","N",aSHST[308]})   
Aadd(aProcSHST,{"VIII","D260","C392","001","N",aSHST[309]})
Aadd(aProcSHST,{"VIII","D260","C393","001","N",aSHST[310]})
Aadd(aProcSHST,{"VIII","D260","C394","001","N",aSHST[311]})
Aadd(aProcSHST,{"VIII","D260","C395","001","N",aSHST[312]})
Aadd(aProcSHST,{"VIII","D260","C396","001","N",aSHST[313]})
Aadd(aProcSHST,{"VIII","D260","C397","001","N",aSHST[314]})
Aadd(aProcSHST,{"VIII","D260","C398","001","N",aSHST[315]})
Aadd(aProcSHST,{"VIII","D260","C399","001","N",aSHST[316]})
Aadd(aProcSHST,{"VIII","D260","C400","001","N",aSHST[317]})
Aadd(aProcSHST,{"VIII","D260","C401","001","N",aSHST[318]})
Aadd(aProcSHST,{"VIII","D260","C402","001","N",aSHST[319]})
Aadd(aProcSHST,{"VIII","D260","C403","001","N",aSHST[320]})
Aadd(aProcSHST,{"VIII","D260","C404","001","N",aSHST[321]})
Aadd(aProcSHST,{"VIII","D260","C405","001","N",aSHST[322]})
Aadd(aProcSHST,{"VIII","D260","C406","001","N",aSHST[323]})
Aadd(aProcSHST,{"VIII","D260","C407","001","N",aSHST[324]})
Aadd(aProcSHST,{"VIII","D260","C408","001","N",aSHST[325]})
Aadd(aProcSHST,{"VIII","D260","C409","001","N",aSHST[326]})
Aadd(aProcSHST,{"VIII","D260","C410","001","N",aSHST[327]})
Aadd(aProcSHST,{"VIII","D260","C411","001","N",aSHST[328]})
Aadd(aProcSHST,{"VIII","D260","C412","001","N",aSHST[329]})
Aadd(aProcSHST,{"VIII","D260","C413","001","N",aSHST[330]})
Aadd(aProcSHST,{"VIII","D260","C414","001","N",aSHST[331]})
Aadd(aProcSHST,{"VIII","D260","C415","001","N",aSHST[332]})
Aadd(aProcSHST,{"VIII","D260","C416","001","N",aSHST[333]})
Aadd(aProcSHST,{"VIII","D260","C417","001","N",aSHST[334]})
Aadd(aProcSHST,{"VIII","D260","C418","001","N",aSHST[335]})
Aadd(aProcSHST,{"VIII","D260","C419","001","N",aSHST[336]})
Aadd(aProcSHST,{"VIII","D260","C420","001","N",aSHST[337]})
Aadd(aProcSHST,{"VIII","D260","C421","001","N",aSHST[338]})
Aadd(aProcSHST,{"VIII","D260","C422","001","N",aSHST[339]})
Aadd(aProcSHST,{"VIII","D260","C423","001","N",aSHST[340]})
Aadd(aProcSHST,{"VIII","D260","C424","001","N",aSHST[341]})
Aadd(aProcSHST,{"VIII","D260","C425","001","N",aSHST[342]})
Aadd(aProcSHST,{"VIII","D260","C426","001","N",aSHST[343]})
Aadd(aProcSHST,{"VIII","D260","C427","001","N",aSHST[344]})
Aadd(aProcSHST,{"VIII","D260","C428","001","N",aSHST[345]})
Aadd(aProcSHST,{"VIII","D260","C429","001","N",aSHST[346]})
Aadd(aProcSHST,{"VIII","D260","C430","001","N",aSHST[347]})
Aadd(aProcSHST,{"VIII","D260","C431","001","N",aSHST[348]})
Aadd(aProcSHST,{"VIII","D260","C432","001","N",aSHST[349]})
Aadd(aProcSHST,{"VIII","D260","C433","001","N",aSHST[350]})
Aadd(aProcSHST,{"VIII","D260","C434","001","N",aSHST[351]})
Aadd(aProcSHST,{"VIII","D260","C435","001","N",aSHST[352]})
Aadd(aProcSHST,{"VIII","D260","C436","001","N",aSHST[353]})
Aadd(aProcSHST,{"VIII","D260","C437","001","N",aSHST[354]})
Aadd(aProcSHST,{"VIII","D260","C438","001","N",aSHST[355]})
Aadd(aProcSHST,{"VIII","D260","C439","001","N",aSHST[356]})
Aadd(aProcSHST,{"VIII","D260","C440","001","N",aSHST[357]})
Aadd(aProcSHST,{"VIII","D260","C441","001","N",aSHST[358]})
Aadd(aProcSHST,{"VIII","D260","C442","001","N",aSHST[359]})
Aadd(aProcSHST,{"VIII","D260","C443","001","N",aSHST[360]})
Aadd(aProcSHST,{"VIII","D260","C444","001","N",aSHST[361]})
Aadd(aProcSHST,{"VIII","D260","C445","001","N",aSHST[362]})
Aadd(aProcSHST,{"VIII","D260","C446","001","N",aSHST[363]})
Aadd(aProcSHST,{"VIII","D260","C447","001","N",aSHST[364]})
Aadd(aProcSHST,{"VIII","D260","C448","001","N",aSHST[365]})
Aadd(aProcSHST,{"VIII","D260","C449","001","N",aSHST[366]})
Aadd(aProcSHST,{"VIII","D260","C450","001","N",aSHST[367]})
Aadd(aProcSHST,{"VIII","D261","C462","001","C","261"})
Aadd(aProcSHST,{"VIII","D261","C452","001","N",aSHST[368]})
Aadd(aProcSHST,{"VIII","D261","C453","001","N",aSHST[369]})
Aadd(aProcSHST,{"VIII","D261","C454","001","N",aSHST[370]})
Aadd(aProcSHST,{"VIII","D261","C455","001","N",aSHST[371]})
Aadd(aProcSHST,{"VIII","D261","C456","001","N",aSHST[372]})
Aadd(aProcSHST,{"VIII","D261","C457","001","N",aSHST[373]})
Aadd(aProcSHST,{"VIII","D261","C458","001","N",aSHST[374]})
Aadd(aProcSHST,{"VIII","D261","C459","001","N",aSHST[375]})
Aadd(aProcSHST,{"VIII","D261","C460","001","N",aSHST[376]})
Aadd(aProcSHST,{"VIII","D261","C461","001","N",aSHST[377]})
Aadd(aProcSHST,{"VIII","M262","C462","000","C","262"})
aCAcoImu:=oGetAI:aCols

For nCont:=1 To Len(aCAcoImu)   
	If !Empty(aCAcoImu[nCont][1]).And.!(aCAcoImu[nCont][5])
		Aadd(aProcSHST,{"VIII" ,"M262","C463",StrZero(nCont,3),"C",aCAcoImu[nCont][1]+Space(100-Len(aCAcoImu[nCont][1]))})
		Aadd(aProcSHST,{"VIII" ,"M262","C464",StrZero(nCont,3),"N",aCAcoImu[nCont][2]})
		Aadd(aProcSHST,{"VIII" ,"M262","C465",StrZero(nCont,3),"N",aCAcoImu[nCont][3]})
		Aadd(aProcSHST,{"VIII" ,"M262","C466",StrZero(nCont,3),"N",aCAcoImu[nCont][4]})								
	Else 
		Aadd(aDelSHST,{"VIII" ,"M262","C463",StrZero(nCont,3),"C",aCAcoImu[nCont][1]+Space(10-Len(aCAcoImu[nCont][1]))})
		Aadd(aDelSHST,{"VIII" ,"M262","C464",StrZero(nCont,3),"N",aCAcoImu[nCont][2]})
		Aadd(aDelSHST,{"VIII" ,"M262","C465",StrZero(nCont,3),"N",aCAcoImu[nCont][3]})
		Aadd(aDelSHST,{"VIII" ,"M262","C466",StrZero(nCont,3),"N",aCAcoImu[nCont][4]})	
	Endif
Next                                                 
//===============================================================================
//Capitulo VIII - Atividade desenvolvida no Âmbito da Saude no Trabalho		
//Parte 2 - Promocao da Saude
//===============================================================================      
Aadd(aProcSHST,{"VIII" ,"V263","C467","000","C","263<INI>"})             
If Len(Alltrim(aSHST[378]))>100
	Aadd(aProcSHST,{"VIII"  ,"V263","C467","001","C",Substr(Alltrim(aSHST[378]),1,100)})
	Aadd(aProcSHST,{"VIII"  ,"V263","C467","002","C",Substr(Alltrim(aSHST[378]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"VIII"  ,"V263","C467","001","C",Alltrim(aSHST[378])})
Endif                                                                 
Aadd(aProcSHST,{"VIII" ,"V263","C467","999","C","</FIM>"})             
Aadd(aProcSHST,{"VIII","D264","C468","001","C","264"})
Aadd(aProcSHST,{"VIII","D264","C469","001","N",aSHST[379]})
Aadd(aProcSHST,{"VIII","D264","C470","001","N",aSHST[380]})
Aadd(aProcSHST,{"VIII","D264","C471","001","N",aSHST[381]})

Aadd(aProcSHST,{"VIII" ,"V265","C472","000","C","265<INI>"})             
If Len(Alltrim(aSHST[382]))>100
	Aadd(aProcSHST,{"VIII"  ,"V265","C472","001","C",Substr(Alltrim(aSHST[382]),1,100)})
	Aadd(aProcSHST,{"VIII"  ,"V265","C472","002","C",Substr(Alltrim(aSHST[382]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"VIII"  ,"V265","C472","001","C",Alltrim(aSHST[382])})
Endif                                                                 
Aadd(aProcSHST,{"VIII" ,"V265","C472","999","C","</FIM>"})             
//===============================================================================
//Capitulo - IX-Acidentes de Trabalho e Doenças Profissionais 				 
//===============================================================================
Aadd(aProcSHST,{"IX","D270","C473","001","C","270"})
Aadd(aProcSHST,{"IX","D270","C474","001","N",aSHST[383]})
Aadd(aProcSHST,{"IX","D270","C475","001","N",aSHST[384]})
Aadd(aProcSHST,{"IX","D270","C476","001","N",aSHST[385]})
Aadd(aProcSHST,{"IX","D270","C477","001","N",aSHST[386]})
Aadd(aProcSHST,{"IX","D270","C478","001","N",aSHST[387]})
Aadd(aProcSHST,{"IX","D270","C479","001","N",aSHST[388]})
Aadd(aProcSHST,{"IX","D270","C480","001","N",aSHST[389]})   
Aadd(aProcSHST,{"IX","D270","C481","001","N",aSHST[390]})
Aadd(aProcSHST,{"IX","D270","C482","001","N",aSHST[391]})
Aadd(aProcSHST,{"IX","D270","C483","001","N",aSHST[392]})

Aadd(aProcSHST,{"IX","D270","C484","001","N",aSHST[393]})
Aadd(aProcSHST,{"IX","D270","C485","001","N",aSHST[394]})
Aadd(aProcSHST,{"IX","D270","C486","001","N",aSHST[395]})
Aadd(aProcSHST,{"IX","D270","C487","001","N",aSHST[396]})
Aadd(aProcSHST,{"IX","D270","C488","001","N",aSHST[397]})
Aadd(aProcSHST,{"IX","D270","C489","001","N",aSHST[398]})

Aadd(aProcSHST,{"IX","D270","C490","001","N",aSHST[399]})   
Aadd(aProcSHST,{"IX","D270","C491","001","N",aSHST[400]})
Aadd(aProcSHST,{"IX","D270","C492","001","N",aSHST[401]})
Aadd(aProcSHST,{"IX","D270","C493","001","N",aSHST[402]})
Aadd(aProcSHST,{"IX","D270","C494","001","N",aSHST[403]})
Aadd(aProcSHST,{"IX","D270","C495","001","N",aSHST[404]})
Aadd(aProcSHST,{"IX","D270","C496","001","N",aSHST[405]})
Aadd(aProcSHST,{"IX","D270","C497","001","N",aSHST[406]})
Aadd(aProcSHST,{"IX","D270","C498","001","N",aSHST[407]})
Aadd(aProcSHST,{"IX","D270","C499","001","N",aSHST[408]})

Aadd(aProcSHST,{"IX","D270","C500","001","N",aSHST[409]})
Aadd(aProcSHST,{"IX","D270","C501","001","N",aSHST[410]})
Aadd(aProcSHST,{"IX","D270","C502","001","N",aSHST[411]})
Aadd(aProcSHST,{"IX","D270","C503","001","N",aSHST[412]})
Aadd(aProcSHST,{"IX","D270","C504","001","N",aSHST[413]})
Aadd(aProcSHST,{"IX","D270","C505","001","N",aSHST[414]})

Aadd(aProcSHST,{"IX","D270","C506","001","N",aSHST[415]})   
Aadd(aProcSHST,{"IX","D270","C507","001","N",aSHST[416]})
Aadd(aProcSHST,{"IX","D270","C508","001","N",aSHST[417]})
Aadd(aProcSHST,{"IX","D270","C509","001","N",aSHST[418]})
Aadd(aProcSHST,{"IX","D270","C510","001","N",aSHST[419]})
Aadd(aProcSHST,{"IX","D270","C511","001","N",aSHST[420]})
Aadd(aProcSHST,{"IX","D270","C512","001","N",aSHST[421]})
Aadd(aProcSHST,{"IX","D270","C513","001","N",aSHST[422]})
Aadd(aProcSHST,{"IX","D270","C514","001","N",aSHST[423]})
Aadd(aProcSHST,{"IX","D270","C515","001","N",aSHST[424]})
Aadd(aProcSHST,{"IX","D270","C516","001","N",aSHST[425]})
Aadd(aProcSHST,{"IX","D270","C517","001","N",aSHST[426]})
Aadd(aProcSHST,{"IX","D270","C518","001","N",aSHST[427]})
Aadd(aProcSHST,{"IX","D270","C519","001","N",aSHST[428]})
Aadd(aProcSHST,{"IX","D270","C520","001","N",aSHST[429]})
Aadd(aProcSHST,{"IX","D270","C521","001","N",aSHST[430]})

Aadd(aProcSHST,{"IX","D271","C522","001","C","271"})
Aadd(aProcSHST,{"IX","D271","C523","001","N",aSHST[431]})
Aadd(aProcSHST,{"IX","D271","C524","001","N",aSHST[432]})
Aadd(aProcSHST,{"IX","D271","C525","001","N",aSHST[433]})
Aadd(aProcSHST,{"IX","D271","C526","001","N",aSHST[434]})
Aadd(aProcSHST,{"IX","D271","C527","001","N",aSHST[435]})
Aadd(aProcSHST,{"IX","D271","C528","001","N",aSHST[436]})
Aadd(aProcSHST,{"IX","D271","C529","001","N",aSHST[437]})
Aadd(aProcSHST,{"IX","D271","C530","001","N",aSHST[438]})
Aadd(aProcSHST,{"IX","D271","C531","001","N",aSHST[439]})
Aadd(aProcSHST,{"IX","D271","C532","001","N",aSHST[440]})
Aadd(aProcSHST,{"IX","D271","C533","001","N",aSHST[441]})
Aadd(aProcSHST,{"IX","D271","C534","001","N",aSHST[442]})
Aadd(aProcSHST,{"IX","D271","C535","001","N",aSHST[443]})
Aadd(aProcSHST,{"IX","D271","C536","001","N",aSHST[444]})
Aadd(aProcSHST,{"IX","D271","C537","001","N",aSHST[445]})
Aadd(aProcSHST,{"IX","D271","C538","001","N",aSHST[446]})
Aadd(aProcSHST,{"IX","D271","C539","001","N",aSHST[447]})
Aadd(aProcSHST,{"IX","D271","C540","001","N",aSHST[448]})
Aadd(aProcSHST,{"IX","D271","C541","001","N",aSHST[449]})
Aadd(aProcSHST,{"IX","D271","C542","001","N",aSHST[450]})
Aadd(aProcSHST,{"IX","D271","C543","001","N",aSHST[451]})
Aadd(aProcSHST,{"IX","D271","C544","001","N",aSHST[452]})
Aadd(aProcSHST,{"IX","D271","C545","001","N",aSHST[453]})
Aadd(aProcSHST,{"IX","D271","C546","001","N",aSHST[454]})
Aadd(aProcSHST,{"IX","D271","C547","001","N",aSHST[455]})
Aadd(aProcSHST,{"IX","D271","C548","001","N",aSHST[456]})
Aadd(aProcSHST,{"IX","V272","C549","000","C","272<INI>"})             
If Len(Alltrim(aSHST[457]))>100
	Aadd(aProcSHST,{"IX"  ,"V272","C549","001","C",Substr(Alltrim(aSHST[457]),1,100)})
	Aadd(aProcSHST,{"IX"  ,"V272","C549","002","C",Substr(Alltrim(aSHST[457]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"IX"  ,"V272","C549","001","C",Alltrim(aSHST[457])})
Endif                                                      
Aadd(aProcSHST,{"IX" ,"V272","C549","999","C","</FIM>"})             
Aadd(aProcSHST,{"IX","M273","C550","000","C","273"})

aCCodDoe:=oGetCD:aCols
For nCont:=1 To Len(aCCodDoe)   
	If !Empty(aCCodDoe[nCont][1]).And.!(aCCodDoe[nCont][7])
			Aadd(aProcSHST,{"IX" ,"M273","C551",StrZero(nCont,3),"N",aCCodDoe[nCont][1]})
			Aadd(aProcSHST,{"IX" ,"M273","C552",StrZero(nCont,3),"C",aCCodDoe[nCont][2]+Space(100-Len(aCCodDoe[nCont][2]))})
			Aadd(aProcSHST,{"IX" ,"M273","C553",StrZero(nCont,3),"N",aCCodDoe[nCont][3]})
			Aadd(aProcSHST,{"IX" ,"M273","C554",StrZero(nCont,3),"N",aCCodDoe[nCont][4]})
			Aadd(aProcSHST,{"IX" ,"M273","C555",StrZero(nCont,3),"N",aCCodDoe[nCont][5]})
			Aadd(aProcSHST,{"IX" ,"M273","C556",StrZero(nCont,3),"N",aCCodDoe[nCont][6]})
	Else
			Aadd(aDelSHST,{"IX" ,"M273","C551",StrZero(nCont,3),"N",aCCodDoe[nCont][1]})
			Aadd(aDelSHST,{"IX" ,"M273","C552",StrZero(nCont,3),"C",aCCodDoe[nCont][2]+Space(100-Len(aCCodDoe[nCont][2]))})
			Aadd(aDelSHST,{"IX" ,"M273","C553",StrZero(nCont,3),"N",aCCodDoe[nCont][3]})
			Aadd(aDelSHST,{"IX" ,"M273","C554",StrZero(nCont,3),"N",aCCodDoe[nCont][4]})
			Aadd(aDelSHST,{"IX" ,"M273","C555",StrZero(nCont,3),"N",aCCodDoe[nCont][5]})
			Aadd(aDelSHST,{"IX" ,"M273","C556",StrZero(nCont,3),"N",aCCodDoe[nCont][6]})
	Endif
Next                                                 
Aadd(aProcSHST,{"IX" ,"V274","C557","000","C","274<INI>"})             
If Len(Alltrim(aSHST[458]))>100
	Aadd(aProcSHST,{"IX"  ,"V274","C557","001","C",Substr(Alltrim(aSHST[458]),1,100)})
	Aadd(aProcSHST,{"IX"  ,"V274","C557","002","C",Substr(Alltrim(aSHST[458]),101,100)})		
Else                                   
	Aadd(aProcSHST,{"IX"  ,"V274","C557","001","C",Alltrim(aSHST[458])})
Endif                                                      
Aadd(aProcSHST,{"IX" ,"V274","C557","999","C","</FIM>"})             
Aadd(aProcSHST,{"IX","F999","C558","001","C"," "})         

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³ProcSHST   ³ Autor ³ Marcos Kato	 		  		³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Armazena os dados no array						  				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaSHST(cParFilial,cParAnoBas)
Local nRGR:=0     
Local lGrava:=.F.
//=======================================================================
//Ordem do Array - Capitulo,Tipo Registro,Campo,Sequencia,Tipo e Conteudo   
//=======================================================================   

If len(aProcSHST)>0
	For nRGR:=1 To len(aProcSHST)
		lGrava:=.F.
		DbselectArea("RGR")
		RGR->(DbSetOrder(1))
		RGR->(DbgoTop())
		If DbSeek(cParFilial+cParAnoBas+aProcSHST[nRGR][3]+aProcSHST[nRGR][4])
			If ValType(aProcSHST[nRGR][6])=="N"
				If Alltrim(Str(aProcSHST[nRGR][6]))==Alltrim(RGR->RGR_DESCRI)
					lGrava:=.F.
				Else
					lGrava:=.T.
				Endif
			Else
				If Alltrim(aProcSHST[nRGR][6])==Alltrim(RGR->RGR_DESCRI)
					lGrava:=.F.
				Else
					lGrava:=.T.
				Endif
			Endif
			If lGrava
				RecLock("RGR",.F.)
				RGR->RGR_USRALT:=__cUserID
				RGR->RGR_DATALT:=dDataBase
			Endif
		Else
			lGrava:=.T.
			RecLock("RGR",.T.)
			RGR->RGR_USRGER:=__cUserID
			RGR->RGR_DATGER:=dDataBase
		Endif
		If lGrava
			RGR->RGR_FILIAL:=cParFilial
			RGR->RGR_ANOBAS:=cParAnoBas            
			RGR->RGR_TIPREG:=Substr(aProcSHST[nRGR][2],1,1)
			RGR->RGR_REGIST:=Substr(aProcSHST[nRGR][2],2,3)			
			RGR->RGR_CAMPO :=aProcSHST[nRGR][3]
			RGR->RGR_CAP   :=aProcSHST[nRGR][1]
			RGR->RGR_SEQ   :=aProcSHST[nRGR][4]
			RGR->RGR_TIPO  :=aProcSHST[nRGR][5]
			RGR->RGR_DESCRI:=Iif(ValType(aProcSHST[nRGR][6])=="N",Alltrim(Str(aProcSHST[nRGR][6])),Alltrim(aProcSHST[nRGR][6]))
			RGR->(MsUnlock())
		Endif
	Next
Endif      
//Conteudo dos array
If len(aDelSHST)>0
	For nRGR:=1 To len(aDelSHST)
		DbselectArea("RGR")
		RGR->(DbSetOrder(1))
		RGR->(DbgoTop())
		If DbSeek(cParFilial+cParAnoBas+aDelSHST[nRGR][3]+aDelSHST[nRGR][4])
			RecLock("RGR",.F.)
			RGR->RGR_USRDEL:=__cUserID
			RGR->RGR_DATDEL:=dDataBase
			DbDelete()
			RGR->(MsUnlock())	
		Endif	
    Next              
Endif    
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Program	 ³GeraSHST   ³ Autor ³ Marcos Kato	 		  		³ Data ³ 14.10.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta os dados do SHST 						  				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraSHST(cParFilial,cParAnoBas)
Local cSHST1 :=""	,cSHST2 :="",cTipReg :="",cSequencia :=""
Local cDesc1 :=""	,cDesc2 :="",cDesc3  :="",cDesc4     :="",cDesc5     :=""
Local nVal1  :=0 	,nVal2  :=0 ,nVal3   :=0 ,nVal4  	 :=0 ,nVal5  	 :=0

cSHST1:="SELECT RGR_CAP,RGR_CAMPO,RGR_SEQ,RGR_DESCRI "
cSHST1+="FROM "+RETSQLNAME("RGR")+" "
cSHST1+="WHERE RGR_DESCRI<>' ' "           
cSHST1+="AND RGR_FILIAL ='"+cParFilial+"' "
cSHST1+="AND RGR_ANOBAS ='"+cParAnoBas+"' "
cSHST1+="AND RGR_TIPREG<>'M'"
cSHST1+="AND RGR_SEQ NOT IN ('000','999') "
cSHST1+="AND D_E_L_E_T_='' "
cSHST1+="ORDER BY RGR_CAP,RGR_SEQ,RGR_CAMPO "

cSHST1:= ChangeQuery(cSHST1)

If Select("SHST")>0
	DbSelectArea("SHST")
	SHST->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSHST1),"SHST",.F.,.T.)

aSHST[68] :=""
aSHST[68] :=""
aSHST[83] :=""
aSHST[142]:=""
aSHST[143]:=""
aSHST[144]:=""
aSHST[160]:=""
aSHST[161]:=""
aSHST[162]:=""
aSHST[163]:=""
aSHST[164]:=""
aSHST[165]:=""
aSHST[166]:=""
aSHST[167]:=""
aSHST[168]:=""
aSHST[169]:=""
aSHST[170]:=""
aSHST[171]:=""
aSHST[261]:=""
aSHST[293]:=""
aSHST[378]:=""
aSHST[382]:=""
aSHST[457]:=""
aSHST[458]:=""

If SHST->(!Eof())
	If MsgNoYes(STR0368+cParAnobas+"."+STR0369,STR0370)//"Existe dados na Manutencao SHST do Ano "#"Deseja gerar um novo?"#"Atencao"	
		DbselectArea("RGR")
		RGR->(DbSetOrder(1))
		RGR->(DbgoTop())
		If DbSeek(cParFilial+cParAnoBas)
			Do While RGR->(!EOF()).And.RGR->RGR_FILIAL+RGR->RGR_ANOBAS==cParFilial+cParAnoBas
			RecLock("RGR",.F.)
			RGR->RGR_USRDEL:=__cUserID
			RGR->RGR_DATDEL:=dDataBase
			DbDelete()
			RGR->(MsUnlock())
			RGR->(DbSkip())
			End	
		Endif	
		Return()
	Else
	Do While SHST->(!EOF())
		If Alltrim(SHST->RGR_CAP)=="I"//Capitulo I
			If SHST->RGR_CAMPO=="C013"
				aSHST[1]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C014"
				aSHST[2]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C015"
				aSHST[3]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C016"
				aSHST[4]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C017"
				aSHST[5]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C018"
				aSHST[6]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C019"
				aSHST[7]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C020"
				aSHST[8]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C021"
				aSHST[9]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C022"
				aSHST[10]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C023"
				aSHST[11]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C024"
				aSHST[12]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C025"
				aSHST[13]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C026"
				aSHST[14]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C027"
				aSHST[15]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C028"
				aSHST[16]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C029"
				aSHST[17]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C030"
				aSHST[18]:=Val(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="II"//Capitulo II
			If SHST->RGR_CAMPO=="C032"
				aSHST[19]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C033"
				aSHST[20]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C034"
				aSHST[21]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C035"
				aSHST[22]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C036"
				aSHST[23]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C037"
				aSHST[24]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C038"
				aSHST[25]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C039"
				aSHST[26]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C040"
				aSHST[27]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C041"
				aSHST[28]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C042"
				aSHST[29]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C043"
				aSHST[30]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C044"
				aSHST[31]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C045"
				aSHST[32]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C046"
				aSHST[33]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C047"
				aSHST[34]:=Val(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="III"//Capitulo III
			If SHST->RGR_CAMPO=="C049"
				aSHST[35]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C050"
				aSHST[36]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C051"
				aSHST[37]:=SHST->RGR_DESCRI
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="IV"//Capitulo IV
			If SHST->RGR_CAMPO=="C053"
				aSHST[38]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C054"
				aSHST[39]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C055"
				aSHST[40]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C056"
				aSHST[41]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C057"
				aSHST[42]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C058"
				aSHST[43]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C067"
				aSHST[49]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C068"
				aSHST[44]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C069"
				aSHST[45]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C070"
				aSHST[46]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C071"
				aSHST[47]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C072"
				aSHST[48]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C073"
				aSHST[50]:=SHST->RGR_DESCRI
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="V"//Capitulo V
			If SHST->RGR_CAMPO=="C082"
				aSHST[51]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C083"
				aSHST[59]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C084"
				aSHST[52]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C085"
				aSHST[60]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C086"
				aSHST[53]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C087"
				aSHST[61]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C088"
				aSHST[54]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C089"
				aSHST[62]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C090"
				aSHST[55]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C091"
				aSHST[63]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C092"
				aSHST[56]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C093"
				aSHST[64]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C094"
				aSHST[57]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C095"
				aSHST[65]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C096"
				aSHST[58]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C097"
				aSHST[66]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C098"
				aSHST[67]:=Val(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="VI"//Capitulo VI
			If SHST->RGR_CAMPO=="C099"
				aSHST[68]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C101"
				aSHST[69]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C102"
				aSHST[70]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C103"
				aSHST[71]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C104"
				aSHST[72]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C105"
				aSHST[73]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C106"
				aSHST[74]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C107"
				aSHST[75]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C108"
				aSHST[76]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C109"
				aSHST[77]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C110"
				aSHST[78]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C111"
				aSHST[79]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C112"
				aSHST[80]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C113"
				aSHST[81]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C114"
				aSHST[82]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C115"
				aSHST[83]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C124"
				aSHST[84]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C125"
				aSHST[85]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C133"
				aSHST[86]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C134"
				aSHST[93]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C135"
				aSHST[100]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C136"
				aSHST[87]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C137"
				aSHST[94]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C138"
				aSHST[101]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C139"
				aSHST[88]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C140"
				aSHST[95]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C141"
				aSHST[102]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C142"
				aSHST[89]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C143"
				aSHST[96]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C144"
				aSHST[103]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C145"
				aSHST[90]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C146"
				aSHST[97]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C147"
				aSHST[104]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C148"
				aSHST[91]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C149"
				aSHST[98]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C150"
				aSHST[105]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C151"
				aSHST[92]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C152"
				aSHST[99]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C153"
				aSHST[106]:=Val(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="VII"//Capitulo VII
			If SHST->RGR_CAMPO=="C155"
				aSHST[107]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C156"
				aSHST[108]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C157"
				aSHST[109]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C158"
				aSHST[110]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C159"
				aSHST[111]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C160"
				aSHST[112]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C161"
				aSHST[113]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C162"
				aSHST[114]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C163"
				aSHST[115]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C164"
				aSHST[116]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C165"
				aSHST[117]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C166"
				aSHST[118]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C167"
				aSHST[119]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C168"
				aSHST[120]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C169"
				aSHST[121]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C170"
				aSHST[122]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C171"
				aSHST[123]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C172"
				aSHST[124]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C173"
				aSHST[125]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C174"
				aSHST[126]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C179"
				aSHST[127]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C180"
				aSHST[128]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C181"
				aSHST[129]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C182"
				aSHST[130]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C183"
				aSHST[131]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C184"
				aSHST[132]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C185"
				aSHST[133]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C186"
				aSHST[134]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C187"
				aSHST[135]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C188"
				aSHST[136]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C189"
				aSHST[137]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C190"
				aSHST[138]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C191"
				aSHST[141]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C192"
				aSHST[139]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C193"
				aSHST[140]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C194"
				aSHST[142]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C195"
				aSHST[143]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C196"
				aSHST[144]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C198"
				aSHST[145]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C199"
				aSHST[146]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C200"
				aSHST[147]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C201"
				aSHST[148]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C202"
				aSHST[149]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C203"
				aSHST[150]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C204"
				aSHST[151]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C205"
				aSHST[152]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C206"
				aSHST[153]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C207"
				aSHST[154]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C208"
				aSHST[155]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C209"
				aSHST[156]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C210"
				aSHST[157]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C211"
				aSHST[158]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C212"
				aSHST[159]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C213"
				aSHST[160]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C214"
				aSHST[161]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C215"
				aSHST[162]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C225"
				aSHST[163]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C226"
				aSHST[164]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C236"
				aSHST[165]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C237"
				aSHST[166]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C238"
				aSHST[167]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C239"
				aSHST[168]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C248"
				aSHST[169]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C249"
				aSHST[170]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C250"
				aSHST[171]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C252"
				aSHST[172]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C253"
				aSHST[173]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C254"
				aSHST[174]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C255"
				aSHST[175]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C256"
				aSHST[176]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C257"
				aSHST[177]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C258"
				aSHST[178]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C259"
				aSHST[179]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C260"
				aSHST[180]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C261"
				aSHST[181]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C262"
				aSHST[182]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C263"
				aSHST[183]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C264"
				aSHST[184]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C266"
				aSHST[185]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C267"
				aSHST[186]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C268"
				aSHST[187]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C269"
				aSHST[188]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C270"
				aSHST[189]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C271"
				aSHST[190]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C272"
				aSHST[191]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C273"
				aSHST[192]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C274"
				aSHST[193]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C275"
				aSHST[194]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C276"
				aSHST[195]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C277"
				aSHST[196]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C278"
				aSHST[197]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C279"
				aSHST[198]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C280"
				aSHST[199]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C281"
				aSHST[200]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C282"
				aSHST[201]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C283"
				aSHST[202]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C284"
				aSHST[203]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C285"
				aSHST[204]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C286"
				aSHST[205]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C287"
				aSHST[206]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C288"
				aSHST[209]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C289"
				aSHST[207]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C290"
				aSHST[208]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C291"
				aSHST[210]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C292"
				aSHST[211]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C293"
				aSHST[212]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C294"
				aSHST[213]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C295"
				aSHST[214]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C296"
				aSHST[215]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C297"
				aSHST[216]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C298"
				aSHST[217]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C299"
				aSHST[218]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C300"
				aSHST[219]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C301"
				aSHST[220]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C302"
				aSHST[221]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C303"
				aSHST[222]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C304"
				aSHST[223]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C305"
				aSHST[224]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C306"
				aSHST[225]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C307"
				aSHST[226]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C308"
				aSHST[227]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C309"
				aSHST[228]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C310"
				aSHST[229]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C311"
				aSHST[232]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C312"
				aSHST[230]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C313"
				aSHST[231]:=VaL(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C314"
				aSHST[233]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C315"
				aSHST[234]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C316"
				aSHST[235]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C317"
				aSHST[236]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C318"
				aSHST[237]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C319"
				aSHST[238]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C320"
				aSHST[241]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C321"
				aSHST[239]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C322"
				aSHST[240]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C324"
				aSHST[242]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C325"
				aSHST[243]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C326"
				aSHST[244]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C327"
				aSHST[245]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C328"
				aSHST[246]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C329"
				aSHST[247]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C330"
				aSHST[248]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C331"
				aSHST[249]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C332"
				aSHST[250]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C333"
				aSHST[251]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C334"
				aSHST[252]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C335"
				aSHST[253]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C336"
				aSHST[254]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C337"
				aSHST[255]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C338"
				aSHST[256]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C339"
				aSHST[257]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C340"
				aSHST[260]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C341"
				aSHST[258]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C342"
				aSHST[262]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C343"
				aSHST[262]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C344"
				aSHST[263]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C345"
				aSHST[264]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C346"
				aSHST[265]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C347"
				aSHST[266]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C348"
				aSHST[267]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C349"
				aSHST[268]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C350"
				aSHST[269]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C351"
				aSHST[270]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C352"
				aSHST[271]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C353"
				aSHST[272]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C354"
				aSHST[273]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C355"
				aSHST[274]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C356"
				aSHST[275]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C357"
				aSHST[276]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C358"
				aSHST[277]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C359"
				aSHST[278]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C360"
				aSHST[279]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C361"
				aSHST[280]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C362"
				aSHST[281]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C363"
				aSHST[282]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C364"
				aSHST[283]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C365"
				aSHST[284]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C366"
				aSHST[285]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C367"
				aSHST[286]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C368"
				aSHST[287]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C369"
				aSHST[288]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C370"
				aSHST[289]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C371"
				aSHST[292]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C372"
				aSHST[290]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C373"
				aSHST[291]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C374"
				aSHST[294]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C375"
				aSHST[295]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C376"
				aSHST[296]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C377"
				aSHST[297]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C378"
				aSHST[298]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C379"
				aSHST[299]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C380"
				aSHST[301]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C381"
				aSHST[300]:=SHST->RGR_DESCRI
			ElseIf SHST->RGR_CAMPO=="C382"
				aSHST[261]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C383"
				aSHST[293]+=Alltrim(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="VIII"//Capitulo VIII
			If SHST->RGR_CAMPO=="C385"
				aSHST[302]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C386"
				aSHST[303]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C387"
				aSHST[304]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C388"
				aSHST[305]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C389"
				aSHST[306]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C390"
				aSHST[307]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C391"
				aSHST[308]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C392"
				aSHST[309]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C393"
				aSHST[310]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C394"
				aSHST[311]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C395"
				aSHST[312]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C396"
				aSHST[313]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C397"
				aSHST[314]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C398"
				aSHST[315]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C399"
				aSHST[316]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C400"
				aSHST[317]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C401"
				aSHST[318]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C402"
				aSHST[319]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C403"
				aSHST[320]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C404"
				aSHST[321]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C405"
				aSHST[322]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C406"
				aSHST[323]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C407"
				aSHST[324]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C408"
				aSHST[325]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C409"
				aSHST[326]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C410"
				aSHST[327]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C411"
				aSHST[328]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C412"
				aSHST[329]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C413"
				aSHST[330]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C414"
				aSHST[331]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C415"
				aSHST[332]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C416"
				aSHST[333]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C417"
				aSHST[334]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C418"
				aSHST[335]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C419"
				aSHST[336]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C420"
				aSHST[337]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C421"
				aSHST[338]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C422"
				aSHST[339]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C423"
				aSHST[340]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C424"
				aSHST[341]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C425"
				aSHST[342]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C426"
				aSHST[343]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C427"
				aSHST[344]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C428"
				aSHST[345]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C429"
				aSHST[346]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C430"
				aSHST[347]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C431"
				aSHST[348]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C432"
				aSHST[349]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C433"
				aSHST[350]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C434"
				aSHST[351]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C435"
				aSHST[352]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C436"
				aSHST[353]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C437"
				aSHST[354]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C438"
				aSHST[355]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C439"
				aSHST[356]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C440"
				aSHST[357]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C441"
				aSHST[358]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C442"
				aSHST[359]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C443"
				aSHST[360]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C444"
				aSHST[361]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C445"
				aSHST[362]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C446"
				aSHST[363]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C447"
				aSHST[364]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C448"
				aSHST[365]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C449"
				aSHST[366]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C450"
				aSHST[367]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C452"
				aSHST[368]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C453"
				aSHST[369]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C454"
				aSHST[370]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C455"
				aSHST[371]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C456"
				aSHST[372]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C457"
				aSHST[373]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C458"
				aSHST[374]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C459"
				aSHST[375]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C460"
				aSHST[376]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C461"
				aSHST[377]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C467"
				aSHST[378]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C469"
				aSHST[379]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C470"
				aSHST[380]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C471"
				aSHST[381]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C472"
				aSHST[382]+=Alltrim(SHST->RGR_DESCRI)
			Endif
		ElseIf Alltrim(SHST->RGR_CAP)=="IX"//Capitulo IX
			If SHST->RGR_CAMPO=="C474"
				aSHST[383]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C475"
				aSHST[384]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C476"
				aSHST[385]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C477"
				aSHST[386]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C478"
				aSHST[387]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C479"
				aSHST[388]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C480"
				aSHST[389]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C481"
				aSHST[390]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C482"
				aSHST[391]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C483"
				aSHST[392]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C484"
				aSHST[393]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C485"
				aSHST[394]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C486"
				aSHST[395]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C487"
				aSHST[396]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C488"
				aSHST[397]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C489"
				aSHST[398]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C490"
				aSHST[399]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C491"
				aSHST[400]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C492"
				aSHST[401]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C493"
				aSHST[402]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C494"
				aSHST[403]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C495"
				aSHST[404]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C496"
				aSHST[405]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C497"
				aSHST[406]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C498"
				aSHST[407]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C499"
				aSHST[408]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C500"
				aSHST[409]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C501"
				aSHST[410]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C502"
				aSHST[411]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C503"
				aSHST[412]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C504"
				aSHST[413]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C505"
				aSHST[414]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C506"
				aSHST[415]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C507"
				aSHST[416]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C508"
				aSHST[417]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C509"
				aSHST[418]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C510"
				aSHST[419]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C511"
				aSHST[420]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C512"
				aSHST[421]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C513"
				aSHST[422]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C514"
				aSHST[423]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C515"
				aSHST[424]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C516"
				aSHST[425]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C517"
				aSHST[426]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C518"
				aSHST[427]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C519"
				aSHST[428]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C520"
				aSHST[429]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C521"
				aSHST[430]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C523"
				aSHST[431]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C524"
				aSHST[432]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C525"
				aSHST[433]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C526"
				aSHST[434]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C527"
				aSHST[435]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C528"
				aSHST[436]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C529"
				aSHST[437]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C530"
				aSHST[438]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C531"
				aSHST[439]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C532"
				aSHST[440]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C533"
				aSHST[441]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C534"
				aSHST[442]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C535"
				aSHST[443]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C536"
				aSHST[444]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C537"
				aSHST[445]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C538"
				aSHST[446]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C539"
				aSHST[447]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C540"
				aSHST[448]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C541"
				aSHST[449]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C542"
				aSHST[450]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C543"
				aSHST[451]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C544"
				aSHST[452]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C545"
				aSHST[453]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C546"
				aSHST[454]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C547"
				aSHST[455]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C548"
				aSHST[456]:=Val(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C549"
				aSHST[457]+=Alltrim(SHST->RGR_DESCRI)
			ElseIf SHST->RGR_CAMPO=="C557"
				aSHST[458]+=Alltrim(SHST->RGR_DESCRI)
			Endif
		Endif
		SHST->(DbSkip())
	End
	Endif
Endif



//================================================================================================
//Query trazaendo somente os dados que serao utilizados em array
//================================================================================================
cSHST2:="SELECT RGR_CAP,RGR_TIPREG,RGR_REGIST,RGR_CAMPO,RGR_SEQ,RGR_DESCRI "
cSHST2+="FROM "+RETSQLNAME("RGR")+" "
cSHST2+="WHERE RGR_DESCRI<>' ' "
cSHST2+="AND RGR_FILIAL ='"+cParFilial+"' "
cSHST2+="AND RGR_ANOBAS ='"+cParAnoBas+"' "
cSHST2+="AND RGR_TIPREG='M'"
cSHST2+="AND RGR_SEQ NOT IN ('000','999') "
cSHST2+="AND D_E_L_E_T_='' "
cSHST2+="ORDER BY RGR_CAP,RGR_TIPREG,RGR_REGIST,RGR_SEQ,RGR_CAMPO "

cSHST2:= ChangeQuery(cSHST2)

If Select("SHST2")>0
	DbSelectArea("SHST2")
	SHST2->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSHST2),"SHST2",.F.,.T.)
If SHST2->(!Eof())
	
	Do While SHST2->(!EOF())
		If SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M221"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				nVal2:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C060"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C061"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C062"
						nVal2:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,.F.)
				Aadd(aICMTrb,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M222"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			cDesc1:=""
			cDesc2:=""
			Do While SHST2->(!EOF())  .And.  cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C064"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C065"
						cDesc2:=Alltrim(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,cDesc2)
				Aadd(aAux,.F.)
				Aadd(aICTTrb,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M224"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				nVal2:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C075"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C076"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C077"
						nVal2:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,.F.)
				Aadd(aECMTrb,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M225"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				cDesc2:=""
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C079"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C080"
						cDesc2:=Alltrim(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,cDesc2)
				Aadd(aAux,.F.)
				Aadd(aECTTrb,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M243"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				cDesc2:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				nVal4:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C117"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C118"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C119"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C120"
						cDesc2:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C121"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C122"
						nVal4:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,cDesc2)
				Aadd(aAux,nVal3)
				Aadd(aAux,nVal4)
				Aadd(aAux,.F.)
				Aadd(aCAcFor,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M245"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				nVal4:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C127"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C128"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C129"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C130"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C131"
						nVal4:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,nVal3)
				Aadd(aAux,nVal4)
				Aadd(aAux,.F.)
				Aadd(aCForPe,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M251"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C176"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C177"
						nVal1:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,.F.)
				Aadd(aCAudit,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M25A"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				cDesc2:=""
				cDesc3:=""
				cDesc4:=""
				cDesc5:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C217"
						cDesc1:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C218"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C219"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C220"
						cDesc2:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C221"
						cDesc3:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C222"
						cDesc4:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C223"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C224"
						cDesc5:=Alltrim(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,cDesc2)
				Aadd(aAux,cDesc3)
				Aadd(aAux,cDesc4)
				Aadd(aAux,nVal3)
				Aadd(aAux,cDesc5)
				Aadd(aAux,.F.)
				Aadd(aCAgFis,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M25D"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				cDesc2:=""
				cDesc3:=""
				cDesc4:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				nVal4:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C228"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C229"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C230"
						cDesc2:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C231"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C232"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C233"
						cDesc3:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C234"
						nVal4:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C235"
						cDesc4:=Alltrim(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,nVal1)
				Aadd(aAux,cDesc1)
				Aadd(aAux,cDesc2)
				Aadd(aAux,nVal2)
				Aadd(aAux,nVal3)
				Aadd(aAux,cDesc3)
				Aadd(aAux,nVal4)
				Aadd(aAux,cDesc4)
				Aadd(aAux,.F.)
				Aadd(aCAgQui,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M25I"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				cDesc2:=""
				cDesc3:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				nVal4:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C241"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C242"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C243"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C244"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C245"
						cDesc2:=Alltrim(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C246"
						nVal4:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C247"
						cDesc3:=Alltrim(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,nVal3)
				Aadd(aAux,cDesc2)
				Aadd(aAux,nVal4)
				Aadd(aAux,cDesc3)
				Aadd(aAux,.F.)
				Aadd(aCAgBio,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M262"
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C463"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C464"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C465"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C466"
						nVal3:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal1)
				Aadd(aAux,nVal2)
				Aadd(aAux,nVal3)
				Aadd(aAux,.F.)
				Aadd(aCAcoImu,aAux)
			End
		ElseIf SHST2->RGR_TIPREG+SHST2->RGR_REGIST=="M273"
			
			cTipReg:=SHST2->RGR_TIPREG+SHST2->RGR_REGIST
			Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST
				cSequencia:=SHST2->RGR_SEQ
				cDesc1:=""
				nVal1:=0
				nVal2:=0
				nVal3:=0
				nVal4:=0
				nVal5:=0
				Do While SHST2->(!EOF()) .And. cTipReg==SHST2->RGR_TIPREG+SHST2->RGR_REGIST .And. cSequencia==SHST2->RGR_SEQ
					If SHST2->RGR_CAMPO=="C551"
						nVal1:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C552"
						cDesc1:=SHST2->RGR_DESCRI
					ElseIf SHST2->RGR_CAMPO=="C553"
						nVal2:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C554"
						nVal3:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C555"
						nVal4:=Val(SHST2->RGR_DESCRI)
					ElseIf SHST2->RGR_CAMPO=="C556"
						nVal5:=Val(SHST2->RGR_DESCRI)
					Endif
					cSequencia:=SHST2->RGR_SEQ
					SHST2->(DbSkip())
				End
				aAux := {}
				Aadd(aAux,nVal1)
				Aadd(aAux,cDesc1)
				Aadd(aAux,nVal2)
				Aadd(aAux,nVal3)
				Aadd(aAux,nVal4)
				Aadd(aAux,nVal5)
				Aadd(aAux,.F.)
				Aadd(aCCodDoe,aAux)
			End
		Else
			SHST2->(DbSkip())
		Endif
	End
	
Endif         
Return              
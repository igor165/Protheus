#include "PROTHEUS.CH"
#Include "PLSMGER.CH"
#include "TOPCONN.CH"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA295 � Autor � Michele Tatagiba     � Data � 22.11.2002 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Classe de Carencia                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 7.10                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA295
                                
Private aRotina   := MenuDef()
                        
Private cCadastro  := "Classe de Carencia"

mBrowse(006,001,022,075,"BDL")

Return      



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LSA295Mnt篈utor  矴eraldo Felix Junior� Data �  06/04/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Manutencao das classes de carencia.                        罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � SIGAPLS                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function PLSA295Mnt(cAlias,nReg,nOpc)                
Local I__f := 0

LOCAL aButtons    := {}
LOCAL nOpca		  := 2
LOCAL lRet     := .T.
LOCAL BG8Name  := RetSQLName("BG8")
LOCAL cSQL     := ""

PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE lCarTDE    := .f.
PRIVATE oEnchoice

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis para controle do tipo de acomodacao                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aTrbPc  := {}
PRIVATE oBrwPc
PRIVATE aCabPc  := {}
PRIVATE aDadPc  := {}

PRIVATE aCols      := {}
PRIVATE aHeader    := {}
     
aadd(aButtons,{"FERIAS",{|| PLS295ADPC(nOpc) },"Tipo de Acomodacao"})

If nOpc == K_Incluir
   Copy cAlias TO Memory Blank
Else
    Copy cAlias TO MEMORY
Endif    

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta a GetDados do Padrao de Tipo de Acomodacao                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Store Header "BWG" TO aCabPc For .T.
BWG->(DbSetOrder(1))
If ! BWG->(DbSeek(xFilial("BWG")+M->BDL_CODINT+M->BDL_CODIGO))
   Store COLS Blank "BWG" TO aDadPc FROM aCabPc
Else
   Store COLS "BWG" TO aDadPc FROM aCabPc VETTRAB aTrbPc While xFilial("BWG")+M->BDL_CODINT+M->BDL_CODIGO == BWG->(BWG_FILIAL+BWG_CODINT+BWG_CLASSE)
Endif

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 030.4,100.3 OF GetWndDefault()

if Val(GetVersao(.F.)) >= 12 //Valida vers鉶 12
	oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,{035,001,260,355},,,,,,oDlg,,,.F.)
Else
	oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,{015,001,260,355},,,,,,oDlg,,,.F.)
Endif

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),(PlsEndBrw(),oDlg:End()),.F.)},{||nOpca:=2,oDlg:End()},.F.,aButtons))

If nOpca == K_OK
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Inicio da Transacao...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nOpc == K_Excluir
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualizo os Procedimentos Incompativeis                             �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		cSQL := "SELECT * FROM "+BG8Name+" WHERE "
		cSQL += BG8Name+".BG8_FILIAL = '"+xFilial("BG8")+"' AND "
		cSQL += "BG8_CLACAR = '"+BDL->BDL_CODIGO+"' AND D_E_L_E_T_ <> '*'"
		
		TCQUERY cSQL NEW ALIAS "TrbBG8"
		
		If ! TrbBG8->(Eof())
			lRet := .F.
			SX2->(DbSetOrder(1))
			SX2->(DbSeek("BG8"))
			MsgInfo("Nao e possivel Excluir pois este registro esta sendo utilizado ["+AllTrim(SX2->(X2NOME()))+"]")
			Return(.F.)
		Endif
		TrbBG8->(DbCloseArea())
	Endif
	
	PLUPTENC(cAlias,nOpc)
    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    //� Tipo de Acomodacao...                                               �
    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�            
    If Type('oBrwPc') == "O"
       aChave := {}
       aadd(aChave,{"BWG_CODINT",M->BDL_CODINT})
       aadd(aChave,{"BWG_CLASSE",M->BDL_CODIGO})
       oBrwPc:Grava(aChave)
    Endif         	
Endif


Return()



/*
Carrega os dados do Benefici醨io em um array
Carrega as coberturas do benefici醨io passado
Passa essas informa珲es para o NIO.

Retorno
lRet	: retorno logico indicando se a cobertura do beneficiario foi atualizada no NIO 
*/
Function CarAtuNIO(cAlias,cOriDad,nOpc,lUsaSIP)
Local cCodOpeSip 	:= ""
Local cCodProSip 	:= ""
Local aDadCobAux 	:= {}		
Local aDadCob 	:= {}
Local nOpcSip 	:= nOpc
Local lRet    	:= .F.     

Default lUsaSIP	:= .F.
Default cOriDad := "1"

//Primeiro monto o array com os dados do benefici醨io
	oModel := Pl260DadNio(cOriDad ,NIL    ,NIL ,cAlias   ,aDadCobAux,NIL    , NIL, , lUsaSIP )
							
	//Carrega as coberturas do benefici醨io.
	//O trabalho de levantar itens de cobertura cobertos � do sistema de origem (no caso o PLS)
     
	//Chamo a rotina gen閞ica que atualiza o N鷆leo de Informa珲es da Central de Obriga珲es
	//lRet := PLSAtuNIO("B3O",oModel,nOpcSip,dDataBase,aDadCobAux) 
	
Return lRet


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北砅rograma  砅LS295ADPC� Autor � Geraldo Felix Junior � Data � 06.04.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escri噭o � Monta a getdados do Tipo de Acomodacao                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function PLS295ADPC(nOpc)

LOCAL oDlgPc                   
Local nOpca       := 0

DEFINE MSDIALOG oDlgPc TITLE "Tipo de Acomodacao - "+BDL->BDL_DESCRI FROM 009,000 TO 029,060 OF GetWndDefault()
oDlgPc:lEscClose := .F.

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta o Browse dos Procedimentos                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oBrwPc  := TPLSBrw():New(35,001,237,150,nil  ,oDlgPc,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabPc ,aDadPc ,.F. ,"BWG" ,nOpc,"Tipo de Acomodacao - "+Alltrim(BDL->BDL_DESCRI) ,,nil,nil,aTrbPc)

ACTIVATE MSDIALOG oDlgPc CENTERED ON INIT ( EnchoiceBar(oDlgPc, {|| nOpca:=1,oDlgPc:End()},{|| nOpca:= 0,oDlgPc:End()} ))

If nOpca == 1
   aCabPc := aClone(oBrwPc:aHeader)
   aDadPc := aClone(oBrwPc:aCols)
Endif


Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �04/01/2007潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados         潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01	,	'AxPesqui'		, 0 , K_Pesquisar  , 0, .F.},;
						{ STRPL02	,	'PLSA295Mnt'	, 0 , K_Visualizar , 0, Nil},; 
						{ STRPL03		,	'PLSA295Mnt'	, 0 , K_Incluir    , 0, Nil},; 
						{ STRPL04		,	'PLSA295Mnt'	, 0 , K_Alterar    , 0, Nil},;
						{ STRPL05		,	'PLSA295Mnt'	, 0 , K_Excluir    , 0, Nil}}
Return(aRotina)





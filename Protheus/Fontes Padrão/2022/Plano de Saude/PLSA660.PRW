#define  K_NovaVersao  6
#define  K_SubCon      6
#define  K_BlqSubCon   7
#define  K_HisBlqSub	   8
#include "PLSMGER.CH"
#include "PLSA660.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"  

STATIC cMenu := 6 //Variavel estatica para controlar o MenuDef e o aRotina.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA660 Ё Autor Ё Tulio Cesar          Ё Data Ё 07.12.2000 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Grupos/Empresas                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁTulio Cesar Ё01.11.01ЁV 7.10Ё  Novas implementacoes                    Ё╠╠
╠╠ЁAlexander   Ё06.04.05Ё      Ё Exclusao de Parametro (Gru/Emp,Cont,SCon)Ё╠╠
╠╠Ё            Ё        Ё      Ё Nao deixar excluir contrato com subcontroЁ╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660

Local aRotAdic
Local nNx
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define opcoes da rotina...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cAlias    	:= "BG9"
PRIVATE cCadastro 	:= PLSRetTit(cAlias)
PRIVATE nOk			:= 0
PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi(STR0009) },;	//'Empresa OK'
							{ 'BR_AZUL'     ,OemtoAnsi(STR0010) },;	//'Sub-Contrato(s) Bloqueado(s) Parcial(s)'
							{ 'BR_AMARELO'  ,OemtoAnsi(STR0011) },;	//'Familia(s) Bloqueada(s) Parcial(s)'
							{ 'BR_VERMELHO' ,OemtoAnsi(STR0012) },;	//'Sub-Contrato(s) Bloqueado(s)'
							{ 'BR_PRETO' 	,OemtoAnsi(STR0013) } }

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define aCols e a aHeader...                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCols        := {}
PRIVATE aHeader      := {}   
PRIVATE n            := 1        
PRIVATE nHC
PRIVATE nHG
PRIVATE nHS                         

cMenu   := 0
aRotina := MenuDef()

// Ponto de Entrada para inserir novos botУes no menu do Grupo/Empresa
If ExistBlock("PL660MGE") 
	aRotAdic := ExecBlock("PL660MGE",.F.,.F.,{})

	If ValType(aRotAdic) == "A"
		For nNx := 1 To Len(aRotAdic)
			AAdd(aRotina,aRotAdic[nNx])
		Next
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza HELP's			                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PL660CarCr()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama mBrowse padrao...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BQC->(DbSetOrder(1))
BT5->(DbSetOrder(1))
BG9->(DbClearFilter())
BG9->(DbSetOrder(1))
BG9->(MsSeek(xFilial("BG9")))
BG9->(mBrowse(06,01,22,75,"BG9",,,,,,,,,,,.F.,.F. ))
BG9->(DbClearFilter())
BT5->(DbClearFilter())
BQC->(DbClearFilter())                
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                              

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA660Mov Ё Autor Ё Tulio Cesar        Ё Data Ё 08.03.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Modulo de Manutencao dos Grupo de Beneficiarios           Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLSA660Mov(cAlias,nReg,nOpc)                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PLSA660                                                   Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Mov(cAlias,nReg,nOpc)
Local I__f := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da EnchoiceBar...                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды



LOCAL bOK     := {|| nOpca := 1,If( PLSA660OK(nOpc,M->BG9_CODINT+M->BG9_CODIGO,M->BG9_USO), ;
                      oDialog:End(),nOpca:=2),If(nOpca==1,oDialog:End(),.F.) }
LOCAL bCancel := {||nOpca :=2, oDialog:End()}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de lock de registro...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL lLock   := .F.
LOCAL oEncBG9
LOCAL aSize 	:= {}
LOCAL aInfo 	:= { }
LOCAL aObjects 	:= {}   
LOCAL aPosObj 	:= {}
LOCAL aObjects2 := {}   
LOCAL aPosObj2 	:= {}
Local iCont     := 0
Local aButtons  := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis genericas...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oDialog
PRIVATE nOpcx        := nOpc
PRIVATE nOpca        := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Financeiro por contrato...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCabFin  := {}
PRIVATE aDadFin  := {}
PRIVATE aTrbFin  := {}
PRIVATE oBrwFin
PRIVATE lFinanc   := ( nOpc <> K_Incluir .And. BG9->BG9_TIPO == "2" )
PRIVATE cInd
PRIVATE cFor
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da enchoice...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE n
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis para controle de Forma de Cobranca ...             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aSTela  := {}            

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o GRUPO EMPRESA TEM CONTRATO  e nao deixa excluirЁ
//ЁAlexander  11/04/2005                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if nOpc == K_Excluir
	BT5->(DbSetOrder(1)) //BT5_FILIAL + BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
	if BT5->( MsSeek(xFilial("BT5")+BG9->(BG9_CODINT+BG9_CODIGO) ) )
	   BT5->(DbCloseArea())
	   MsgInfo(OemtoAnsi(STR0014)+CHR(13)+OemtoAnsi(STR0015)) //'Existe CONTRATO para este GRUPO/EMPRESA!' 'Impossivel fazer a EXCLUSцO!'
	   return
	endif	
endif	                 
If Existblock("PLS660GR")
	If !(Execblock("PLS660GR",.F.,.F.,{nOpc}))
		Return(.F.)
	Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se registro esta disponivel...                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpcx == K_Alterar .Or. nOpcx == K_Excluir
   If ! BG9->(RecLock("BG9",.F.))
      Return
   Else
      lLock := .T.
   Endif   
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta M->??? para enchoice...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Incluir
   Copy cAlias To Memory Blank
Else
   Copy cAlias TO MEMORY                                           
EndIf                      

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetEnch("") 

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}   
AAdd( aObjects, { 100, 20, .t., .f. } )    
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )     

aObjects2 := {}   
AAdd( aObjects2, { 100, 20, .t., .f. } )    
AAdd( aObjects2, { 100, 100, .t., .t.,.f. } )
aPosObj2 := MsObjSize( aInfo, aObjects2 )     

DEFINE MSDIALOG oDialog TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Folder...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! lFinanc
   @ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDialog PIXEL PROMPTS  OemtoAnsi(STR0016) //"Dados da Empresa"
Else
   @ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDialog PIXEL PROMPTS  OemtoAnsi(STR0016),; //"Dados da Empresa"
                                                                    OemtoAnsi(STR0017)
Endif                                                                   

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Enchoice...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Zero()
oEncBG9 := MsMGet():New(cAlias,nReg,nOpc,,,,,{005,001,aPosObj[2][4],aPosObj[2][3]},,,,,,oFolder:aDialogs[1],,,.F.)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё FINANCEIRO...                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lFinanc

   Store Header "BBT" TO aCabFin For AllTrim(SX3->X3_CAMPO) $ "BBT_MESTIT,BBT_ANOTIT,BBT_CLIFOR,BBT_PREFIX,BBT_NUMTIT,BBT_PARCEL,BBT_TIPTIT,BBT_NUMCOB,BBT_RECPAG,BBT_VALOR"
   If nOpcx == K_Incluir
      Store COLS Blank "BBT" TO aDadFin FROM aCabFin
   Else
      cInd := CriaTrab(nil,.F.)
      cOrd := Eval({ || BBT->(DbSetOrder(1)), BBT->(IndexKey()) })
      
      cFor := "BBT_FILIAL = '"+xFilial("BBT")+"'  .And. BBT_CODOPE == '"+BG9->BG9_CODINT+"' .And. "
      CFor += "BBT_CODEMP = '"+BG9->BG9_CODIGO+"' .And. BBT_NIVEL  == '1' "
      
      BBT->(IndRegua("BBT",cInd,cOrd,nil,cFor,nil,.T.))

      Store COLS "BBT" TO aDadFin FROM aCabFin VETTRAB aTrbFin While .T.

      If Len(aDadFin) == 0
         Store COLS Blank "BBT" TO aDadFin FROM aCabFin
         @ 005, 006 Say oSayFin PROMPT OemtoAnsi(STR0018) SIZE 150, 006 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao ha titulos no financeiro para esta empresa"
      Else
					oBrwFin := TPLSBrw():New(005,005,aPosObj2[2][4]*0.99,aPosObj2[2][3]*0.7 ,nil  ,oFolder:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabFin   ,aDadFin ,.F.      ,"BBT" ,nOpcx,"Historico Financeiro",nil,nil,nil,aTrbFin,,,)
		 			oBrwFin:bGotFocus  := {|| cPrefix  := oBrwFin:FieldGet("BBT_PREFIX"),;
							      cNumTit  := oBrwFin:FieldGet("BBT_NUMTIT"),;
							      cParcela := oBrwFin:FieldGet("BBT_PARCEL"),;
							      cTipTit  := oBrwFin:FieldGet("BBT_TIPTIT"),;
							      cNumCob  := oBrwFin:FieldGet("BBT_NUMCOB")}
		 			oBrwFin:bChange    := {||Eval(oBrwFin:bGotFocus)}
		 			oBotCon := SButton():New(aPosObj2[2][3]*0.70,005, 09, {|| PLSCOMPFIN( oBrwFin:FieldGet("BBT_PREFIX"),oBrwFin:FieldGet("BBT_NUMTIT"),oBrwFin:FieldGet("BBT_PARCEL"),;
		                                                      oBrwFin:FieldGet("BBT_TIPTIT"),oBrwFin:FieldGet("BBT_NUMCOB"),.F.,.F.) },;
																													oFolder:aDialogs[2], .T.) 
		 			oBotCon:cTOOLTIP := OemtoAnsi(STR0019) //"Composicao do titulo"                  
      Endif
      
      BBT->(DbClearFilter())
      BBT->(RetIndex("BBT"))
   Endif

Endif   

//Ponto de entrada para adicionar novos botoes no cadastro Grupo/Empresa
If ExistBlock("PLS660BOT")

	aBot := ExecBlock("PLS660BOT",.F.,.F.,{})

	If ValType(aBot) == "A"

		For iCont := 1 to Len(aBot)
			aAdd(aButtons,{aBot[iCont,1],aBot[iCont,2],aBot[iCont,3],aBot[iCont,4]})
		Next iCont

	EndIf

Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,aButtons)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata atualizacao dos dados...  
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Trata se for exclusao...                                            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nOpcx == K_Excluir
      If ! PLSA660Exc("1",M->BG9_CODINT,M->BG9_CODIGO,.T.)
         Return
      Endif
   Endif

   If nOpcx <> K_Visualizar
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Inicio da Transacao...                                              Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      Begin Transaction
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Se for exclusao, exclui os contratos e seus componentes             Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nOpcx == K_Excluir
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Exclui Parametro Grupo/Empresa..	                                 Ё
	     //Ё Alexander 06/04/2005		     	                                 Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         BGJ->(DBSetOrder(1)) //BGJ_FILIAL + BGJ_CODINT + BGJ_CODIGO + BGJ_ANO + BGJ_MES
         If BGJ->(MsSeek(xFilial("BGJ")+BG9->(BG9_CODINT+BG9_CODIGO)))
            While !BGJ->(EOF()) .And. BG9->(BG9_CODINT+BG9_CODIGO) == BGJ->(BGJ_CODINT+BGJ_CODIGO)
                  BGJ->(RecLock("BGJ",.F.))
                  BGJ->(DBDelete())
                  BGJ->(MSUnlock())
            BGJ->(DBSkip())
            Enddo
         Endif
      Endif
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza cadastro do plano...                                       Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      PLUPTENC("BG9",nOpc,lLock)      
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Libera Lock...                                                      Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If lLock
         BG9->(MsUnLock())
      Endif   
      ConfirmSX8()
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Fim do controle de semafaro iniciado em PLSA660OK                   Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nOpcx == K_Incluir
         PLSFechaSem(nHG,"PLSA660G.SMF")
      Endif   
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Fim da Transacao...                                                 Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      End Transaction

	  If ExistBlock("PL660GRV") 
			ExecBlock("PL660GRV",.F.,.F.,{nOpcx})
	  EndIf

   Endif   
Else
   If nOpc == K_Incluir
      RollBackSX8()
   Endif   
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLS660FilC Ё Autor Ё Michele Tatagiba   Ё Data Ё 03.06.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Modulo de Manutencao do Filtro dos contratos              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS660FilC(cAlias,nReg,nOpc)                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PLSA660                                                   Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/              
Function PLS660FilC()
LOCAL aRotAdic := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trato o caso da empresa ser pessoa fisica...                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BG9->BG9_TIPO == "1"
   MsgInfo(OemtoAnsi(STR0020)) //"Opcao disponivel somente para pessoa juridica."
Else
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Define variaveis PRIVATE...                                              Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
   	PRIVATE aCores 
	PRIVATE bAjustBrw  := {|| oBrw := GetObjBrow(), PLSMONLEG(oBrw,aCdCores,aFilAdic[2]) }
   	PRIVATE aRotina  := {}
                           
	PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi(STR0023) },; 		//'Contrato OK'
								{ 'BR_AZUL'     ,OemtoAnsi(STR0010) },;		//'Sub-Contrato(s) Bloqueado(s) Parcial(s)'
								{ 'BR_VERMELHO' ,OemtoAnsi(STR0012) } }			//'Sub-Contrato(s) Bloqueado(s)'
   	PRIVATE cTitulo
   	PRIVATE cAlias    := "BT5"
   	PRIVATE cChave    := BG9->(BG9_CODINT+BG9_CODIGO)
   	PRIVATE cChaveBT5 := cChave
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Chama funcao de Browse...                                           Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	 cMenu := 1
	 aRotina := MenuDef()

   #IFDEF TOP
           PRIVATE cFil := "BT5_FILIAL = '"+xFilial("BT5")+"' AND BT5_VERSAO = '001' AND BT5_CODINT = '"+Subs(cChaveBT5,1,4)+"'"
                   cFil += " AND BT5_CODIGO = '"+Subs(cChaveBT5,5,4)+"' AND D_E_L_E_T_ = ' '"
   #ELSE                
           PRIVATE cFil := "BT5_FILIAL = '"+xFilial("BT5")+"' .And. BT5_VERSAO = '001' .And. BT5_CODINT = '"+Subs(cChaveBT5,1,4)+"'"
                   cFil += " .And. BT5_CODIGO = '"+Subs(cChaveBT5,5,4)+"'"
   #ENDIF
   BT5->(DbSetOrder(1))   
   BT5->(MsSeek(xFilial("BT5")))
   cTitulo   := OemtoAnsi(STR0024)+" [ "+AllTrim(BG9->BG9_DESCRI)+" ] "	//"Grupo/Empresa"


 	If ExistBlock("PL660FC")
	aRotAdic := ExecBlock("PL660FC",.F.,.F.,{aRotina})
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ALTERACAO DAHER LEGENDA												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCores   :={ 	{ "(nOk := Plsa660Blq()) = 2", 'BR_VERMELHO' },;
					{ "nOk = 1", 'BR_AZUL' },;
	             	{ ".T.", 'BR_VERDE'} }
 
	aFilAdic := {.T.,"('01','02','03')"}
	aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi(STR0025),"01" },;	//'Contrato Ativo'
						{ 'BR_AZUL'     ,OemtoAnsi(STR0026),"02" },;	//'Bloqueado Parcial'
						{ 'BR_VERMELHO' ,OemtoAnsi(STR0027),"03" } }	//'Contrato Bloqueado'
   BT5->(dbSetorder(1))
   BT5->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,nil,nil,nil,nil,4,aCores,nil,nil,nil,bAjustBrw,.F.,.F.,,cFil))
   //BT5->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,,,,,,aCores,,,,, .T. ))
   
  
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                   

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA660Con Ё Autor Ё Michele Tatagiba   Ё Data Ё 03.06.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Modulo de Manutencao dos Contratos                        Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLSA660Con(cAlias,nReg,nOpc)                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PLSA660                                                   Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Con(cAlias,nReg,nOpc)
Local I__f := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da EnchoiceBar...                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL bOK     := {|| nOpca := 1,If( PLS660COOK(nOpc,BG9->BG9_CODINT+BG9->BG9_CODIGO,M->BT5_NUMCON), ;
                      oDlgFolder:End(),nOpca:=2),If(nOpca==1,oDlgFolder:End(),.F.) }
LOCAL bCancel := {|| nOpca := 2, oDlgFolder:End()}
LOCAL nOrdBT5
LOCAL nRecBT5
LOCAL nRegOld := nReg
LOCAL xnOrdem := BT5->( INDEXORD() )
LOCAL cPrefix	:= ''
LOCAL cNumTit	:= ''
LOCAL cParcela  := ''
LOCAL cTipTit	:= ''
LOCAL cNumCob	:= ''
LOCAL oBotCon
LOCAL aSize 	:= {}
LOCAL aInfo 	:= {}
LOCAL aObjects 	:= {}   
LOCAL aPosObj 	:= {}
LOCAL aObjects2 := {}   
LOCAL aPosObj2 	:= {}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis genericas...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oEncBT5
PRIVATE nOpcx        := nOpc
PRIVATE nOpca        := 0
PRIVATE cChave       := BG9->(BG9_CODINT+BG9_CODIGO)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da enchoice...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aSTela  := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Versoes Contratos ...                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCabVer  := {}
PRIVATE aDadVer  := {}
PRIVATE aTrbVer  := {}
PRIVATE oBrwVer       
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Financeiro por contrato...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCabFin  := {}
PRIVATE aDadFin  := {}
PRIVATE aTrbFin  := {}
PRIVATE oBrwFin
PRIVATE lFinanc   := ( nOpc <> K_Incluir .And. BG9->BG9_TIPO == "2" )
PRIVATE cInd
PRIVATE cFor
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis do contrato selecionado...                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oSay01
PRIVATE oSay02
//PRIVATE oSay03                
PRIVATE oPla
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define folders...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oFolder
PRIVATE oDlgFolder                                                       
PRIVATE oFolPro                 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Contratos dos grupos...                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cCodCon  := BT5->BT5_NUMCON
PRIVATE cChavCon
              
PRIVATE lNewVer    := .F.
PRIVATE cPlsVersao := "001"
PRIVATE nRecBQB
PRIVATE cVerEsc    := ""                               
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o CONTRATO  tem SUB-CONTRATO  e nao deixa excluirЁ
//ЁAlexander  06/04/2005                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if nOpc == K_Excluir
	DbSelectArea("BQC")
	BQC->(DbSetOrder(1)) //BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + + BQC_SUBCON + BQC_VERSUB
	if BQC->( MsSeek(xFilial("BQC")+BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) ) )
	   BQC->(DbCloseArea())
	   MsgInfo(OemtoAnsi(STR0028)+CHR(13)+OemtoAnsi(STR0015)) //'Existe Sub-Contrato para este CONTRATO!'
	   return
	endif	
endif	

If Existblock("PLS660CT")
	If !(Execblock("PLS660CT",.F.,.F.,{nOpc}))
		Return(.F.)
	Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera filtros do mBrowse...                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BT5->(DbClearFilter())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de versao dos Contratos ...                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nOrdBT5 := BT5->(IndexOrd())
nRecBT5 := BT5->(Recno())

If     nOpc == K_Incluir
       cPLSVersao := "001"            
       cCadastro  := cTitulo + OemtoAnsi(STR0029) //" - Novo Contrato"
ElseIf nOpc == K_Visualizar .Or. nOpc == K_Alterar .Or. nOpc == K_Excluir .Or. nOpc == K_SubCon
       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Controle de versao do plano. Exibir as versoes existentes...        Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       cVerEsc := ""
       BT5->(DbSetOrder(1))
       BT5->(MsSeek(xFilial("BT5")+cChave+cCodCon+"001"))
       BT5->(DbSkip())
       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё VERSOES...                                                          Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       Store Header "BQB" TO aCabVer For .T.
       BQB->(DbSetOrder(1))
       If BQB->(MsSeek(xFilial("BQB")+cChave+cCodCon+"001"))
          Store COLS "BQB" TO aDadVer FROM aCabVer VETTRAB aTrbVer While cChave+cCodCon == BQB->(BQB_CODIGO+BQB_NUMCON)
       Else

          Help("",1,"PLS660VE1")
          
          DbSelectArea("BT5")
          Return
       Endif
       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Define dialogo...                                                   Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If Len(aDadVer) > 1
          DEFINE MSDIALOG oDlgFolder TITLE OemtoAnsi(STR0030) FROM 008.2,010.3 TO 020,50 OF GetWndDefault() //"Versao do Contrato"
          //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
          //Ё TPLSBRW -> VERSOES                                                  Ё
          //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          oBrwVer := TPLSBrw():New(020,006,150,085,nil  ,oDlgFolder,nil    , {|| nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BQB_VERSAO")], oDlgFolder:End() }  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabVer,aDadVer,.T.,"BQB",K_Visualizar,"Versoes do Contrato" ,{{"BQB_DATFIN","=",ctod("")}})
          oBrwVer:AVETTRAB := Aclone(aTrbVer)
          //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
          //Ё Ativa o dialogo...                                                  Ё
          //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BQB_VERSAO")], oDlgFolder:End()},{|| nOpca := 2,oDlgFolder:End()})
       Else
          nOpca   := K_OK
          cVerEsc := aDadVer[1,PLRETPOS("BQB_VERSAO",aCabVer)]
       Endif   
       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё testa se confirmou alguma versao...                                 Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If nOpca <> K_OK
          //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
          //Ё Refaz filtro para mBrowse...                                        Ё
          //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          DbSelectArea("BT5")
          Return
       Endif   

       BQB->(DbSetOrder(1))
       BQB->(MsSeek(xFilial("BQB")+cChave+cCodCon+cVerEsc))
       
       BT5->(DbSetOrder(1))
       BT5->(MsSeek(xFilial("BT5")+cChave+cCodCon+cVerEsc))
       nRecBQB := BQB->(Recno())
Endif       
                                  
If nOpcx == K_Alterar
   cCadastro  := cTitulo + OemtoAnsi(STR0031) //" - Alteracao do Contrato "
Elseif nOpcx == K_Excluir
   cCadastro  := cTitulo + OemtoAnsi(STR0032) //" - Exclusao do Contrato"
Endif               

If nOpc == K_SubCon
   PLS660FilS(nOpc, xnOrdem,  nRegOld)
  
   Return
Endif                                                                    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta M->??? para enchoice...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Incluir
   Copy cAlias To Memory Blank
Else
   Copy cAlias TO MEMORY
   cChavCon := cChave+BT5->(BT5_NUMCON+BT5_VERSAO)
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetEnch("")

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}   
AAdd( aObjects, { 100, 20, .t., .f. } )    
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )     

aObjects2 := {}   
AAdd( aObjects2, { 100, 20, .t., .f. } )    
AAdd( aObjects2, { 100, 100, .t., .t.,.f. } )
aPosObj2 := MsObjSize( aInfo, aObjects2 )     

DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
                                                                             
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Folder...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! lFinanc
   @ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlgFolder PIXEL PROMPTS  OemtoAnsi(STR0006),; //"Contratos "
                                                                       OemtoAnsi(STR0033)	//Versoes
Else
   @ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlgFolder PIXEL PROMPTS  OemtoAnsi(STR0006)+ " ",;//"Contratos "
                                                                      OemtoAnsi(STR0033),;		//"Versoes"
                                                                      OemtoAnsi(STR0017)		//"Historico Financeiro"
Endif                                                                   

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Mensagem Informativa...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Val(GetVersao(.F.)) >= 12//caso a versЦo seja maior ou igual a 12 altera a linha de inМcio dos folders
	@ 030, 003 GROUP oGrupoCon TO 050, 039 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0034)  COLOR CLR_HBLUE, CLR_HRED //" Codigo "
	@ 040, 006 Say oSayCon PROMPT TransForm(cChave,"@R !.!!!-!!!!") SIZE 030, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
	
	@ 030, 041 GROUP oGrupoCon TO 050, 155 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0035)  COLOR CLR_HBLUE, CLR_HRED //" Descricao Grupo Beneficiarios "
	@ 040, 044 Say oSayCon PROMPT BG9->BG9_DESCRI SIZE 115, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
		
	@ 030, 157 GROUP oGrupoCon TO 050, 214 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0036)  COLOR CLR_HBLUE, CLR_HRED //" Contrato / Versao "
	@ 040, 159 Say oSay01 PROMPT M->BT5_NUMCON SIZE 100, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
	
	@ 030, 216 GROUP oGrupoCon TO 050, 253 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0037)  COLOR CLR_HBLUE, CLR_HRED	//" Data "
	@ 040, 218 Say oSay02 PROMPT ctod("") SIZE 100, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE	
Else
	@ 015, 003 GROUP oGrupoCon TO 032, 039 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0034)  COLOR CLR_HBLUE, CLR_HRED //" Codigo "
	@ 022, 006 Say oSayCon PROMPT TransForm(cChave,"@R !.!!!-!!!!") SIZE 030, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
	
	@ 015, 041 GROUP oGrupoCon TO 032, 155 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0035)  COLOR CLR_HBLUE, CLR_HRED //" Descricao Grupo Beneficiarios "
	@ 022, 044 Say oSayCon PROMPT BG9->BG9_DESCRI SIZE 115, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
	
	@ 015, 157 GROUP oGrupoCon TO 032, 214 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0036)  COLOR CLR_HBLUE, CLR_HRED //" Contrato / Versao "
	@ 022, 159 Say oSay01 PROMPT M->BT5_NUMCON SIZE 100, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
	
	@ 015, 216 GROUP oGrupoCon TO 032, 253 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0037)  COLOR CLR_HBLUE, CLR_HRED	//" Data "
	@ 022, 218 Say oSay02 PROMPT ctod("") SIZE 100, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
Endif
If nOpc <> K_Incluir
   PLSA660Cab(.F.)
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Enchoice...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEncBT5 := MsMGet():New(cAlias,nReg,nOpc,,,,,{005,005,aPosObj[2][4],aPosObj[2][3]},,,,,,oFolder:aDialogs[1],,,.F.)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё FINANCEIRO...                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lFinanc

   Store Header "BBT" TO aCabFin For AllTrim(SX3->X3_CAMPO) $ "BBT_MESTIT,BBT_ANOTIT,BBT_CLIFOR,BBT_PREFIX,BBT_NUMTIT,BBT_PARCEL,BBT_TIPTIT,BBT_NUMCOB,BBT_RECPAG,BBT_VALOR"
   If nOpcx == K_Incluir
      Store COLS Blank "BBT" TO aDadFin FROM aCabFin
   Else
      cInd := CriaTrab(nil,.F.)
      cOrd := Eval({ || BBT->(DbSetOrder(2)), BBT->(IndexKey()) })
      
      cFor := "BBT_FILIAL = '"+xFilial("BBT")+"'  .And. BBT_CODOPE == '"+BT5->BT5_CODINT+"' .And.  "
      CFor += "BBT_CODEMP = '"+BT5->BT5_CODIGO+"' .And. BBT_CONEMP =='"+BT5->BT5_NUMCON+"' .AND. "
      CFor += "BBT_VERCON = '"+BT5->BT5_VERSAO+"' .And. BBT_NIVEL  == '2' "
      
      BBT->(IndRegua("BBT",cInd,cOrd,nil,cFor,nil,.T.))

      Store COLS "BBT" TO aDadFin FROM aCabFin VETTRAB aTrbFin While .T.
      If Len(aDadFin) == 0
         Store COLS Blank "BBT" TO aDadFin FROM aCabFin
         @ 005, 006 Say oSayFin PROMPT OemtoAnsi(STR0038) SIZE 150, 006 OF oFolder:aDialogs[3] PIXEL COLOR CLR_HBLUE //"Nao ha titulos no financeiro para este contrato" 
      Else
					oBrwFin := TPLSBrw():New(005,005,aPosObj2[2][4]*0.99,aPosObj2[2][3]*0.7 ,nil  ,oFolder:aDialogs[3],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabFin   ,aDadFin ,.F.      ,"BBT" ,nOpcx,"Historico Financeiro",nil,nil,nil,aTrbFin,,,)
										oBrwFin:bGotFocus  := {|| cPrefix  := oBrwFin:FieldGet("BBT_PREFIX"),;
							      cNumTit  := oBrwFin:FieldGet("BBT_NUMTIT"),;
							      cParcela := oBrwFin:FieldGet("BBT_PARCEL"),;
							      cTipTit  := oBrwFin:FieldGet("BBT_TIPTIT"),;
							      cNumCob  := oBrwFin:FieldGet("BBT_NUMCOB")}
					oBrwFin:bChange    := {||Eval(oBrwFin:bGotFocus)}
					oBotCon := SButton():New(aPosObj2[2][3]*0.70, 005, 09, {|| PLSCOMPFIN(cPrefix,cNumTit,cParcela,;
		                                                      cTipTit,cNumCob,.F.,.F.) },;
		                                                      oFolder:aDialogs[3], .T.)   
					oBotCon:cTOOLTIP := OemtoAnsi(STR0019) //"Composicao do titulo"         
      Endif
      
      BBT->(DbClearFilter())
      BBT->(RetIndex("BBT"))
   Endif

Endif   


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VERSOES...                                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpcx == K_Incluir .Or. nOpcx == K_NovaVersao
   Copy "BQB" To Memory BLANK
   M->BQB_VERSAO := cPLSVersao
ElseIf nOpcx <> K_NovaVersao
   Copy "BQB" To Memory
Endif                                                                              
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de versao...                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_NovaVersao
   M->BT5_VERSAO  := cPLSVersao   
   lRefresh       := .T.
   nOpc           := K_Alterar
   nOpcx          := K_Alterar
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё TPLSBRW -> VERSOES CONTRATOS                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aTela := {}
aGets := {}
cVar  := "aSTela["+AllTrim(Str(Len(aSTela)+1))+"]"
aadd(aSTela,{})
oEncVer := BQB->(MsMGet():New("BQB",nRecBQB,nOpc,,,,,{005,005,136,343},,,,,,oFolder:aDialogs[2],,,.F.,cVar))
aSTela[len(aSTela)] = aClone(aTela)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,bOK,bCancel,.F.,{})
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata atualizacao dos dados...  
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK

   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Trata se for exclusao...                                            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nOpcx == K_Excluir
      If ! PLSA660Exc("2",BG9->BG9_CODINT,BG9->BG9_CODIGO,.T.,M->BT5_NUMCON,M->BT5_VERSAO)
         Return
      Endif
   Endif

   If nOpcx <> K_Visualizar
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Inicio da Transacao...                                              Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      Begin Transaction
        
      If lNewVer
         nOpcx  := K_Incluir
         nOpc   := K_Incluir
      Endif
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza cadastro de contratos ...                                  Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
      If nOpcx == K_Incluir
         M->BT5_CODINT := Subs(cChave,1,4)
         M->BT5_CODIGO := Subs(cChave,5,4)
      Endif
      PLUPTENC("BT5",nOpc)
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Versoes...                                                          Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      M->BQB_CODIGO := cChave
      M->BQB_CODINT := Subs(cChave,1,4)
      M->BQB_CDEMP  := Subs(cChave,5,4)
      M->BQB_NUMCON := M->BT5_NUMCON
      PLUPTENC("BQB",nOpc)
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Exclui Parametros do Contrato...                                    Ё
      //Ё Alexander 06/04/2005			                                      Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      if nOpcx == K_Excluir
         BH3->( DbSetOrder(1) ) //BH3_FILIAL + BH3_CODINT + BH3_CODIGO + BH3_NUMCON + BH3_VERSAO + BH3_ANO + BH3_MES
         if BH3->( MsSeek(xFilial("BH3")+M->(BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO) ) )
            while !BH3->(EOF()) .And. M->(BT5_FILIAL + BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO ) == BH3->( BH3_FILIAL + BH3_CODINT + BH3_CODIGO + BH3_NUMCON + BH3_VERSAO )
  	      	  PLUPTENC("BH3",nOpc)                     
              BH3->(DBSkip())
            enddo
         endif
	  endif    
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Controle interno de troca de versao de plano...                     Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If lNewVer
         dDataIni := M->BQB_DATINI
         cVersao  := M->BQB_VERSAO
         
         BQB->(DbSetOrder(1))
         BQB->(MsSeek(xFilial("BQB")+cChave+cCodCon+cVersao,.T.))
         BQB->(DbSkip(-1))
         
         BQB->(RecLock("BQB",.F.))
         BQB->BQB_DATFIN := (dDataIni-1)
         BQB->(MsUnLock())
      Endif
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Fim do controle de semafaro iniciado em PLSA660OK                   Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nOpcx == K_Incluir
         PLSFechaSem(nHC,"PLSA660C.SMF")
      Endif                                          
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Fim da Transacao...                                                 Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      End Transaction
   Endif   
Endif                                
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Refaz filtro para mBrowse...                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BT5")
   
BT5->( dbSetorder(xnOrdem) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no Contrato Selecionado ...                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Incluir
   BT5->(DbGoTo(nRegOld))
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA660OK  Ё Autor Ё Tulio Cesar         Ё Data Ё 16.10.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica processo de atualizacao...                        Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660OK(nOpc,cChave,cUso)
LOCAL lRet    := Eval( { || Obrigatorio(aGets,aTela) })
LOCAL nOrdBG9 := BG9->(IndexOrd())

If ExistBlock("PL660VDE")
   If ! ExecBlock("PL660VDE",.F.,.F.)
      Return(.F.)
   Endif
Endif

If ( lRet .And. ! Empty(M->BG9_CODCLI) .And. Empty(M->BG9_VENCTO) )
   Help("",1,"PLSA660VC")
   Return(.F.)
Endif   
If lRet
   If nOpc == K_Incluir
      BG9->(DbSetOrder(1))     
      If BG9->(MsSeek(xFilial("BG9")+cChave))
         Help("",1,"JAGRAVADO")
         lRet := .F.
      Else     
         If cUso == "2"
            BG9->(DbSetOrder(3))
            If BG9->(MsSeek(xFilial("BG9")+cUso))
               Help("",1,"PLSA660USO")
               lRet := .F.
            Else
               lRet := .T.
            Endif
         Else
            lRet := .T.
         Endif
      
         If lRet
            nHG := PLSAbreSem("PLSA660G.SMF")
         Endif   
      Endif
      BG9->(DbSetOrder(nOrdBG9))
   Endif
Endif

Return(lRet)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLS660COOK Ё Autor Ё Michele Tatagiba    Ё Data Ё 03.06.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica processo de atualizacao...                        Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLS660COOK(nOpc,cChave,cCodCon)
LOCAL lRet    := Eval( { || Obrigatorio(oEncBT5:aGets,oEncBT5:aTela) .And. PLS660Ver(cChavCon,nOpcx) })
LOCAL nOrdBT5 := BT5->(IndexOrd())

If ExistBlock("PL660VDC")
   If ! ExecBlock("PL660VDC",.F.,.F.)
      Return(.F.)
   Endif
Endif

If lRet
   If nOpc == K_Incluir
      BT5->(DbSetOrder(1))     
      If BT5->(MsSeek(xFilial("BT5")+cChave+cCodCon))
         Help("",1,"JAGRAVADO")
         lRet := .F.
      Else
         nHC := PLSAbreSem("PLSA660C.SMF")
      Endif
      BT5->(DbSetOrder(nOrdBT5))
    Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o Dia de Vencimento e Codcli de acordo com Nivel...        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	if M->BT5_COBNIV == "1"
		if ! Empty(M->BT5_CODCLI) .or. ! Empty(M->BT5_CODFOR)
			if M->BT5_VENCTO == 0
				lRet := .F.
				MsgAlert(OemtoAnsi(STR0039)) //"Nivel de combranca neste nivel, por favor informe o dia de vencimento!"
			Endif
		Else
			lRet := .F.
			Help("",1,"PL660CLOBR")
		Endif
	Endif
Endif

If !lRet
	PLSFechaSem(nHC,"PLSA660C.SMF")
Endif

Return(lRet)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLS660VER  Ё Autor Ё Tulio Cesar         Ё Data Ё 16.10.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica processo de atualizacao...                        Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLS660Ver(cChavCon,nOpcx)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL lRet    := .T.
LOCAL nOrdBA3
LOCAL nRecBA3
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica Se pode Excluir...                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpcx == K_Excluir .Or. nOpcx == K_Alterar
   nOrdBA3 := BA3->(IndexOrd())
   nRecBA3 := BA3->(Recno())                
   
   BA3->(DbSetOrder(7))
   If BA3->(MsSeek(xFilial("BA3")+cChavCon))
      If     nOpcx == K_Excluir
             Help("",1,"PLSA660EX")
             lRet := .F.
      Endif
   Endif
   
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
Endif        

If lRet .And. Empty(dtos(M->BQB_DATINI))
   Help("",1,"PLSA660EX1")
   lRet := .F.
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorno da funcao...                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA660CAB Ё Autor Ё Tulio Cesar         Ё Data Ё 18.09.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Atualiza o cabecalho da tela no dialogo                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA660Cab(lRefresh)
DEFAULT lRefresh := .T.

cCodCon         := M->BT5_NUMCON
oSay02:cCaption := dtoc(M->BT5_DATCON)
//oSay03:cCaption := "" //M->BT5_CODCLI+"-"+M->BT5_LOJA+"  "+M->BT5_NOME

If lRefresh
   oSay01:Refresh()
   oSay02:Refresh()
  // oSay03:Refresh()
Endif

Return(.T.)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA660VLD Ё Autor Ё Tulio Cesar         Ё Data Ё 18.09.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Atualiza cabecalho a partir da saida da enchoice...        Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Vld()
LOCAL lRet := .F.

If M->BT5_COBNIV == "1" .And. Empty(M->BT5_CODCLI)
   Help("",1,"PLSA660VLD")
Else
   lRet := .T.
Endif   

If lRet
   cCodCon         := M->BT5_NUMCON
   oSay02:cCaption := dtoc(M->BT5_DATCON)
  // oSay03:cCaption := M->BT5_CODCLI+"-"+M->BT5_LOJA+"  "+M->BT5_NOME
Endif

Return(lRet)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLSA660DATЁ Autor Ё Michele Tatagiba      Ё Data Ё 22.05.02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Trata a data da versao do Grupo/Empresa                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Dat(cChave,dData)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva dados...                                                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nOrdBQB := BQB->(IndexOrd())
LOCAL nRecBQB := BQB->(Recno())
LOCAL dUltDat := dData
LOCAL lRet    := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a data informada e maior que a da ultima versao...      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BQB->(DbSetOrder(1))
BQB->(MsSeek(xFilial("BQB")+cChave+"999",.T.))
BQB->(DbSkip(-1))

If BQB->(BQB_FILIAL+BQB_CODIGO+BQB_NUMCON) == xFilial("BQB")+cChave
   dUltDat := BQB->BQB_DATINI
   If dtos(dData) > dtos(dUltDat)
      lRet := .T.
   Endif   
Else
   lRet := .T.
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura dados salvos...                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BQB->(DbSetOrder(nOrdBQB))
BQB->(DbGoTo(nRecBQB))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe help caso data seja errada...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lRet
   Help("",1,"PLSA660Dat")
Else
   If dtos(dData) < dtos(M->BT5_DATCON)
      MsgInfo(OemtoAnsi(STR0040)) //"Data da versao deve ser maior que a data do contrato"
      lRet := .F.
   Endif   
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)



/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA660   ╨Autor  ЁMicrosiga           ╨ Data Ё  03/15/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PLSA660Seq(cCodInt,cCodEmp,cConEmp)
LOCAL nRet    := 0
LOCAL nOrdBQB := BQB->(IndexOrd())                                    
LOCAL nTam    := Len(BQB->BQB_VERSAO)

BQB->(DbSetOrder(1))

BQB->(MsSeek(xFilial("BQB")+cCodInt+cCodEmp+cConEmp+Replicate("9",nTam),.T.))
BQB->(DbSkip(-1))
                                                           
If BQB->(BQB_FILIAL+BQB_CODIGO+BQB_NUMCON) <> xFilial("BQB")+cCodInt+cCodEmp+cConEmp
   nRet := StrZero(1,nTam)
Else
   nRet := StrZero(Val(BQB->BQB_VERSAO)+1,nTam)
Endif

BQB->(DbSetOrder(nOrdBQB))

Return(nRet)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLS660FilS Ё Autor Ё Michele Tatagiba   Ё Data Ё 03.06.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Modulo de Manutencao do Filtro dos SubContratos           Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS660FilS(cAlias,nReg,nOpc)                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PLSA660                                                   Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/              
Function PLS660FilS(nOpc, xnOrdem,  nRegOld)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis PRIVATE...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
PRIVATE aCores
PRIVATE aCdCores
PRIVATE bAjustBrw  := {|| oBrw := GetObjBrow(), PLSMONLEG(oBrw,aCdCores,aFilAdic[2]) }
PRIVATE aRotina   := {}
                        
PRIVATE cTitulo
PRIVATE cAlias    := "BQC"
PRIVATE cChave    := BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)
PRIVATE cChaveBQC := cChave

cMenu := 2

aRotina := MenuDef()

If Existblock("PLS660SC")
	If !(Execblock("PLS660SC",.F.,.F.,{nOpc}))
		Return
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama funcao de Browse...                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#IFDEF TOP
       PRIVATE cFiltro := "@BQC_FILIAL = '"+xFilial("BQC")+"' "
               cFiltro += " AND BQC_CODIGO = '"+Subs(cChaveBQC,1,8)+"' AND D_E_L_E_T_ = ' ' AND "
               cFiltro += " BQC_NUMCON = '"+Subs(cChaveBQC,9,12)+"' AND BQC_VERCON = '"+Subs(cChaveBQC,21,3)+"'"
#ELSE
       PRIVATE cFiltro := "BQC_FILIAL = '"+xFilial("BQC")+"' "
               cFiltro += " .AND. BQC_CODIGO = '"+Subs(cChaveBQC,1,8)+"' .AND.  "
               cFiltro += " BQC_NUMCON = '"+Subs(cChaveBQC,9,12)+"' .AND. BQC_VERCON = '"+Subs(cChaveBQC,21,3)+"'"
#ENDIF               
BQC->(DbSetOrder(1))   
DbSelectArea("BQC")
//SET FILTER TO &cFiltro
BQC->(MsSeek(xFilial("BQC")))
cTitulo   := "Grupo/Empresa"+" [ "+AllTrim(BG9->BG9_DESCRI)+" ] "
  
                            
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ALTERACAO DAHER LEGENDA												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCores   := {{"BQC->BQC_CODBLO <> Space(03)","BR_VERMELHO"} , {"BQC->BQC_CODBLO == Space(03)","BR_VERDE"}}  
aFilAdic := {.T.,"('01','02')"}
aCdCores := {{"BR_VERMELHO",OemtoAnsi(STR0044),"01"} , {"BR_VERDE",OemtoAnsi(STR0045) ,"02"}} //"Subcontrato Bloqueado"

BQC->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,nil,nil,nil,nil,4,aCores,nil,nil,nil,bAjustBrw,.F.,.F.,nil,cFiltro))

BT5->(DbSetOrder(1))   
DbSelectArea("BT5")

BT5->( dbSetorder(xnOrdem) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no Contrato Selecionado ...                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Incluir
   BT5->(DbGoTo(nRegOld))
Endif   

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA660LEG Ё Autor Ё Wagner Mobile Costa Ё Data Ё 04.10.03 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exibe a legenda...                                         Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Leg()

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA660Blq Ё Autor Ё Wagner Mobile Costa Ё Data Ё 04.10.03 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna valor para exibicao da legenda                     Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA660Blq()

Local nLeg 		:= nLido := nBlq := 0
Local cFor		:= 0
Local lFamilia  := .F.
Local cArea		:= Alias()

If cArea = "BT5"
	If BQC->(MsSeek(xFilial("BQC")+BT5->(BT5_CODINT+BT5->BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)))
		While 	! BQC->(Eof()) .And. BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON) =;
				xFilial("BQC") + BT5->(BT5_CODINT+BT5->BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)
		    If ! Empty(BQC->BQC_CODBLO)
		  		nBlq ++
		  	Endif
			nLido ++ 
			BQC->(DbSkip())
		EndDo          
	Endif
ElseIf cArea = "BG9"
    If BG9->BG9_TIPO = "1"
		cFor := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BA3") + " "
		cFor += "WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND "
		cFor += "BA3_CODINT = '" + BG9->BG9_CODINT + "' AND "
		cFor += "BA3_CODEMP = '" + BG9->BG9_CODIGO + "' AND "
		cFor += "BA3_MOTBLO <> ' ' AND D_E_L_E_T_ = ' '"
		lFamilia := .T.
    Else
		cFor := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BQC") + " "
		cFor += "WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "
		cFor += "BQC_CODIGO = '" + BG9->BG9_CODINT + BG9->BG9_CODIGO + "' AND "
		cFor += "BQC_CODBLO <> ' ' AND D_E_L_E_T_ = ' '"
    Endif
    
	cFor := ChangeQuery(cFor)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "BQCQRY", .F., .T.)
	nBlq := CONTADOR
	DbCloseArea()

    If BG9->BG9_TIPO = "1"
		cFor := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BA3") + " "
		cFor += "WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND "
		cFor += "BA3_CODINT = '" + BG9->BG9_CODINT + "' AND "
		cFor += "BA3_CODEMP = '" + BG9->BG9_CODIGO + "' AND "
		cFor += "D_E_L_E_T_ = ' '"
		lFamilia := .T.
    Else
		cFor := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BQC") + " "
		cFor += "WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "
		cFor += "BQC_CODIGO = '" + BG9->BG9_CODINT + BG9->BG9_CODIGO + "' AND "
		cFor += "D_E_L_E_T_ = ' '"
    Endif
    
	cFor := ChangeQuery(cFor)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "BQCQRY", .F., .T.)
	nLido := CONTADOR
	DbCloseArea()
Endif

If nBlq = 0
	nLeg := 0		// Ok
ElseIf nLido > 0 .And. nBlq < nLido
	nLeg := 1		// Parcialmente Bloqueado
ElseIf nLido = nBlq .Or. nBlq > nLido
	nLeg := 2		// Totalmente Bloqueado
Endif

If lFamilia .And. nLeg > 0
	nLeg += 2
Endif

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return nLeg

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA660Cob Ё Autor Ё Wagner Mobile Costa Ё Data Ё 05.11.03 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exibe valor de cobranca de um sub-contrato                 Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLS660Cob(cAlias)

If cAlias = "BG9"    //EMPRESA
	PLSCobGrp("","",1)
ElseIf cAlias = "BT5" //CONTRATO
	PLSCobGrp("","",2)
ElseIf cAlias = "BQC"  //SUB-CONTRATO
	PLSCobGrp("","",3)
Endif
  
Return



/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL660forma╨Autor  ЁGeraldo Felix Junior╨ Data Ё  25/02/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Traz a forma de cobranca e as faixas do produto para o     ╨╠╠
╠╠╨          Ёsub contrato automaticamente!!!                             ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/ 
Function PL660Forma(xxcCodFor)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara as variaveis de memoria...                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nCols       := 1, nHeader := nPos := nLido := 0
PRIVATE cCodQtd     := ""
PRIVATE nPosPro     := 0

PRIVATE nBT9_CODFOR := Ascan(aCabFor, {|x| Trim(x[2]) = "BT9_CODFOR"})
PRIVATE nBT9_DESFOR := Ascan(aCabFor, {|x| Trim(x[2]) = "BT9_DESFOR"})
PRIVATE nBT9_AUTOMA := Ascan(aCabFor, {|x| Trim(x[2]) = "BT9_AUTOMA"})
 
PRIVATE nBT9_CODPRO := Ascan(aCabFor, {|x| Trim(x[2]) = "BT9_CODPRO"})
PRIVATE nBT9_VERSAO := Ascan(aCabFor, {|x| Trim(x[2]) = "BT9_VERSAO"})

PRIVATE nCODFOR 	:= Ascan(oBrwFor:aCols, {|x| x[nBT9_CODPRO] = M->BT6_CODPRO .AND. x[nBT9_VERSAO] = M->BT6_VERSAO })
PRIVATE cSql
PRIVATE cAno		:= Str(Year(M->BQC_DATCON), 4), cMes := StrZero(Month(M->BQC_DATCON), 2)
PRIVATE cCodFor := ""       
DEFAULT xxcCodFor := ""       

cCodFor := xxcCodFor
        

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Esta rotina so sera processada na inclusao...                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
If nOpcx # K_Incluir
	Return .T.
Endif
*/

If 	Empty(M->BT6_CODPRO) .Or. Empty(M->BT6_VERSAO) 
	Return .T.
Endif                    

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o arquivo de faixas e faixa salarial do produto..			Ё
//| Primeiro procuro as faixas etarias, se encontrar pego ela, senao    |
//| procuro as faixas salariais, se encontrar pego ela senao retorno    |
//| sem levar faixa nenhuma												|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cCodFor)
   BB3->( dbSetorder(01) ) 
   If !BB3->( MsSeek(xFilial("BB3")+BT5->BT5_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) ) 
      If PLSALIASEX("B1A")
	     B1A->( dbSetorder(01) ) 
	     If !B1A->( MsSeek(xFilial("B1A")+BT5->BT5_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) )
	  	    Return(.T.)
         Else
		    cCodFor    := B1A->B1A_CODFOR
   	     Endif
      Else
         Return(.T.)
      Endif
   else 
	  cCodFor    := BB3->BB3_CODFOR
   endif
Endif

if cCodFor == "108"    
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega por faixa salarial...                                                                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PL660FSal()
else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega por faixa etaria...                                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PL660FEta()
endif                          

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza as formas de cobranca da taxa de adesao...                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PL660Adesao() 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Traz os opcionais vinculados e suas formas de cobranca...           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
If GetNewPar("MV_PLAUTOP", 1) == 1
	PL660OPCVIN()
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza Carencia p/ Novos Dependentes e Classe Carencia...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 

PL660AtCar() //Atualiza Carencia

// Atualiza os Grupos Determinados e os Procedimentos de Acordo com o produto
If GetNewPar("MV_PLAUTGP", .T.)
	PL660GDPro() 
EndIf

Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL660FEta  Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 11.03.04 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Carrega faixa etaria no subcontrato						 Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PL660FEta()                                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PL660FEta	                                             Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
                                          
function PL660FEta()
Local nHeader  
LOCAL oBak
LOCAL nCnt := 0
LOCAL nCampo1 := 0
LOCAL nCampo2 := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza as variaveis utilizadas pelo bFilter das tabelas filhas... Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
cCodProSel := M->BT6_CODPRO
cVersaoSel := M->BT6_VERSAO
		
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o arquivo de formas de cobranca...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
nPosVet := Ascan(aVetsFor, {|x|	x[01] = cCodFor 		.And. x[02] = "BTN" .and.;
								x[10] = M->BT6_CODPRO 	.and. X[11] = M->BT6_VERSAO })

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava a forma de cobranca no subcont5rato...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nCODFOR = 0
	If Empty(oBrwFor:aCols[1][nBT9_CODFOR])
		aAuxVar := aClone(oBrwFor:aCols)
		                                    
		aAuxVar[1][nBT9_CODPRO] := M->BT6_CODPRO
		aAuxVar[1][nBT9_VERSAO] := M->BT6_VERSAO
		
		aAuxVar[1][nBT9_CODFOR] := cCodFor
		aAuxVar[1][nBT9_DESFOR] := BJ1->BJ1_DESCRI
		aAuxVar[1][nBT9_AUTOMA] := "1"
		
		oBrwFor:SetArray(aAuxVar)
		nCodFor := 1
	Else
		oBrwFor:AddBlank()
		oBrwFor:FieldPut("BT9_CODPRO", M->BT6_CODPRO, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_VERSAO", M->BT6_VERSAO, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_CODFOR", cCodFor		, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_DESFOR", BJ1->BJ1_DESCRI	, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_AUTOMA", "1"			, Len(oBrwFor:aCols))
										
		nCodFor := Len(oBrwFor:aCols) 		
	Endif
	oBrwFor:ForceRefresh(oBrwFor)
	oBrwFor:oBrowse:oBrowse:lDisablePaint := .f.
	oBrwFor:oBrowse:oBrowse:Refresh()
	oBrwFor:oBrowse:oBrowse:lDisablePaint := .t.

Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reseta as variaveis de apoio...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aDados   := {}
aCabec   := {}
nCols    := 1
nLido    := 0                      

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa aHeader e o aCols das faixas do sub-contrato...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STORE HEADER "BTN" TO aCabec For .T.
Store COLS Blank "BTN" TO aDados FROM aCabec
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem a tabela de preco padrao do produto...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT * FROM " + RetSQLName("BB3")+" WHERE BB3_FILIAL = '"+xFilial("BB3")+"' AND "
cSQL += "BB3_CODIGO = '"+M->BQC_CODINT + M->BT6_CODPRO+"' AND "
cSQL += "BB3_VERSAO = '"+M->BT6_VERSAO+"' AND "
cSQL += "BB3_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BB3_CODFOR = '" + cCodFor + "' AND "
cSQL += "(BB3_TABVLD  >= '"+Dtos(dDatabase)+"' OR "
cSQL += "BB3_TABVLD  >= '"+Space(TamSX3("BB3_TABVLD")[1])+ "')  AND "	
cSQL += "D_E_L_E_T_= '' 
cSQL += "ORDER BY BB3_TIPUSR DESC ,BB3_GRAUPA DESC ,BB3_SEXO DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"TrbBB3",.f.,.t.)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa a tabela de precos do produto...                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! TrbBB3->(Eof())
	nCnt ++
	nLido ++
	If nLido > nCols
		Aadd(aDados, AClone(aDados[1]))
		nCols ++
	Endif
	For nHeader := 1 To Len(aCabec)
		
		If aCabec[nHeader][2] = "BTN_CODPRO"
			aDados[nCols][nHeader] := M->BT6_CODPRO
		
		Elseif aCabec[nHeader][2] = "BTN_VERPRO"                    
			aDados[nCols][nHeader] := M->BT6_VERSAO
		
		ElseIf aCabec[nHeader][2] = "BTN_AUTOMA"
			aDados[nCols][nHeader] := "1"
	
		ElseIf aCabec[nHeader][2] == "BTN_TABVLD"
			nCampo1 := nHeader
		ElseIf aCabec[nHeader][2] == "BTN_PERREJ"
			nCampo2 := nHeader
		Elseif (nPos := TrbBB3->(FieldPos(StrTran(aCabec[nHeader][2], "BTN", "BB3")))) > 0
			If TamSX3( aCabec[nHeader][2])[3] = "D"
				aDados[nCols][nHeader] := sTod(TrbBB3->(FieldGet(nPos)))
			Else
				aDados[nCols][nHeader] := TrbBB3->(FieldGet(nPos))
			Endif	
		EndIf
		
	Next

   	Pl260AtuVar(aCabec, aDados, nCols)

	TrbBB3->(DbSkip())

EndDo
TrbBB3->(DbCloseArea())

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza o array padrao da forma de cobranca...                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLido > 0 .AND. INCLUI 
	If nPosVet == 0 
		aadd(aVetsFor,{cCodFor,"BTN","1",aClone(aDados),{},BT5->BT5_NUMCON,cPLSVersao,;
		M->BQC_SUBCON,M->BQC_VERSUB,M->BT6_CODPRO,M->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
	Else
		aVetsFor[nPosVet][4] := aClone(aDados) 
	EndIf
Endif
                                                                    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reseta as variaveis de apoio para utiliza-las para os descontos...  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosVet := Ascan(aVetsFor, {|x|	x[01] = cCodFor 		.And. x[02] = "BFT" .and. ;
								x[10] = M->BT6_CODPRO 	.and. X[11] = M->BT6_VERSAO })
aDados   := {}
aCabec   := {}
nCols    := 1
nLido    := 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o aHeader e o aCols dos descontos...                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STORE HEADER "BFT" TO aCabec For .T.
Store COLS Blank "BFT" TO aDados FROM aCabec

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona tabela de descontos padroes do produto...                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BFS->(DbSetOrder(1))
BFS->(MsSeek(	xFilial("BFS") + BT5->BT5_CODINT + M->BT6_CODPRO + M->BT6_VERSAO +;
cCodFor))

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё processa os descontos do produto...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While 	! BFS->(Eof()) .AND. BFS->BFS_FILIAL = xFilial("BFS") .And.;
	BFS->BFS_CODIGO = BT5->BT5_CODINT + M->BT6_CODPRO .And.;
	BFS->BFS_VERSAO = M->BT6_VERSAO .And. BFS->BFS_CODFOR = cCodFor 
	nLido ++                 
	
	If nLido > nCols
		Aadd(aDados, AClone(aDados[1]))
		nCols ++
	Endif
	
	For nHeader := 1 To Len(aCabec)
		If aCabec[nHeader][2] = "BFT_CODPRO"
			aDados[nCols][nHeader] := M->BT6_CODPRO
		
		Elseif aCabec[nHeader][2] = "BFT_VERPRO"                    
			aDados[nCols][nHeader] := M->BT6_VERSAO

		ElseIf aCabec[nHeader][2] = "BFT_AUTOMA"
			aDados[nCols][nHeader] := "1"
			
		Elseif (nPos := BFS->(FieldPos(StrTran(aCabec[nHeader][2], "BFT", "BFS")))) > 0
			aDados[nCols][nHeader] := BFS->(FieldGet(nPos))
			
		Endif
	Next
	
	Pl260AtuVar(aCabec, aDados, nCols)
	
	BFS->(DbSkip())
EndDo

If nLido > 0
	If nPosVet = 0
		aadd(aVetsFor,{cCodFor,"BFT","1",aClone(aDados),{},BT5->BT5_NUMCON,cPLSVersao,;
				M->BQC_SUBCON,M->BQC_VERSUB,M->BT6_CODPRO,M->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
	Endif
Endif

If ExistBlock("PL660FETA")
   oBak := oDlgFolder
   ExecBlock("PL660FETA",.F.,.F.)
   oDlgFolder := oBak
Endif             

return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL660FSal  Ё Autor ЁDaher			   Ё Data Ё 24.02.05 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Carrega faixa salarial no subcontrato					 Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PL660FSal()                                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PL660FSal	                                             Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
                        
function PL660FSal()
Local nHeader
local nCodSeq := 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza as variaveis utilizadas pelo bFilter das tabelas filhas... Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
cCodProSel := M->BT6_CODPRO
cVersaoSel := M->BT6_VERSAO
		
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o arquivo de formas de cobranca...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
nPosVet := Ascan(aVetsFor, {|x|	x[01] = cCodFor 		.And. x[02] = "B1B" .and.;
								x[10] = M->BT6_CODPRO 	.and. X[11] = M->BT6_VERSAO })

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava a forma de cobranca no subcont5rato...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nCODFOR = 0
	If Empty(oBrwFor:aCols[1][nBT9_CODFOR])
		aAuxVar := aClone(oBrwFor:aCols)
		                                    
		aAuxVar[1][nBT9_CODPRO] := M->BT6_CODPRO
		aAuxVar[1][nBT9_VERSAO] := M->BT6_VERSAO
		
		aAuxVar[1][nBT9_CODFOR] := cCodFor
		aAuxVar[1][nBT9_DESFOR] := BJ1->BJ1_DESCRI
		aAuxVar[1][nBT9_AUTOMA] := "1"
		
		oBrwFor:SetArray(aAuxVar)
		nCodFor := 1
	Else
		oBrwFor:AddBlank()
		oBrwFor:FieldPut("BT9_CODPRO", M->BT6_CODPRO, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_VERSAO", M->BT6_VERSAO, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_CODFOR", cCodFor		, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_DESFOR", BJ1->BJ1_DESCRI	, Len(oBrwFor:aCols))
		oBrwFor:FieldPut("BT9_AUTOMA", "1"			, Len(oBrwFor:aCols))
										
		nCodFor := Len(oBrwFor:aCols) 		
	Endif
	oBrwFor:ForceRefresh(oBrwFor)
	oBrwFor:oBrowse:oBrowse:lDisablePaint := .f.
	oBrwFor:oBrowse:oBrowse:Refresh()
	oBrwFor:oBrowse:oBrowse:lDisablePaint := .t.

Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reseta as variaveis de apoio...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aDados   := {}
aCabec   := {}
nCols    := 1
nLido    := 0                      

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa aHeader e o aCols das faixas do sub-contrato...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STORE HEADER "B1B" TO aCabec For .T.
Store COLS Blank "B1B" TO aDados FROM aCabec
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem a tabela de preco padrao do produto...                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cSQL := "SELECT * FROM " + RetSQLName("B1A")+" WHERE B1A_FILIAL = '"+xFilial("B1A")+"' AND "
cSQL += "B1A_CODIGO = '" + M->BQC_CODINT   + M->BT6_CODPRO+"' AND "
cSQL += "B1A_VERSAO = '" + M->BT6_VERSAO   +"' AND "
cSQL += "B1A_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND B1A_CODFOR = '" + cCodFor + "' AND "
cSQL += "D_E_L_E_T_= '' "
cSQL += "ORDER BY B1A_VLSLIN, B1A_VLSLFN"
	
PLSQuery(cSQL,"TrbB1A")

While ! TrbB1A->(Eof())
	nLido ++
	If nLido > nCols
		Aadd(aDados, AClone(aDados[1]))
		nCols ++
	Endif
	For nHeader := 1 To Len(aCabec)
		If  (nPos := TrbB1A->(FieldPos(strtran(aCabec[nHeader][2],"B1B","B1A")))) > 0
			aDados[nCols][nHeader] := TrbB1A->(FieldGet(nPos))
		ElseIf aCabec[nHeader][2] = "B1B_AUTOMA"
			aDados[nCols][nHeader] := "1"
		Endif
	Next
	Pl260AtuVar(aCabec, aDados, nCols)
	TrbB1A->(DbSkip())
EndDo
TrbB1A->(DbCloseArea())

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza o array padrao da forma de cobranca...                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLido > 0
	If nPosVet = 0
		aadd(aVetsFor,{cCodFor,"B1B","1",aClone(aDados),{},BT5->BT5_NUMCON,cPLSVersao,;
		M->BQC_SUBCON,M->BQC_VERSUB,M->BT6_CODPRO,M->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega os grupos de quantidade, caso exista a tabela B1G           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
If PLSALIASEXI("B1G") .AND. PLSALIASEXI("B1F")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reseta as variaveis de apoio...                                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aDados   := {}
	aCabec   := {}
	nCols    := 1
	nLido    := 0
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa aHeader e o aCols das faixas do sub-contrato...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	STORE HEADER "B1G" TO aCabec For .T.
	Store COLS Blank "B1G" TO aDados FROM aCabec
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem a tabela de preco padrao do produto...                        Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	cSQL := "SELECT * FROM " + RetSQLName("B1F")+" WHERE B1F_FILIAL = '"+xFilial("B1F")+"' AND "
	cSQL += "B1F_CODIGO = '" + M->BQC_CODINT   + M->BT6_CODPRO+"' AND "
	cSQL += "B1F_VERSAO = '" + M->BT6_VERSAO   +"' AND "
	cSQL += "B1F_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND " 
	cSQL += "B1F_CODFOR = '" + cCodFor + "' AND "
	cSQL += "D_E_L_E_T_= '' "
	cSQL += "ORDER BY B1F_QTDINI, B1F_QTDFIN"
	
	PLSQuery(cSQL,"TrbB1F")
	
	While ! TrbB1F->(Eof())
		nLido ++
		If nLido > nCols
			Aadd(aDados, AClone(aDados[1]))
			nCols ++
		Endif
		
		nCodSeq ++
		For nHeader := 1 To Len(aCabec)
			If  (nPos := TrbB1F->(FieldPos(strtran(aCabec[nHeader][2],"B1G","B1F")))) > 0
				aDados[nCols][nHeader] := TrbB1F->(FieldGet(nPos))     
				
			ElseIf aCabec[nHeader][2] = "B1G_AUTOMA"
				aDados[nCols][nHeader] := "1"   
				
			ElseIf aCabec[nHeader][2] = "B1G_CODPRO" 
				aDados[nCols][nHeader] := M->BT6_CODPRO 
				
			ElseIf aCabec[nHeader][2] = "B1G_VERPRO" 
				aDados[nCols][nHeader] := M->BT6_VERSAO    
				  
			ElseIf aCabec[nHeader][2] = "B1G_CODSEQ" 
				aDados[nCols][nHeader] := StrZero(nCodSeq, Len(B1G->B1G_CODSEQ))
				
			Endif
		Next
		Pl260AtuVar(aCabec, aDados, nCols)
		TrbB1F->(DbSkip())
	EndDo
	TrbB1F->(DbCloseArea())
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o array padrao da forma de cobranca...                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nLido > 0
		If nPosVet = 0
			aadd(aVetsFor,{cCodFor,"B1G","1",aClone(aDados),{},BT5->BT5_NUMCON,cPLSVersao,;
			M->BQC_SUBCON,M->BQC_VERSUB,M->BT6_CODPRO,M->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
		Endif
	Endif
Endif

return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL660AdesaoЁ Autor ЁGeraldo Felix JuniorЁ Data Ё 11.03.04 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Sugere as formas de cobranca de adesao de acordo produto  Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PL260Adesao()                                             Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PL260Adesao                                               Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PL660Adesao()

Local nCols := 1, nHeader := 0
Local nPos := 0
Local nLido := 0

Local nBTK_CODFOR := Ascan(aCabAde, {|x| Trim(x[2]) = "BTK_CODFOR"})
Local nBTK_DESFOR := Ascan(aCabAde, {|x| Trim(x[2]) = "BTK_DESFOR"})
Local nBTK_AUTOMA := Ascan(oBrwFor:aHeader, {|x| Trim(x[2]) = "BTK_AUTOMA"})

Local nBTK_CODPRO := Ascan(aCabAde, {|x| Trim(x[2]) = "BTK_CODPRO"})
Local nBTK_VERSAO := Ascan(aCabAde, {|x| Trim(x[2]) = "BTK_VERSAO"})

Local nCODFOR 	  := 0 
Local nI		  := 1
/*
If nOpcx # K_Incluir
	Return .T.
Endif
*/
                                                                         
BJ9->( dbSetorder(01) ) 
If !BJ9->( MsSeek(xFilial("BJ9")+BT5->BT5_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) )
	Return .T.
Endif

cCodFor := BJ9->BJ9_CODFOR
nCODFOR := Ascan(aVetsTxF, {|x|	x[01] = M->BT6_CODPRO .and. x[02] = M->BT6_VERSAO .and. x[03] = cCodFor  })
nTxAds := Ascan(oBrwAde:aCols, {|x|	x[nBTK_CODPRO] = M->BT6_CODPRO .and. x[nBTK_VERSAO] = M->BT6_VERSAO .and. !Empty(x[nBTK_CODFOR])  })

If 	Empty(M->BT6_CODPRO) .Or. Empty(M->BT6_VERSAO) .Or. Empty(cCodFor)
	Return .T.
Endif

nPosVet := Ascan(aVetsTxF, {|x|	x[01] = cCodFor .And. 		x[02] = "BR6" .and.;
								x[10] = M->BT6_CODPRO .and.	x[11] = M->BT6_VERSAO })

If nTxAds = 0
	
	If Empty(oBrwAde:aCols[1][nBTK_CODFOR])     
		BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
		
		oBrwAde:aCols[1][nBTK_CODPRO] := M->BT6_CODPRO
		oBrwAde:aCols[1][nBTK_VERSAO] := M->BT6_VERSAO
		
		oBrwAde:aCols[1][nBTK_CODFOR] := cCodFor
		oBrwAde:aCols[1][nBTK_DESFOR] := BJ1->BJ1_DESCRI
		nCodFor := 1
	Else
		BJ1->(MsSeek(xFilial("BJ1") + cCodFor))                  		
		oBrwAde:AddBlank()
		oBrwAde:SetPos(Len(oBrwAde:aCols))
		
		oBrwAde:aCols[Len(oBrwAde:aCols)][nBTK_CODPRO] := M->BT6_CODPRO
		oBrwAde:aCols[Len(oBrwAde:aCols)][nBTK_VERSAO] := M->BT6_VERSAO
		
		oBrwAde:aCols[Len(oBrwAde:aCols)][nBTK_CODFOR] := cCodFor
		oBrwAde:aCols[Len(oBrwAde:aCols)][nBTK_DESFOR] := BJ1->BJ1_DESCRI
		If  nBTK_AUTOMA > 0
   		    oBrwAde:aCols[Len(oBrwFor:aCols)][nBTK_AUTOMA] := "1"
   		Endif    
		
		nCodFor := Len(oBrwAde:aCols)
		
		Aadd(oBrwAde:aVetTrab, 0)
	Endif
	oBrwAde:ForceRefresh(oBrwAde)
Endif                                   

aDados 	 := {}
aCabec 	 := {}
nCols    := 1
nLido    := 0

STORE HEADER "BR6" TO aCabec For .T.
Store COLS Blank "BR6" TO aDados FROM aCabec

BRY->(DbSetOrder(1))
BRY->(MsSeek(	xFilial("BRY") + BT5->BT5_CODINT + M->BT6_CODPRO + M->BT6_VERSAO +;
cCodFor))
While ! BRY->(Eof()) .and. BRY->BRY_FILIAL = xFilial("BRY") .And.;
	BRY->BRY_CODIGO = BT5->BT5_CODINT + M->BT6_CODPRO .And.;
	BRY->BRY_VERSAO = M->BT6_VERSAO .And. BRY->BRY_CODFOR = cCodFor 

	nLido ++
	If nLido > nCols
		Aadd(aDados, AClone(aDados[1]))
		nCols ++
	Endif
	
	For nHeader := 1 To Len(aCabec)

		If aCabec[nHeader][2] = "BR6_CODPRO"
			aDados[nCols][nHeader] := M->BT6_CODPRO
		
		Elseif aCabec[nHeader][2] = "BR6_VERPRO"                    
			aDados[nCols][nHeader] := M->BT6_VERSAO
	
		ElseIf aCabec[nHeader][2] = "BR6_AUTOMA"
			aDados[nCols][nHeader] := "1"

		Elseif (nPos := BRY->(FieldPos(StrTran(aCabec[nHeader][2], "BR6", "BRY")))) > 0
			aDados[nCols][nHeader] := BRY->(FieldGet(nPos))
		Endif
	Next
	
	Pl260AtuVar(aCabec, aDados, nCols)
	
	BRY->(DbSkip())
EndDo

If nLido > 0
	If nPosVet = 0
		aadd(aVetsTxF,{cCodFor,"BR6",'1',aDados,{},;
		BT5->BT5_NUMCON,BT5->BT5_VERSAO,M->BQC_SUBCON,BQC->BQC_VERSUB,;
		M->BT6_CODPRO  ,BT6->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
	Endif
Endif

nPosVet := Ascan(aVetsTxF, {|x|	x[01] = cCodFor 		.And. x[02] = "BFV" .and.;
								x[10] = M->BT6_CODPRO 	.and. X[11] = M->BT6_VERSAO })
aDados 	 := {}
aCabec   := {}
nCols    := 1
nLido    := 0

STORE HEADER "BFV" TO aCabec For .T.
Store COLS Blank "BFV" TO aDados FROM aCabec

BFX->(DbSetOrder(1))
BFX->(MsSeek(	xFilial("BFX") + BT5->BT5_CODINT + M->BT6_CODPRO + M->BT6_VERSAO + cCodFor))

While !BFX->(Eof()) .AND. BFX->BFX_FILIAL = xFilial("BFX") .And.;
	BFX->BFX_CODIGO = BT5->BT5_CODINT + M->BT6_CODPRO .And.;
	BFX->BFX_VERSAO = M->BT6_VERSAO .And. BFX->BFX_CODFOR = cCodFor
	
	nLido ++
	If nLido > nCols
		Aadd(aDados, AClone(aDados[1]))
		nCols ++
	Endif
	
	For nHeader := 1 To Len(aCabec)
		If aCabec[nHeader][2] = "BFV_CODPRO"
			aDados[nCols][nHeader] := M->BT6_CODPRO
			
		Elseif aCabec[nHeader][2] = "BFV_VERPRO"
			aDados[nCols][nHeader] := M->BT6_VERSAO
			
		ElseIf aCabec[nHeader][2] = "BFV_AUTOMA"
			aDados[nCols][nHeader] := "1"
			
		Elseif (nPos := BFX->(FieldPos(StrTran(aCabec[nHeader][2], "BFV", "BFX")))) > 0
			aDados[nCols][nHeader] := BFX->(FieldGet(nPos))
		Endif
	Next
	Pl260AtuVar(aCabec, aDados, nCols)
	
	BFX->(DbSkip())
EndDo

If nLido > 0
	If nPosVet = 0	
		aadd(aVetsTxF,{cCodFor,"BFV",'1',aDados,{},;
		BT5->BT5_NUMCON,BT5->BT5_VERSAO,M->BQC_SUBCON,BQC->BQC_VERSUB,;
		M->BT6_CODPRO  ,BT6->BT6_VERSAO,cCodFor+M->BT6_CODPRO+M->BT6_VERSAO})
	Endif
Endif

Return .T.
                             
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL660OPCVINЁ Autor ЁGeraldo Felix JuniorЁ Data Ё 25.03.04 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Sugere as formas de cobranca de adesao de acordo produto  Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PL260Adesao()                                             Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PL260Adesao                                               Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PL660OPCVIN()
Local nCols 	:= 1
Local i
Local nHeader 	:= 0
Local nPos 		:= 0
Local nLido 	:= 0
Local lContinua := .F.
Local nRecBT3	:= 0    
LOCAL lForcRefr := .F.
LOCAL aControl	:= {}
LOCAL cKeyBJY	:= ''
LOCAL cKeyBBV	:= ''
            
LOCAL nPosVet := Ascan(aVetsOpc, {|x|	x[01] = cCodFor .And. 		x[02] = "BBX" .and.;
										x[10] = M->BT6_CODPRO .and.	x[11] = M->BT6_VERSAO })
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicoes do array do produto relacionado...                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nBHS_CODPRO := oBrwOpc:FieldPos("BHS_CODPRO", aCabOpc)    //Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_CODPRO"})
Local nBHS_VERPRO := oBrwOpc:FieldPos("BHS_VERPRO", aCabOpc)	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_VERPRO"})
Local nBHS_CODPLA := oBrwOpc:FieldPos("BHS_CODPLA", aCabOpc) 	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_CODPLA"})
Local nBHS_VERPLA := oBrwOpc:FieldPos("BHS_VERPLA", aCabOpc) 	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_VERPLA"})
Local nBHS_DESPLA := oBrwOpc:FieldPos("BHS_DESPLA", aCabOpc) 	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_DESPLA"})
Local nBHS_TIPVIN := oBrwOpc:FieldPos("BHS_TIPVIN", aCabOpc) 	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_TIPVIN"})
Local nBHS_IMPCAR := oBrwOpc:FieldPos("BHS_IMPCAR", aCabOpc) 	//Ascan(aCabOpc, {|x| Trim(x[2]) = "BHS_IMPCAR"})
          
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicoes do array das formas de cobranca do opcinal nao vinculado...Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nBJW_CODPRO := oBrwFrOpc:FieldPos("BJW_CODPRO", aCabFrOpc) 
LOCAL nBJW_VERSAO := oBrwFrOpc:FieldPos("BJW_VERSAO", aCabFrOpc) 
LOCAL nBJW_CODOPC := oBrwFrOpc:FieldPos("BJW_CODOPC", aCabFrOpc) 
LOCAL nBJW_VEROPC := oBrwFrOpc:FieldPos("BJW_VEROPC", aCabFrOpc) 
LOCAL nBJW_CODFOR := oBrwFrOpc:FieldPos("BJW_CODFOR", aCabFrOpc) 
LOCAL nBJW_RGIMP  := oBrwFrOpc:FieldPos("BJW_RGIMP" , aCabFrOpc) 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё So Disponivel na inclusao...                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
If nOpcx # K_Incluir
	Return .T.
Endif
*/
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abandona a rotina se nao for informado nenhum produto no sub contr..Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If 	Empty(M->BT6_CODPRO) .Or. Empty(M->BT6_VERSAO) .Or. Empty(cCodFor)
	Return .T.
Endif
 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe opcionais vinculados no produto...               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
BT3->( dbSetorder(01) ) 
If !BT3->( MsSeek(xFilial("BT3")+BT5->BT5_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) )
	Return .T.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Adiciona os opcionais vinculados ao sub contrato...                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
While !BT3->( Eof() ) .and. BT3->(BT3_CODIGO+BT3_VERSAO) == BT5->BT5_CODINT+M->BT6_CODPRO+M->BT6_VERSAO

	If (nPos := Ascan(oBrwOpc:aCols, {|x| 	x[nBHS_CODPRO] == Substr(BT3->BT3_CODIGO,5,4) .and.;
											x[nBHS_VERPRO] == BT3->BT3_VERSAO .and.;
											x[nBHS_CODPLA] == BT3->BT3_CODPLA .and.;
											x[nBHS_VERPLA] == BT3->BT3_VERPLA} )) == 0
	
	
		lForcRefr := .T.
		If Empty(oBrwOpc:aCols[1][nBHS_CODPLA])
			oBrwOpc:aCols[1][nBHS_CODPRO] := Substr(BT3->BT3_CODIGO,5,4)
			oBrwOpc:aCols[1][nBHS_VERPRO] := BT3->BT3_VERSAO
			oBrwOpc:aCols[1][nBHS_CODPLA] := BT3->BT3_CODPLA
			oBrwOpc:aCols[1][nBHS_VERPLA] := BT3->BT3_VERPLA
			oBrwOpc:aCols[1][nBHS_DESPLA] := Posicione("BI3",1,xFilial("BI3")+BT3->(SUBSTR(BT3_CODIGO,1,4)+BT3_CODPLA+BT3_VERPLA),"BI3_DESCRI")
			oBrwOpc:aCols[1][nBHS_TIPVIN] := BT3->BT3_TIPVIN
			oBrwOpc:aCols[1][nBHS_IMPCAR] := BT3->BT3_IMPCAR
		Else    	 
			// Existe casos em que o acols eh inicializado com duas linhas.                                
			If !Empty(oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_CODPRO])
				Aadd(oBrwOpc:aCols, AClone(oBrwOpc:aCols[1]))
			Endif
		
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_CODPRO] := Substr(BT3->BT3_CODIGO,5,4)
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_VERPRO] := BT3->BT3_VERSAO
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_CODPLA] := BT3->BT3_CODPLA
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_VERPLA] := BT3->BT3_VERPLA
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_DESPLA] := Posicione("BI3",1,xFilial("BI3")+BT3->(SUBSTR(BT3_CODIGO,1,4)+BT3_CODPLA+BT3_VERPLA),"BI3_DESCRI")
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_TIPVIN] := BT3->BT3_TIPVIN
			oBrwOpc:aCols[Len(oBrwOpc:aCols)][nBHS_IMPCAR] := BT3->BT3_IMPCAR
			Aadd(oBrwOpc:AvetTrab,0)
		Endif
	
		If BT3->BT3_TIPVIN == '1'
			Aadd(aControl, {BT3->( Recno() ), .F.} )	
		Else
			Aadd(aControl, {BT3->( Recno() ), .T.} )		
		Endif
	Endif
	
	BT3->( dbSkip() )
Enddo

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Liga o lAltered do objeto para a classe poder gravar...             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAuxOpc := Aclone(oBrwOpc:aCols)
If lForcRefr
	oBrwOpc:SetArray(aAuxOpc)
	oBrwOpc:lAltered := .T.      
	oBrwOpc:ForceRefresh(oBrwPro)
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Adiciona as formar de cobranca dos opcionais nao vinculados...      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

For i := 1 To  Len(aControl)
	If 	aControl[i][2]
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reposiciona produto relacionado...                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BT3->( dbGoto(aControl[i][1]) )
		BJY->( dbSetorder(01) )
		cKeyBJY := BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)
		
		If BJY->(MsSeek(xFilial("BJY")+cKeyBJY) )
			While !BJY->( Eof() ) .and. BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona forma de cobranca...                                      Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				    
				BJ1->(MsSeek(xFilial("BJ1") + BJY->BJY_CODFOR))

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Preenche as formas de cobranca...                                   Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				    				
				If Empty(oBrwFrOpc:FieldGet("BJW_CODFOR", 1))
					oBrwFrOpc:FieldPut("BJW_CODPRO", cCodProSel  	, 1)
					oBrwFrOpc:FieldPut("BJW_VERSAO", cVersaoSel		, 1)
					oBrwFrOpc:FieldPut("BJW_CODOPC", BT3->BT3_CODPLA, 1)
					oBrwFrOpc:FieldPut("BJW_VEROPC", BT3->BT3_VERPLA, 1)
					oBrwFrOpc:FieldPut("BJW_CODFOR", BJY->BJY_CODFOR, 1)
					oBrwFrOpc:FieldPut("BJW_DESFOR", BJ1->BJ1_DESCRI, 1)
					
					nCodFor := 1
				Else                                               
					If !Empty(oBrwFrOpc:aCols[Len(oBrwFrOpc:aCols)][3])
						Aadd(oBrwFrOpc:aCols, AClone(oBrwFrOpc:aCols[1]))
					Endif
					nCodFor := Len(oBrwFrOpc:aCols)

					oBrwFrOpc:FieldPut("BJW_CODPRO", cCodProSel  	, nCodFor)
					oBrwFrOpc:FieldPut("BJW_VERSAO", cVersaoSel		, nCodFor)
					oBrwFrOpc:FieldPut("BJW_CODOPC", BT3->BT3_CODPLA, nCodFor)
					oBrwFrOpc:FieldPut("BJW_VEROPC", BT3->BT3_VERPLA, nCodFor)
					oBrwFrOpc:FieldPut("BJW_CODFOR", BJY->BJY_CODFOR, nCodFor)
					oBrwFrOpc:FieldPut("BJW_DESFOR", BJ1->BJ1_DESCRI, nCodFor)
					Aadd(oBrwFrOpc:AvetTrab,0)
					
				Endif            
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Preenche os valores das faixas da forma de cobranca...              Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

				BBV->( dbSetorder(01) )
				cKeyBBV := BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC+BJY_CODFOR)
				If BBV->( MsSeek(xFilial("BBV")+cKeyBBV) )

					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Reseta variaveis auxiliares...                                      Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
					aDados 	 := {}
					aCabec 	 := {}
					nCols    := 1
					nLido    := 0

					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Define aHeader e aCols auxiliares...                                Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					STORE HEADER "BBX" TO aCabec For .T.
					Store COLS Blank "BBX" TO aDados FROM aCabec								
					
					While !BBV->( Eof() ) .and. BBV->(BBV_CODIGO+BBV_VERSAO+BBV_CODOPC+BBV_VEROPC+BBV_CODFOR) == cKeyBBV

						nLido ++
						If nLido > nCols
							Aadd(aDados, AClone(aDados[1]))
							nCols ++
						Endif
	
						For nHeader := 1 To Len(aCabec)
							If aCabec[nHeader][2] = "BBX_CODPRO"
								aDados[nCols][nHeader] := M->BT6_CODPRO
		
							Elseif aCabec[nHeader][2] = "BBX_VERPRO"                    
  								aDados[nCols][nHeader] := M->BT6_VERSAO
 	    	
							ElseIf aCabec[nHeader][2] = "BBX_RGIMP"
								aDados[nCols][nHeader] := "1"
                    	
							Elseif (nPos := BBV->(FieldPos(StrTran(aCabec[nHeader][2], "BBX", "BBV")))) > 0
								aDados[nCols][nHeader] := BBV->(FieldGet(nPos))
							Endif   	
						Next
	
						Pl260AtuVar(aCabec, aDados, nCols)
						BBV->( dbSkip() )
					Enddo
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Alimenta matriz dinamica com os valores das faixas de cada opcional...Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды					
					If nLido > 0
						If nPosVet = 0
							aadd(aVetsOpc,{BJY->BJY_CODFOR,"BBX",'1',aDados,{},;
								BT5->BT5_NUMCON,BT5->BT5_VERSAO,M->BQC_SUBCON,BQC->BQC_VERSUB,;
								M->BT6_CODPRO  ,BT6->BT6_VERSAO,BJY->BJY_CODFOR+M->BT6_CODPRO+M->BT6_VERSAO+BJY->(BJY_CODOPC+BJY_VEROPC)})
						Endif
					Endif										
				Endif
				
				BJY->( dbSkip() )
			Enddo
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Liga o lAltered do objeto para a classe poder gravar...             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oBrwFrOpc:lAltered := .T.
		If TYPE("oBrwBBX") == 'O'
			oBrwBBX:lAltered   := .T.
		Endif
	Endif
Next

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza os descontos das faixas etarias do opcional...             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLido := 0
For i := 1 To  Len(aControl)
	If 	aControl[i][2]
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reposiciona produto relacionado...                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BT3->( dbGoto(aControl[i][1]) )
		BJY->( dbSetorder(01) )
		cKeyBJY := BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)
		
		If BJY->(MsSeek(xFilial("BJY")+cKeyBJY) )
			While !BJY->( Eof() ) .and. BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona forma de cobranca...                                      Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BJ1->(MsSeek(xFilial("BJ1") + BJY->BJY_CODFOR))

				BBV->( dbSetorder(01) )
				cKeyBBV := BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC+BJY_CODFOR)
				If BBV->( MsSeek(xFilial("BBV")+cKeyBBV) )
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Posiciona descontos da forma de cobranca...                         Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды					
					BFW->( dbSetorder(01) )
					If BFW->( MsSeek(xFilial("BFW")+cKeyBBV) )
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Reseta variaveis auxiliares...                                      Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						aDados 	 := {}
						aCabec 	 := {}
						nCols    := 1
						nLido    := 0
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Define aHeader e aCols auxiliares...                                Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						STORE HEADER "BGW" TO aCabec For .T.
						Store COLS Blank "BGW" TO aDados FROM aCabec
						
						While !BFW->( Eof() ) .and. BFW->(BFW_CODIGO+BFW_VERSAO+BFW_CODOPC+BFW_VEROPC+BFW_CODFOR) == cKeyBBV
							
							nLido ++
							If nLido > nCols
								Aadd(aDados, AClone(aDados[1]))
								nCols ++
							Endif
							
							For nHeader := 1 To Len(aCabec)
								If aCabec[nHeader][2] = "BGW_CODPRO"
									aDados[nCols][nHeader] := M->BT6_CODPRO
									
								Elseif aCabec[nHeader][2] = "BGW_VERPRO"
									aDados[nCols][nHeader] := M->BT6_VERSAO
									
								ElseIf aCabec[nHeader][2] = "BGW_RGIMP"
									aDados[nCols][nHeader] := "1"
									                             
								ElseIf aCabec[nHeader][2] = "BGW_DATDE"
									aDados[nCols][nHeader] := dDatabase
									
								Elseif (nPos := BFW->(FieldPos(StrTran(aCabec[nHeader][2], "BGW", "BFW")))) > 0
									aDados[nCols][nHeader] := BFW->(FieldGet(nPos))
								Endif
							Next
							
							Pl260AtuVar(aCabec, aDados, nCols)
							BFW->( dbSkip() )
						Enddo
					Endif
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Alimenta matriz dinamica com os valores das faixas de cada opcional...Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If nLido > 0
						If nPosVet = 0
							aadd(aVetsOpc,{BJY->BJY_CODFOR,"BGW",'1',aDados,{},;
							BT5->BT5_NUMCON,BT5->BT5_VERSAO,M->BQC_SUBCON,BQC->BQC_VERSUB,;
							M->BT6_CODPRO  ,BT6->BT6_VERSAO,BJY->BJY_CODFOR+M->BT6_CODPRO+M->BT6_VERSAO+BJY->(BJY_CODOPC+BJY_VEROPC)})
						Endif
						nLido := 0
					Endif
				Endif
				
				BJY->( dbSkip() )
			Enddo
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Liga o lAltered do objeto para a classe poder gravar...             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oBrwFrOpc:lAltered := .T.
		If TYPE("oBrwBGW") == 'O'
			oBrwBGW:lAltered   := .T.
		Endif
	Endif
Next

Return .T.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL660AtCar Ё Autor ЁLuciano Aparecido   Ё Data Ё 26.09.07 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Sugere Carencia Novos Dependentes e Classe de Carencia de Ё╠╠
╠╠Ё          Ё de acordo com produto para ser gravado na inclusЦo de um  Ё╠╠
╠╠Ё          Ё novo sub-contrato.                                   	 Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PL660AtCar()                                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PL660AtCar                                                Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PL660AtCar()

Local nCols 	:= 1
Local nPos 		:= 0
LOCAL lForcRefr := .F.
LOCAL aAuxBEY   := {}
LOCAL aAuxBA6   := {}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicoes do array Produto x Novos dependentes...                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nBEY_SEQUEN := oBrwBEY:FieldPos("BEY_SEQUEN", aCabBEY)    
Local nBEY_TIPO   := oBrwBEY:FieldPos("BEY_TIPO"  , aCabBEY)
Local nBEY_LIMITE := oBrwBEY:FieldPos("BEY_LIMITE", aCabBEY) 
Local nBEY_UNICAR := oBrwBEY:FieldPos("BEY_UNICAR", aCabBEY) 	
Local nBEY_CODPRO := oBrwBEY:FieldPos("BEY_CODPRO", aCabBEY) 
Local nBEY_TIPUSU := oBrwBEY:FieldPos("BEY_TIPUSU", aCabBEY) 
Local nBEY_DESUSU := oBrwBEY:FieldPos("BEY_DESUSU", aCabBEY) 
Local nBEY_GRAUPA := oBrwBEY:FieldPos("BEY_GRAUPA", aCabBEY) 
Local nBEY_DESGRA := oBrwBEY:FieldPos("BEY_DESGRA", aCabBEY) 
Local nBEY_VERPRO := oBrwBEY:FieldPos("BEY_VERPRO", aCabBEY) 
          
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicoes do array Produto x Classe de Carencia...	 				Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nBA6_CODPRO := oBrwBA6:FieldPos("BA6_CODPRO", aCabBA6) 
LOCAL nBA6_CLACAR := oBrwBA6:FieldPos("BA6_CLACAR", aCabBA6) 
LOCAL nBA6_DESCLA := oBrwBA6:FieldPos("BA6_DESCLA", aCabBA6) 
LOCAL nBA6_CARENC := oBrwBA6:FieldPos("BA6_CARENC", aCabBA6) 
LOCAL nBA6_UNICAR := oBrwBA6:FieldPos("BA6_UNICAR", aCabBA6) 
LOCAL nBA6_VERPRO := oBrwBA6:FieldPos("BA6_VERPRO", aCabBA6) 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abandona a rotina se nao for informado nenhum produto no sub contr..Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If 	Empty(M->BT6_CODPRO) .Or. Empty(M->BT6_VERSAO) .Or. Empty(cCodFor)
	Return .T.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe Carencia para Novo Dependente vinculados no produto... Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
//BEK_FILIAL + BEK_CODIGO + BEK_VERSAO                                                                                                                                                                                                    
BEK->(DbSetOrder(1))
If BEK->( MsSeek(xFilial("BEK")+ BT5->BT5_CODINT +M->BT6_CODPRO +M->BT6_VERSAO))
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Adiciona as Carencias p/ Novos Dependentes ao sub contrato...       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
	While !BEK->( Eof() ) .and. BEK->(BEK_CODIGO+BEK_VERSAO) == BT5->BT5_CODINT +M->BT6_CODPRO +M->BT6_VERSAO
	  	If (nPos := Ascan(oBrwBEY:aCols, {|x| 	x[nBEY_CODPRO] == BEK->(SUBSTR(BEK_CODIGO,5,8)) .and.;
												x[nBEY_VERPRO] == BEK->BEK_VERSAO .and.;
												x[nBEY_SEQUEN] == BEK->BEK_SEQUEN } )) == 0
			lForcRefr := .T.
			If Empty(oBrwBEY:aCols[1][nBEY_SEQUEN])
				oBrwBEY:aCols[1][nBEY_SEQUEN] := BEK->BEK_SEQUEN 
				oBrwBEY:aCols[1][nBEY_TIPO]   := BEK->BEK_TIPO
				oBrwBEY:aCols[1][nBEY_LIMITE] := BEK->BEK_LIMITE
				oBrwBEY:aCols[1][nBEY_UNICAR] := "2"//No BEK nao existe, mas o limite estА em dias, por isso "2" ref dias no BEY 
				oBrwBEY:aCols[1][nBEY_CODPRO] := BEK->(SUBSTR(BEK_CODIGO,5,8))
				oBrwBEY:aCols[1][nBEY_TIPUSU] := BEK->BEK_TIPUSU
				oBrwBEY:aCols[1][nBEY_DESUSU] := Posicione("BIH",1,xFilial("BIH")+BEK->BEK_TIPUSU,"BIH_DESCRI")
				oBrwBEY:aCols[1][nBEY_GRAUPA] := BEK->BEK_GRAUPA
				oBrwBEY:aCols[1][nBEY_DESGRA] := Posicione("BRP",1,xFilial("BRP")+BEK->BEK_GRAUPA,"BRP_DESCRI")
				oBrwBEY:aCols[1][nBEY_VERPRO] := BEK->BEK_VERSAO
			Else    	 
				// Existe casos em que o acols eh inicializado com duas linhas.                                
				If !Empty(oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_SEQUEN])
					Aadd(oBrwBEY:aCols, AClone(oBrwBEY:aCols[1]))
				Endif
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_SEQUEN] := BEK->BEK_SEQUEN 
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_TIPO]   := BEK->BEK_TIPO
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_LIMITE] := BEK->BEK_LIMITE
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_UNICAR] := "2"//No BEK nao existe, mas o limite estА em dias, por isso "2" ref dias no BEY 
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_CODPRO] := BEK->(SUBSTR(BEK_CODIGO,5,8))
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_TIPUSU] := BEK->BEK_TIPUSU
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_DESUSU] := Posicione("BIH",1,xFilial("BIH")+BEK->BEK_TIPUSU,"BIH_DESCRI")
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_GRAUPA] := BEK->BEK_GRAUPA
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_DESGRA] := Posicione("BRP",1,xFilial("BRP")+BEK->BEK_GRAUPA,"BRP_DESCRI")
				oBrwBEY:aCols[Len(oBrwBEY:aCols)][nBEY_VERPRO] := BEK->BEK_VERSAO
				Aadd(oBrwBEY:AvetTrab,0)
			Endif
		Endif
	 	BEK->( dbSkip() )
	Enddo
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liga o lAltered do objeto para a classe poder gravar...             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aAuxBEY := Aclone(oBrwBEY:aCols)
	If lForcRefr
		oBrwBEY:SetArray(aAuxBEY)
		oBrwBEY:lAltered := .T.      
		oBrwBEY:ForceRefresh(oBrwPro)
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe Classe de Carencia no produto... 					  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
lForcRefr := .F. 
nCols 	  := 1
nPos 	  := 0 
BAN->(dbSetOrder(1))
//BAN_FILIAL + BAN_CODIGO + BAN_VERSAO + BAN_CLACAR                                                                                                               
If BAN->( MsSeek(xFilial("BAN")+ BT5->BT5_CODINT +M->BT6_CODPRO +M->BT6_VERSAO ))
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Adiciona as Classes de Carencias ao sub contrato...                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                                         
	While !BAN->( Eof() ) .and. BAN->(BAN_CODIGO+BAN_VERSAO) == BT5->BT5_CODINT +M->BT6_CODPRO +M->BT6_VERSAO
	  	If (nPos := Ascan(oBrwBA6:aCols, {|x| 	x[nBA6_CODPRO] == BAN->(SUBSTR(BAN_CODIGO,5,8)) .and.;
												x[nBA6_VERPRO] == BAN->BAN_VERSAO .and.;
												x[nBA6_CLACAR] == BAN->BAN_CLACAR } )) == 0
			lForcRefr := .T.
			If Empty(oBrwBA6:aCols[1][nBA6_CLACAR])
				oBrwBA6:aCols[1][nBA6_CODPRO ] := BAN->(SUBSTR(BAN_CODIGO,5,8)) 
				oBrwBA6:aCols[1][nBA6_CLACAR ] := BAN->BAN_CLACAR
				oBrwBA6:aCols[1][nBA6_DESCLA ] := Posicione("BDL",1,xFilial("BDL")+ BAN->(SUBSTR(BAN_CODIGO,1,4))+ BAN->BAN_CLACAR,"BDL_DESCRI")
				oBrwBA6:aCols[1][nBA6_CARENC ] := BAN->BAN_QTDCAR
				oBrwBA6:aCols[1][nBA6_UNICAR ] := BAN->BAN_UNCAR
				oBrwBA6:aCols[1][nBA6_VERPRO ] := BAN->BAN_VERSAO
			Else    	 
				// Existe casos em que o acols eh inicializado com duas linhas.                                
				If !Empty(oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_CLACAR])
					Aadd(oBrwBA6:aCols, AClone(oBrwBA6:aCols[1]))
				Endif
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_CODPRO ] := BAN->(SUBSTR(BAN_CODIGO,5,8)) 
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_CLACAR ] := BAN->BAN_CLACAR
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_DESCLA ] := Posicione("BDL",1,xFilial("BDL")+ BAN->(SUBSTR(BAN_CODIGO,1,4))+ BAN->BAN_CLACAR,"BDL_DESCRI")
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_CARENC ] := BAN->BAN_QTDCAR
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_UNICAR ] := BAN->BAN_UNCAR
				oBrwBA6:aCols[Len(oBrwBA6:aCols)][nBA6_VERPRO ] := BAN->BAN_VERSAO
				Aadd(oBrwBA6:AvetTrab,0)
			Endif
		Endif
	 	BAN->( dbSkip() )
	Enddo
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liga o lAltered do objeto para a classe poder gravar...             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aAuxBA6 := Aclone(oBrwBA6:aCols)
	If lForcRefr
		oBrwBA6:SetArray(aAuxBA6)
		oBrwBA6:lAltered := .T.      
		oBrwBA6:ForceRefresh(oBrwPro)
	Endif
Endif

Return .T.

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA660   ╨Autor  ЁMicrosiga           ╨ Data Ё  08/11/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function Plsa660REA()
Local cFil
PRIVATE aRotina    := {}
                         
PRIVATE cAlias     := "BGJ"
PRIVATE cCadastro  := PLSRetTit(cAlias)

cMenu := 3

aRotina := MenuDef()

If ! PLSALIASEX(cAlias)
   MsgStop("Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BGJ")
   Return
Endif   

cFil := "@BGJ_FILIAL = '"+xFilial("BGJ")+"' AND BGJ_CODINT = '"+BG9->BG9_CODINT+"' AND BGJ_CODIGO = '"+BG9->BG9_CODIGO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BGJ->(DbSetOrder(1))
SET FILTER TO &cFil
BGJ->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,.F.))
BGJ->(DbClearFilter())
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEstava perdendo o filtro ao incluir/Alterar parametros Ё
//ЁAlexander 11/04/2005                          		  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
function Plsa660Inc(cAlias,nReg,nOpc)
   Local cFil      
   If cAlias == 'BGJ'
      cFil := "@BGJ_FILIAL = '"+xFilial("BGJ")+"' AND BGJ_CODINT = '"+BG9->BG9_CODINT+"' AND BGJ_CODIGO = '"+BG9->BG9_CODIGO+"' AND D_E_L_E_T_ = ' '"
   ElseIf cAlias == 'BH3'
	  cFil := "@BH3_FILIAL = '"+xFilial("BH3")+"' AND BH3_CODINT = '"+BG9->BG9_CODINT+"' AND BH3_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
	  cFil += "BH3_NUMCON = '"+BT5->BT5_NUMCON+"' AND BH3_VERSAO = '"+BT5->BT5_VERSAO+"' AND D_E_L_E_T_ = ' '"
   ElseIf cAlias == 'BYA'
	cFil := "@BYA_FILIAL = '"+xFilial("BYA")+"' AND BYA_CODINT = '"+BG9->BG9_CODINT+"' AND BYA_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
	cFil += "BYA_NUMCON = '"+BQC->BQC_NUMCON+"' AND BYA_VERSAO = '"+BQC->BQC_VERCON+"' AND "
	cFil += "BYA_SUBCON = '"+BQC->BQC_SUBCON+"' AND BYA_VERSUB = '"+BQC->BQC_VERSUB+"' AND "
	cFil += "D_E_L_E_T_ = ' '"
   EndIf	   
   AxInclui(cAlias,nReg,nOpc,nil,nil,nil,'PLS660PREA(cAlias)')
   SET FILTER TO &cFil
Return

Function PLS660PREA(cAlias)
LOCAL lRet 		:= .T.
LOCAL nOrdem 	:= 1
LOCAL cChave 	:= ''
LOCAL aArea 	:= GetArea()

dbSelectArea("SIX")
dbSetorder(01)

If cAlias == 'BGJ'		// Grupo empresa.
	If SIX->( dbSeek("BGJ2") )
		cChave := M->BGJ_CODINT+M->BGJ_CODIGO+M->BGJ_ANO+M->BGJ_MES+M->BGJ_TIPREA
		nOrdem := 2
	Else
		cChave := M->BGJ_CODINT+M->BGJ_CODIGO+M->BGJ_ANO+M->BGJ_MES
		nOrdem := 1	
	Endif                                
	
Elseif cAlias == "BH3"	// Contrato.
	If SIX->( dbSeek("BH32") )
		cChave := M->BH3_CODINT+M->BH3_CODIGO+M->BH3_NUMCON+M->BH3_VERSAO+M->BH3_ANO+M->BH3_MES+M->BH3_TIPREA
		nOrdem := 2
	Else
		cChave := M->BH3_CODINT+M->BH3_CODIGO+M->BH3_NUMCON+M->BH3_VERSAO+M->BH3_ANO+M->BH3_MES
		nOrdem := 1	
	Endif                                

Elseif cAlias == "BYA"	// Subcontrato.
	If SIX->( dbSeek("BYA2") )
		cChave := M->(BYA_CODINT+BYA_CODIGO+BYA_NUMCON+BYA_VERSAO+BYA_SUBCON+BYA_VERSUB+BYA_ANO+BYA_MES+BYA_CODPLA+BYA_VERPLA+BYA_TIPREA)
		nOrdem := 2
	Else
		cChave := M->(BYA_CODINT+BYA_CODIGO+BYA_NUMCON+BYA_VERSAO+BYA_SUBCON+BYA_VERSUB+BYA_ANO+BYA_MES+BYA_CODPLA+BYA_VERPLA)
		nOrdem := 1	
	Endif           

Endif
lRet := &(cAlias)->(ExistChav(cAlias,cChave,nOrdem))

If ExistBlock("PL660REA")
	lRet := ExecBlock("PL660REA",.F.,.F.,{cAlias,cChave,nOrdem})
EndIf
Restarea(aArea)

Return(lRet)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEstava perdendo o filtro ao incluir/Alterar parametros Ё
//ЁTulio     09/07/2007                          		  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
function Plsa660Alt(cAlias,nReg,nOpc)
   Local cFil      
   If cAlias == 'BGJ'
      cFil := "@BGJ_FILIAL = '"+xFilial("BGJ")+"' AND BGJ_CODINT = '"+BG9->BG9_CODINT+"' AND BGJ_CODIGO = '"+BG9->BG9_CODIGO+"' AND D_E_L_E_T_ = ' '"
   ElseIf cAlias == 'BH3'
	  cFil := "@BH3_FILIAL = '"+xFilial("BH3")+"' AND BH3_CODINT = '"+BG9->BG9_CODINT+"' AND BH3_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
	  cFil += "BH3_NUMCON = '"+BT5->BT5_NUMCON+"' AND BH3_VERSAO = '"+BT5->BT5_VERSAO+"' AND D_E_L_E_T_ = ' '"
   ElseIf cAlias == 'BYA'
	cFil := "@BYA_FILIAL = '"+xFilial("BYA")+"' AND BYA_CODINT = '"+BG9->BG9_CODINT+"' AND BYA_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
	cFil += "BYA_NUMCON = '"+BQC->BQC_NUMCON+"' AND BYA_VERSAO = '"+BQC->BQC_VERCON+"' AND "
	cFil += "BYA_SUBCON = '"+BQC->BQC_SUBCON+"' AND BYA_VERSUB = '"+BQC->BQC_VERSUB+"' AND "
	cFil += "D_E_L_E_T_ = ' '"
   EndIf	   
   AxAltera(cAlias,nReg,nOpc,nil,nil,nil,nil,'PLS660PREA(cAlias)')
   SET FILTER TO &cFil
Return

Function Plsa660REC()
Local cFil
PRIVATE aRotina    := {}
                         
PRIVATE cAlias     := "BH3"
PRIVATE cCadastro  := PLSRetTit(cAlias)

cMenu := 4

aRotina := MenuDef()

If ! PLSALIASEX(cAlias)
   MsgStop("Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BH3")
   Return
Endif   

cFil := "@BH3_FILIAL = '"+xFilial("BH3")+"' AND BH3_CODINT = '"+BG9->BG9_CODINT+"' AND BH3_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
cFil += "BH3_NUMCON = '"+BT5->BT5_NUMCON+"' AND BH3_VERSAO = '"+BT5->BT5_VERSAO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BH3->(DbSetOrder(1))
SET FILTER TO &cFil
BH3->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,.F.))
BH3->(DbClearFilter())
Return


Function Plsa660RES()
Local cFil
PRIVATE aRotina    := {}
                         
PRIVATE cAlias     := "BYA"
PRIVATE cCadastro  

cMenu := 5
aRotina := MenuDef()

If ExistBlock("PLS660MN")
	If !(Execblock("PLS660MN",.F.,.F.,{nOpcx}))
		Return(.F.)
	Endif
Endif     

If ! PLSALIASEX(cAlias)
   MsgStop("Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BYA")
   Return
Endif   

cCadastro  := PLSRetTit(cAlias)
cFil := "@BYA_FILIAL = '"+xFilial("BYA")+"' AND BYA_CODINT = '"+BG9->BG9_CODINT+"' AND BYA_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
cFil += "BYA_NUMCON = '"+BQC->BQC_NUMCON+"' AND BYA_VERSAO = '"+BQC->BQC_VERCON+"' AND "
cFil += "BYA_SUBCON = '"+BQC->BQC_SUBCON+"' AND BYA_VERSUB = '"+BQC->BQC_VERSUB+"' AND "
cFil += "D_E_L_E_T_ = ' '"

DbSelectArea(cAlias)
BYA->(DbSetOrder(1))
SET FILTER TO &cFil
BYA->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,.F.))
BYA->(DbClearFilter())
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё30/01/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё	  1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
	Private aRotina := {}

	If cMenu == 0

		aRotina := {	{ STR0001	,'AxPesqui'		, 0 , K_Pesquisar  	, 0, .F.},;	//'Pesquisar'
		{ STR0002	,'PLSA660Mov'	, 0 , K_Visualizar 	, 0, Nil},;	//'Visualizar'
		{ STR0003	,'PLSA660Mov'	, 0 , K_Incluir    	, 0, Nil},;	//'Incluir'
		{ STR0004	,'PLSA660Mov'	, 0 , K_Alterar    	, 0, Nil},;	//'Alterar' 
		{ STR0005	,'PLSA660Mov'	, 0 , K_Excluir    	, 0, Nil},;	//'Excluir'
		{ STR0006	,'PLS660FilC'	, 0 , K_Visualizar	, 0, Nil},;	//"Contratos"
		{ STR0007	,'PLS660Cob'	, 0 , K_Alterar		, 0, Nil},;	//"Valor Cobranca"
		{ STR0008 	,'PLSA660REA'	, 0	, 0 			, 0, Nil} }	//"Par.Reajustes"
	ElseIf cMenu == 1
		aRotina := { { STR0001	,'AxPesqui'		, 0 , K_Pesquisar  },;	//'Pesquisar'
		{ STR0002	,'PLSA660Con'	, 0 , K_Visualizar },;	//'Visualizar'
		{ STR0003	,'PLSA660Con'	, 0 , K_Incluir    },;	//'Incluir'
		{ STR0004	,'PLSA660Con'	, 0 , K_Alterar    },;	//'Alterar'
		{ STR0005	,'PLSA660Con'	, 0 , K_Excluir    },;	//'Excluir'
		{ STR0021	,'PLSA660Con'	, 0 , K_Visualizar },;	//"Sub-Contrato"		
		{ STR0022	,"PLSA660LEG"	, 0 , K_Incluir },;		//"Legenda"	
		{ STR0007	,'PLS660Cob'	, 0 , K_Alterar },;		//"Valor Cobranca"
		{ STR0008	,'Plsa660REC'	, 0	, K_Alterar }}		//"Par.Reajustes"

	ElseIf cMenu == 2
		aRotina := { { STR0001	,'AxPesqui'    , 0 , K_Pesquisar },; 	//'Pesquisar'
		{ STR0002	,'PLS660Var'   , 0 , K_Visualizar},; 	//'Visualizar'
		{ STR0003	,'PLS660Var'   , 0 , K_Incluir   },; 	//'Incluir'
		{ STR0004	,'PLS660Var'   , 0 , K_Alterar   },; 	//'Alterar'
		{ STR0005	,'PLS660Var'   , 0 , K_Excluir   },; 	//'Excluir'
		{ STR0041	,'PLS660Var'   , 0 , K_NovaVersao},; 	//"Nova Versao"
		{ STR0042	,'PLS660BLQ'   , 0 , K_BlqSubCon },;	//"(Des)bloq.sub-Ct."
		{ STR0043	,'PLS660HIS'   , 0 , K_HisBlqSub },;	//"Hist.Bloqueio"
		{ STR0007	,'PLS660Cob'   , 0 , K_Alterar   },;	//"Valor Cobranca"
		{ STR0008	,'Plsa660RES'  , 0 , K_Alterar   },;	//"Param.Reajustes"
		{ STR0046	,'Plsa660C'    , 0 , K_Alterar   }}		//"Copia"
	ElseIf cMenu == 3
		aRotina := { { STR0001	, 'AxPesqui' , 0 ,K_Pesquisar },;
		{ STR0002	, 'AxVisual' , 0 ,K_Visualizar},;
		{ STR0003	, 'Plsa660Inc' , 0 ,K_Incluir   },;
		{ STR0004	, 'Plsa660Alt' , 0 ,K_Alterar   },;
		{ STR0005	, 'AxDeleta' , 0 ,K_Excluir   }}

	ElseIf cMenu == 4
		aRotina := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
		{ STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
		{ STRPL03  	, 'Plsa660Inc' , 0 ,K_Incluir   },;
		{ STRPL04  	, 'Plsa660Alt' , 0 ,K_Alterar   },;
		{ STRPL05	 , 'AxDeleta' , 0 ,K_Excluir   }}
	ElseIf cMenu == 5
		aRotina := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
		{ STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
		{ STRPL03  	, 'Plsa660Inc' , 0 ,K_Incluir   },;
		{ STRPL04  	, 'Plsa660Alt' , 0 ,K_Alterar   },;
		{ STRPL05	 , 'AxDeleta' , 0 ,K_Excluir   }}

	Else
		aRotina := {	{ STR0001	,'AxPesqui'		, 0 , K_Pesquisar  	, 0, .F.},;	//'Pesquisar'
		{ STR0002	,'PLSA660Mov'	, 0 , K_Visualizar 	, 0, Nil   },;	//'Visualizar'
		{ STR0003	,'PLSA660Mov'	, 0 , K_Incluir    	, 0, Nil   },;	//'Incluir'
		{ STR0004	,'PLSA660Mov'	, 0 , K_Alterar    	, 0, Nil	 },;	//'Alterar' 
		{ STR0005	,'PLSA660Mov'	, 0 , K_Excluir    	, 0, Nil	 },;	//'Excluir'
		{ STR0006	,'PLS660FilC'	, 0 , K_Visualizar	, 0, Nil	 },;	//"Contratos"
		{ STR0007	,'PLS660Cob'	, 0 , K_Alterar		, 0, Nil		 },;	//"Valor Cobranca"
		{ STR0008 	,'PLSA660REA'	, 0	, 0 			, 0, Nil			 },;	//"Par.Reajustes"
		{ STR0001	,'AxPesqui'		, 0 , K_Pesquisar              },;	//'Pesquisar'
		{ STR0002	,'PLSA660Con'	, 0 , K_Visualizar             },;	//'Visualizar'
		{ STR0003	,'PLSA660Con'	, 0 , K_Incluir                },;	//'Incluir'
		{ STR0004	,'PLSA660Con'	, 0 , K_Alterar                },;	//'Alterar'
		{ STR0005	,'PLSA660Con'	, 0 , K_Excluir                },;	//'Excluir'
		{ STR0021	,'PLSA660Con'	, 0 , K_Visualizar             },;	//"Sub-Contrato"		
		{ STR0022	,"PLSA660LEG"	, 0 , K_Incluir 	             },;		//"Legenda"	
		{ STR0007	,'PLS660Cob'	, 0 , K_Alterar 	             },;		//"Valor Cobranca"
		{ STR0008	,'Plsa660REC'	, 0	, K_Alterar 	             },;		//"Par.Reajustes"
		{ STR0001	,'AxPesqui'    , 0 , K_Pesquisar             },; 	//'Pesquisar'
		{ STR0002	,'PLS660Var'   , 0 , K_Visualizar            },; 	//'Visualizar'
		{ STR0003	,'PLS660Var'   , 0 , K_Incluir               },; 	//'Incluir'
		{ STR0004	,'PLS660Var'   , 0 , K_Alterar               },; 	//'Alterar'
		{ STR0005	,'PLS660Var'   , 0 , K_Excluir               },; 	//'Excluir'
		{ STR0041	,'PLS660Var'   , 0 , K_NovaVersao            },; 	//"Nova Versao"
		{ STR0042	,'PLS660BLQ'   , 0 , K_BlqSubCon             },;	//"(Des)bloq.sub-Ct."
		{ STR0043	,'PLS660HIS'   , 0 , K_HisBlqSub             },;	//"Hist.Bloqueio"
		{ STR0007	,'PLS660Cob'   , 0 , K_Alterar               },;	//"Valor Cobranca"
		{ STR0008	,'Plsa660RES'  , 0 , K_Alterar               },;	//"Param.Reajustes"
		{ STR0046	,'Plsa660C'    , 0 , K_Alterar               },;		//"Copia"
		{ STR0001	, 'AxPesqui' , 0 ,K_Pesquisar              },;
		{ STR0002	, 'AxVisual' , 0 ,K_Visualizar               },;
		{ STR0003	, 'Plsa660Inc' , 0 ,K_Incluir                },;
		{ STR0004	, 'Plsa660Alt' , 0 ,K_Alterar                },;
		{ STR0005	, 'AxDeleta' , 0 ,K_Excluir                  },;
		{ STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar               },;
		{ STRPL02 , 'AxVisual' , 0 ,K_Visualizar               },;
		{ STRPL03  	, 'Plsa660Inc' , 0 ,K_Incluir              },;
		{ STRPL04  	, 'Plsa660Alt' , 0 ,K_Alterar              },;
		{ STRPL05	 , 'AxDeleta' , 0 ,K_Excluir                 },;
		{ STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar               },;
		{ STRPL02 , 'AxVisual' , 0 ,K_Visualizar               },;
		{ STRPL03  	, 'Plsa660Inc' , 0 ,K_Incluir              },;
		{ STRPL04  	, 'Plsa660Alt' , 0 ,K_Alterar              },;
		{ STRPL05	 , 'AxDeleta' , 0 ,K_Excluir                 }}

	EndIf

Return(aRotina)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS660CFP ╨Autor  ЁTulio Cesar         ╨ Data Ё  25/08/08   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Copia valores de faixas ao subcontrato (BT9_CODFOR)        ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Plano de SaЗde                                             ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS660CFP
M->BT6_CODPRO := M->BT9_CODPRO
M->BT6_VERSAO := M->BT9_VERSAO
PL660Forma(M->BT9_CODFOR)
Return(.T.)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA660   ╨Autor  ЁMicrosiga           ╨ Data Ё  01/13/12   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL660VLPAT(cAlias)
Local lRet := .F.
Local cChave	:= ""

If cAlias == "BQC"
	If !Empty(M->BQC_CODPAT)
		If Val(GetVersao(.F.)) >= 12//caso a versЦo seja maior ou igual a 12 
			cChave := M->BQC_CODINT+M->BQC_CODPAT
		Else
			cChave := BQC->BQC_CODINT+M->BQC_CODPAT
		Endif		
	Else
		lRet := .T.
	Endif		

Elseif cAlias == "BT6"
	If !Empty(M->BT6_CODPAT)
		cChave := BQC->BQC_CODINT+M->BT6_CODPAT	
	Else
		lRet := .T.
	Endif	
Endif

If !lRet
	lRet := ExistCpo("B1I",cChave,1)
Endif

Return( lRet )
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPL660CarCr Ё Autor Ё Victor   	        | Data Ё 01.04.13 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao ЁCarrega as criticas    									  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/
Function PL660CarCr()

PutHelp("PPLSSITANS",{"O produto selecionado encontra-se ","com o cadastro bloqueado pela ANS."},,,.T.)
PutHelp("SPLSSITANS",{"Selecione um produto com o cadastro ","ativo."},,,.T.)

Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPL660CarCr Ё Autor Ё Victor   	        | Data Ё 26.04.13 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao ЁCarrega as o vinculo do opcional no subcontrado			  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/
Function PL660TrPla()
Local aArea := GetArea()

BT3->(DbSetOrder(1))//BT3_FILIAL+BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA

If BT3->(MsSeek(xFilial("BT3")+BI3->BI3_CODINT+M->BHS_CODPRO+M->BHS_VERPRO+M->BHS_CODPLA))
	M->BHS_TIPVIN := BT3->BT3_TIPVIN
Else
	M->BHS_TIPVIN := '0'
Endif

RestArea(aArea)

Return .T.

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PL660GDPro
Carrega automatico os Grupos Determinados e os Procedimentos do Produto saЗde

@author Vinicius Queiros Teixeira
@since 17/01/2020
@version Protheus 12
/*/
//---------------------------------------------------------------------------------------
Function PL660GDPro()

	Local nPos := 0
	Local lForcRefr := .F.
	Local aAuxBT7 := {} // Grupos Determinados
	Local aAuxBT8 := {} // Procedimentos
	Local nCols := 1
	Local nHeader := 0 
	Local lInsertProduto := .T.
	// PosiГУes dos Grupos Determinados                 
	Local nBT7_CODPRO := oBrwGru:FieldPos("BT7_CODPRO", aCabGru) 
	Local nBT7_CODGRU := oBrwGru:FieldPos("BT7_CODGRU", aCabGru) 
	Local nBT7_DESGRU := oBrwGru:FieldPos("BT7_DESGRU", aCabGru) 
	Local nBT7_VERPRO := oBrwGru:FieldPos("BT7_VERPRO", aCabGru) 			
	// PosiГУes dos Procedimentos
	Local nBT8_CODPRO := oBrwCob:FieldPos("BT8_CODPRO", aCabCob) 
	Local nBT8_CODPSA := oBrwCob:FieldPos("BT8_CODPSA", aCabCob) 
	Local nBT8_CODPAD := oBrwCob:FieldPos("BT8_CODPAD", aCabCob) 
	Local nBT8_VERPRO := oBrwCob:FieldPos("BT8_VERPRO", aCabCob) 
	Local nBT8_DESCRI := oBrwCob:FieldPos("BT8_DESCRI", aCabCob) // Campos Virtuais 
	Local nBT8_DESCAR := oBrwCob:FieldPos("BT8_DESCAR", aCabCob) // Campos Virtuais 

	// Abandona a rotina se nao for informado nenhum produto no sub contrato..
	If Empty(M->BT6_CODPRO) .Or. Empty(M->BT6_VERSAO) 
		Return .T.
	Endif

	lInsertProduto := Ascan(oBrwGru:aCols, {|x| x[nBT7_CODPRO] == M->BT6_CODPRO .And. x[nBT7_VERPRO] == M->BT6_VERSAO}) == 0

	// Atualiza os dados somente quando for um inserГЦo do produto saЗde
	If !lInsertProduto
		Return .T.
	EndIf

	// Verifica se existem grupos determinados no produto 
	cSQL := "SELECT R_E_C_N_O_ Recno FROM " + RetSQLName("BRV")+" WHERE BRV_FILIAL = '"+xFilial("BRV")+"' AND "
	cSQL += "BRV_CODPLA = '"+BT5->BT5_CODINT + M->BT6_CODPRO+"' AND "
	cSQL += "BRV_VERSAO = '"+M->BT6_VERSAO+"' AND "	
	cSQL += "D_E_L_E_T_= ' ' " 
	cSQL += "ORDER BY BRV_CODGRU "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbBRV",.f.,.t.)

	If !TrbBRV->(Eof())            
		While !TrbBRV->(Eof())

			BRV->(DbGoTo(TrbBRV->Recno))
			// Verifica se o grupo ja existe no subcontrato
			If (nPos := Ascan(oBrwGru:aCols, {|x| 	x[nBT7_CODPRO] == BRV->(SUBSTR(BRV_CODPLA,5,8)) .and.;
													x[nBT7_VERPRO] == BRV->BRV_VERSAO .and.;
													x[nBT7_CODGRU] == BRV->BRV_CODGRU } )) == 0
				
				lForcRefr := .T. // Atualizar browser

				If Empty(oBrwGru:aCols[1][nBT7_CODGRU])
					aAuxBT7 := aClone(oBrwGru:aCols)
														
					aAuxBT7[1][nBT7_CODPRO] := M->BT6_CODPRO 
					aAuxBT7[1][nBT7_CODGRU] := BRV->BRV_CODGRU	
					aAuxBT7[1][nBT7_DESGRU] := Posicione("BG7",1,xFilial("BG7")+BT5->BT5_CODINT+BRV->BRV_CODGRU,"BG7_DESCRI")
					aAuxBT7[1][nBT7_VERPRO] := M->BT6_VERSAO
					
					oBrwGru:SetArray(aAuxBT7)
				Else
					oBrwGru:AddBlank()
					oBrwGru:FieldPut("BT7_CODPRO", M->BT6_CODPRO , Len(oBrwGru:aCols))
					oBrwGru:FieldPut("BT7_CODGRU", BRV->BRV_CODGRU, Len(oBrwGru:aCols))
					oBrwGru:FieldPut("BT7_DESGRU", Posicione("BG7",1,xFilial("BG7")+BT5->BT5_CODINT+BRV->BRV_CODGRU,"BG7_DESCRI"), Len(oBrwGru:aCols))
					oBrwGru:FieldPut("BT7_VERPRO", M->BT6_VERSAO, Len(oBrwGru:aCols))
			
				Endif
				
				// Verifica se o grupo determinando que esta posicionado tem coparticipaГЦo
				// se tiver grava a coparticipaГЦo no subcontrato			
				cSQL := "SELECT R_E_C_N_O_ Recno FROM " + RetSQLName("BHI")+" WHERE BHI_FILIAL = '"+xFilial("BHI")+"' AND "
				cSQL += "BHI_CODINT = '"+BT5->BT5_CODINT+"' AND "
				cSQL += "BHI_CODPLA = '"+M->BT6_CODPRO+"' AND "
				cSQL += "BHI_VERSAO = '"+M->BT6_VERSAO+"' AND "	
				cSQL += "BHI_CODGRU = '"+BRV->BRV_CODGRU+"' AND "
				cSQL += "D_E_L_E_T_= ' ' " 
				cSQL += "ORDER BY BHI_CODGRU "

				dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbBHI",.f.,.t.)

				If !TrbBHI->(Eof()) 		
					While !TrbBHI->(Eof())

						BHI->(DbGoTo(TrbBHI->Recno))
						// Se for o primeiro registro nЦo add no array
						If !(Len(aDadCGru) == 1 .And. Empty(aDadCGru[1][1]))

							Aadd(aDadCGru, AClone(aDadCGru[1]))
							nCols := Len(aDadCGru)
						Endif
					
						For nHeader := 1 To Len(aCabCGru)
							If aCabCGru[nHeader][2] = "BHF_CODPRO"
								aDadCGru[nCols][nHeader] := M->BT6_CODPRO
									
							Elseif aCabCGru[nHeader][2] = "BHF_VERPRO"                    
								aDadCGru[nCols][nHeader] := M->BT6_VERSAO

							Elseif aCabCGru[nHeader][2] = "BHF_VALCOP"                    
								aDadCGru[nCols][nHeader] := BHI->BHI_VLRCOP

							Elseif aCabCGru[nHeader][2] = "BHF_VIGINI"                    
								aDadCGru[nCols][nHeader] := BHI->BHI_VIGDE

							Elseif aCabCGru[nHeader][2] = "BHF_VIGFIN"                    
								aDadCGru[nCols][nHeader] := BHI->BHI_VIGATE

							Elseif aCabCGru[nHeader][2] = "BHF_NUMCON"                    
								aDadCGru[nCols][nHeader] := BT5->BT5_NUMCON

							Elseif aCabCGru[nHeader][2] = "BHF_VERCON"                    
								aDadCGru[nCols][nHeader] := BT5->BT5_VERSAO	
								
							Elseif (nPos := BHI->(FieldPos(StrTran(aCabCGru[nHeader][2], "BHF", "BHI")))) > 0
								aDadCGru[nCols][nHeader] := BHI->(FieldGet(nPos))

							Endif
						Next
								
						Pl260AtuVar(aCabCGru, aDadCGru, nCols)
								
						TrbBHI->(DbSkip())
					EndDo
				EndIf
				
				TrbBHI->(DbCloseArea())
				
			EndIf
			TrbBRV->(DbSkip())
		EndDo
		// Liga o lAltered do objeto para a classe poder gravar...    	
		If lForcRefr
			oBrwGru:ForceRefresh(oBrwGru)
			oBrwGru:oBrowse:oBrowse:lDisablePaint := .f.
			oBrwGru:oBrowse:oBrowse:Refresh()
			oBrwGru:oBrowse:oBrowse:lDisablePaint := .t.		
		Endif
		
	EndIf
	TrbBRV->(DbCloseArea())

	nCols 		:= 1
	lForcRefr 	:= .F. 

	// Verifica se existem procedimentos no produto 
	// para gravar no subcontrato               
	cSQL := "SELECT R_E_C_N_O_ Recno FROM " + RetSQLName("BB2")+" WHERE BB2_FILIAL = '"+xFilial("BB2")+"' AND "
	cSQL += "BB2_CODIGO = '"+BT5->BT5_CODINT + M->BT6_CODPRO+"' AND "
	cSQL += "BB2_VERSAO = '"+M->BT6_VERSAO+"' AND "	
	cSQL += "D_E_L_E_T_= ' ' " 
	cSQL += "ORDER BY BB2_CODPSA "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbBB2",.f.,.t.)

	If !TrbBB2->(Eof())            
		While !TrbBB2->(Eof())

			BB2->(DbGoTo(TrbBB2->Recno))
			// Verifica se O procedimento ja tem no subcontrato
			If (nPos := Ascan(oBrwCob:aCols, {|x| 	x[nBT8_CODPRO] == BB2->(SUBSTR(BB2_CODIGO,5,8)) .and.;
													x[nBT8_VERPRO] == BB2->BB2_VERSAO .and.;
													x[nBT8_CODPSA] == BB2->BB2_CODPSA .and.;
													x[nBT8_CODPAD] == BB2->BB2_CODPAD } )) == 0
				
				lForcRefr := .T. // Atualiza Browser

				If Empty(oBrwCob:aCols[1][nBT8_CODPSA])
					aAuxBT8 := aClone(oBrwCob:aCols)

					For nHeader := 1 To Len(aCabCob)
						If aCabCob[nHeader][2] = "BT8_CODPRO"
							aAuxBT8[1][nHeader] := M->BT6_CODPRO
									
						Elseif aCabCob[nHeader][2] = "BT8_VERPRO"                    
							aAuxBT8[1][nHeader] := M->BT6_VERSAO

						Elseif (nPos := BB2->(FieldPos(StrTran(aCabCob[nHeader][2], "BT8", "BB2")))) > 0
							aAuxBT8[1][nHeader] := BB2->(FieldGet(nPos))

						Endif
					Next

					aAuxBT8[1][nBT8_DESCRI] := Posicione("BR8",1,xFilial("BR8")+BB2->(BB2_CODPAD+BB2_CODPSA),"BR8_DESCRI") // DesciГЦo do tab.pad
					aAuxBT8[1][nBT8_DESCAR] := Posicione("BDL",1,xFilial("BDL")+BB2->(Left(BB2_CODIGO,4)+BB2_CLACAR),"BDL_DESCRI") // DescriГЦo da Classe                                     

					oBrwCob:SetArray(aAuxBT8)
				Else
					oBrwCob:AddBlank()
					For nHeader := 1 To Len(aCabCob)
						If aCabCob[nHeader][2] = "BT8_CODPRO"
							oBrwCob:FieldPut(aCabCob[nHeader][2], M->BT6_CODPRO , Len(oBrwCob:aCols))
									
						Elseif aCabCob[nHeader][2] = "BT8_VERPRO"                    
							oBrwCob:FieldPut(aCabCob[nHeader][2], M->BT6_VERSAO , Len(oBrwCob:aCols))

						Elseif (nPos := BB2->(FieldPos(StrTran(aCabCob[nHeader][2], "BT8", "BB2")))) > 0
							oBrwCob:FieldPut(aCabCob[nHeader][2], BB2->(FieldGet(nPos)) , Len(oBrwCob:aCols)) 

						Endif
					Next

					oBrwCob:FieldPut("BT8_DESCRI", Posicione("BR8",1,xFilial("BR8")+BB2->(BB2_CODPAD+BB2_CODPSA),"BR8_DESCRI"), Len(oBrwCob:aCols)) // DesciГЦo do tab.pad
					oBrwCob:FieldPut("BT8_DESCAR", Posicione("BDL",1,xFilial("BDL")+BB2->(Left(BB2_CODIGO,4)+BB2_CLACAR),"BDL_DESCRI"), Len(oBrwCob:aCols))// DescriГЦo da Classe 
			
				Endif		

				// Verifica se o procedimento que esta posicionado tem coparticipaГЦo
				// se tiver grava a coparticipaГЦo no subcontrato			
				cSQL := "SELECT R_E_C_N_O_ Recno FROM " + RetSQLName("BHD")+" WHERE BHD_FILIAL = '"+xFilial("BHD")+"' AND "
				cSQL += "BHD_CODIGO = '"+BT5->BT5_CODINT+M->BT6_CODPRO+"' AND "
				cSQL += "BHD_VERSAO = '"+M->BT6_VERSAO+"' AND "
				cSQL += "BHD_CODPSA = '"+BB2->BB2_CODPSA+"' AND "
				cSQL += "BHD_CODPAD = '"+BB2->BB2_CODPAD+"' AND "	
				cSQL += "D_E_L_E_T_= ' ' " 
				cSQL += "ORDER BY BHD_CODPSA"

				dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbBHD",.f.,.t.)

				If !TrbBHD->(Eof()) 		
					While !TrbBHD->(Eof())

						BHD->(DbGoTo(TrbBHD->Recno))
						// Se for o primeiro registro nЦo add no array
						If !(Len(aDadCCo) == 1 .And. Empty(aDadCCo[1][2]))
							Aadd(aDadCCo, AClone(aDadCCo[1]))
							nCols := Len(aDadCCo)
						Endif
					
						For nHeader := 1 To Len(aCabCCo)
							If aCabCCo[nHeader][2] = "BHE_CODPRO"
								aDadCCo[nCols][nHeader] := M->BT6_CODPRO
									
							Elseif aCabCCo[nHeader][2] = "BHE_VERPRO"                    
								aDadCCo[nCols][nHeader] := M->BT6_VERSAO
					
							Elseif aCabCCo[nHeader][2] = "BHE_VIGINI"                    
								aDadCCo[nCols][nHeader] := BHD->BHD_VIGDE

							Elseif aCabCCo[nHeader][2] = "BHE_VIGFIN"                    
								aDadCCo[nCols][nHeader] := BHD->BHD_VIGATE
						
							Elseif aCabCCo[nHeader][2] = "BHE_CODINT"                    
								aDadCCo[nCols][nHeader] := BHD->BHD_CODINT
							
							Elseif aCabCCo[nHeader][2] = "BHE_CODIGO"                    
								aDadCCo[nCols][nHeader] := BHD->BHD_CODIGO
							
							Elseif aCabCCo[nHeader][2] = "BHE_NUMCON"                    
								aDadCCo[nCols][nHeader] := M->BQC_NUMCON

							Elseif aCabCCo[nHeader][2] = "BHE_VERCON"                    
								aDadCCo[nCols][nHeader] := M->BQC_VERCON

							Elseif aCabCCo[nHeader][2] = "BHE_SUBCON"                    
								aDadCCo[nCols][nHeader] := M->BQC_SUBCON
							
							Elseif aCabCCo[nHeader][2] = "BHE_VERSUB"                    
								aDadCCo[nCols][nHeader] := M->BQC_VERSUB	

							Elseif (nPos := BHD->(FieldPos(StrTran(aCabCCo[nHeader][2], "BHE", "BHD")))) > 0
								aDadCCo[nCols][nHeader] := BHD->(FieldGet(nPos))

							Elseif aCabCCo[nHeader][2] = "BHE_SEQUEN"                    
								aDadCCo[nCols][nHeader] := StrZero(nCols,Len(aDadCCo[nCols][nHeader]))

							Endif
						Next
								
						Pl260AtuVar(aCabCCo, aDadCCo, nCols)
								
						TrbBHD->(DbSkip())
					EndDo
				EndIf
				
				TrbBHD->(DbCloseArea())

			EndIf

			TrbBB2->(DbSkip())
		EndDo

		// Liga o lAltered do objeto para a classe poder gravar...    	
		If lForcRefr
			oBrwCob:ForceRefresh(oBrwCob)
			oBrwCob:oBrowse:oBrowse:lDisablePaint := .f.
			oBrwCob:oBrowse:oBrowse:Refresh()
			oBrwCob:oBrowse:oBrowse:lDisablePaint := .t.		
		Endif
				
	EndIf

	TrbBB2->(DbCloseArea())

Return .T.
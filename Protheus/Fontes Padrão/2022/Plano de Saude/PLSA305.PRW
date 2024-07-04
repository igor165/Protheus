#INCLUDE "plsa305.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"

#define K_Atend     6
#define K_Cancelar  5
#define K_Legenda   7
#define K_Parametro 8
#define _nBytes 20

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305 Ё Autor Ё Tulio Cesar            Ё Data Ё 07.01.02 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Atendimento de um medico a uma consulta                    Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSA305()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Agenda Medica                                              Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial.                              Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao de variaveis...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cAlias       := "BBD"                                                    
Local oBrw
Local bAjustBrw    := {|| oBrw := GetObjBrow(), PLSA305Tel(dDataBase,oBrw,cCodInt,cLocal,cCdAmbu,cDsAmbu) }
Local cPerg        := Padr("PLA305",Len(SX1->X1_GRUPO))
Local cCodLoja
Local cLocal
Local cCodInt
Local cDsambu
Local cSQL
Local oSay
Local _cFil305                                                                
Local nRcBAU
Local dDataDe
Local dDataAte
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cInterc    := GetNewPar("MV_PLSGEIN","0050")
Private cBTHcodate
Private cBTHquepri
Private cBTHquedoe
Private cBTHquecli
Private cBTHquIfam
Private cBTHdesrec
Private cBTHqueexa
Private cBTHquecon
Private cBTHidade 
Private dBTHdatret
Private nBTHpeso  
Private nBTHaltura
Private cBTHpreart
Private cBTHfrecar
Private nBTHtemper
Private cBTHCID   
Private dBTHdata   := dDataBase
Private cBTHhorini := Time()
Private cBTHhorfin := Time()
Private nRecBTH    := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta opcoes da rotina...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cSala
Private cCdAmbu
Private cCodSala
Private aCdCores   := { {  'BR_AMARELO'  ,STR0026 },; //'Encaixe'
                        { 'BR_CINZA'    ,STR0027 },; //'Agendado'
                        { 'BR_VERDE'    ,STR0028 },; //'Espera'
                        { 'BR_LARANJA'  ,STR0032 },;  //'No consultorio
                        { 'BR_AZUL'     ,STR0029 },;  //STR0029'Atendido'
                        { 'NOCHECKED'   ,STR0033 }} //'Cancelado'

Private aCores     := { { 'BBD_STATUS = "1" .And. BBD_ENCAIX = "1"',aCdCores[1,1] },;
                        { 'BBD_STATUS = "1"',aCdCores[2,1] },;
                        { 'BBD_STATUS = "5"',aCdCores[3,1] },;
                        { 'BBD_STATUS = "6"',aCdCores[4,1] },;
                        { 'BBD_STATUS = "4"',aCdCores[5,1] },;
                        { 'BBD_STATUS = "7"',aCdCores[6,1] }}
Private aRotina    := MenuDef()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cCadastro := STR0001 //"Atendimento Medico"

// *** - TRATAMENTO NA FUNCIONALIDADE PLSA305() - SX1 (CONFORME CODIGO FONTE PLSA305 - CHANGESET TFS: 395383) - EXCLUSAO DO MANUSEIO DO DICIONARIO ATRAVES DO CODIGO FONTE;	

If ! Pergunte(cPerg,.T.)                     
   Return
EndIf              

cCodInt  := mv_par01
cLocal   := mv_par02
dDataDe  := mv_par03
dDataAte := mv_par04

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o medico logado...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BAU_CODIGO, R_E_C_N_O_ REG FROM " + RetSQLName("BAU") + " WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BAU_CODCFG = '"+PLSRtCdUsr()+"'"
PLSQuery(cSQL,"Trb305")

If ! Trb305->(Eof())
   cCodLoja := Trb305->BAU_CODIGO
   nRcBAU   := Trb305->REG
Else
   MsgInfo(STR0002) //"O Vinculo Rede de Atendimento X Usuario Configurador deve ser feito antes de entrar nesta opcao."
   Trb305->(DbCloseArea())
   Return
EndIf                     
Trb305->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no medico...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSetOrder(1))
BAU->(DbGoTo(nRcBAU))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca em qual sala ele esta...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BGF_CODIGO, BGF_NSALA, BGF_CDAMBU FROM "+BGF->(RetSQLName("BGF"))+" WHERE "
cSQL += "BGF_FILIAL = '"+xFilial("BGF")+"' AND "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BGF_CODLOJ = '"+cCodLoja+"' AND "
cSQL += "BGF_CODINT = '"+cCodInt+"' AND "
cSQL += "BGF_CODLOC = '"+cLocal+"' AND "
cSQL += "BGF_STATUS = '1'"

PLSQuery(cSQL,"Trb305")

Trb305->(DbGoTop())
If ! Trb305->(Eof())
   cSala   := Trb305->BGF_NSALA       
   cCdAmbu := Trb305->BGF_CDAMBU
   cDsambu := BSD->(Posicione("BSD",1,xFilial("BSD")+cCdAmbu,"BSD_DSAMBU"))
   cCodSala:= Trb305->BGF_CODIGO  
EndIf
Trb305->(DbCloseArea())
If Empty(cSala)
   MsgInfo(STR0003) //"Por favor, confira os parametros informados na entrada da rotina."
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro padrao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cFil305 := "BBD_FILIAL = '"+xFilial("BBD")+"' "
_cFil305 += ".AND. BBD_CODIGO = '"+Subs(cCodLoja,1,6)+"' " 
_cFil305 += ".AND. ( dtos(BBD_DATA) >= '"+dtos(dDataDe)+"' "
_cFil305 += ".AND.   dtos(BBD_DATA) <= '"+dtos(dDataAte)+"' ) "
_cFil305 += ".AND. BBD_Local = '"+Subs(cLocal,1,3)+"' "
_cFil305 += ".AND. BBD_HORA <> ' ' "
BBD->(DbSetFilter({||&_cFil305},_cFil305))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama mBrowse padrao...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->(DbSetOrder(1))
BBD->(MsSeek(xFilial(cAlias)))

BBD->(mBrowse(006,001,022,075,cAlias, , , , , K_Atend, aCores, , , ,bAjustBrw))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera filtro antes de sair da rotina...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->(DbClearFilter())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305MOV Ё Autor Ё Tulio Cesar         Ё Data Ё 08.01.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Movimentacao do atendimento de um medico a uma consulta    Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSA305MOV(cAlias,nReg,nOpc)                               Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё PLSA305                                                    Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial.                              Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305MOV(cAlias,nReg,nOpc)

Local I__f         := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis locais...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local oDlg
Local oFolder
Local oEnc01
Local oEnc02
Local cAliasEnc    := "BTH"
Local oSay                         
Local nOpca        := 0                                           
Local cHorIni      := ""
Local bOK          := {|| dbSelectArea("BBD"), nOpca := 1,If((Obrigatorio(aGets,aTela)),oDlg:End(),(nOpca:=3,.F.))}
Local bCanc        := {|| dbSelectArea("BBD"), If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlg:End()),.F.) }
Local cPrefFil     := "PLSA315"          
Local cFileI
Local cDesPro      := ''
Local nOpcao       := 0
Local lPeriod      := .F.
Local nHMsg
Local aCabBTI      := {}
Local aDadBTI      := {}
Local aTrbBTI      := {}
Local aCpo01       := {}
Local aCpo02       := {}
Local nOrdBTH      := BTH->(IndexOrd())
Local aCabBPJ      := {}
Local aDadBPJ      := {}
Local aTrbBPJ      := {}
Local aRet	       := {}
Local nRecBBD      := BBD->( RecNo() )
Local oGrpLoc 
Local oSayGr                                             
Local cFieldBTH    := ""
Local Ifld         := 0
Local nQtdUsFld    := 0
Local aUserFld     := {}
Local aUserFolders := {}
Local aTitulo      := {}
Local aPages       := {}
Local nTotUsFld    := 0
Local nFld         := 0     
Local nPos         := 0  
Local nPosCodAte   := 0
Local nPosQUEDOE   := 0
Local nPosQUECLI   := 0
Local nPosQUIFAM   := 0
Local nPosDESREC   := 0
Local nPosQUEEXA   := 0
Local nPosQUECON   := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis IntegraГЦo Prontuario Eletronico GH                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aDataPls		:= {"","","","","", "", "", "", "", "", ""}		
Local cCodPlaGH		:= "" 
Local cAteHsp		:= ""
Local aRetHsp		:= ""
Private aCodUsr    	:= {}
Private lIntHsp 	:= GetMv("MV_INTPEGH",,.F.)  // Parametro que identIfica que sera utilizado a rotina de Prontuario Eletronico do GH
Private __nOpcAnmGH	:= 0
Private __cRegAtGh 	:= ""
Private nFolder     := 1
Private nFolderAnt  := 1
Private cFileO
Private oBrwEvo
Private aCabEvo     := {}
Private aDadEvo     := {}
Private aTrbEvo     := {}
Private cCodPac     := BBD->BBD_CODPAC                                         
Private cCodCre     := BBD->BBD_CODIGO
Private lEvol       := .F.
Private nOpcUpt     := nOpc
Private oBrwBTI
Private oBrwBPJ 
Private aTela       := {}
Private aGets       := {}
Private aCols       := {}
Private aHeader     := {}                                                        
Private aButtons    := {} 

aRotina   := { { STR0004   , "AxPesqui"   , 0 , K_Pesquisar  },;  //"Pesquisar"
                        { STR0005  , "PLSA305MOV" , 0 , K_Visualizar },;  //"Visualizar"
                        { STR0006  , "PLSA305MOV" , 0 , K_Atend      },; //"Atendimento"
                        { STR0007  , "PLSA305MOV" , 0 , K_Alterar    },; //"Alterar"
                        { STR0008  , "PLSA305MOV" , 0 , K_Cancelar   },;//"Cancelar"
                        { "xxxxxxxxx"   , "PLSA305MOV" , 0 , 6 } }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend .And. BBD->BBD_DATA <> dDataBase
   MsgInfo(STR0009) //"Esta agenda so podera ser visualizada"
   BBD->( dbGoto(nRecBBD) )
   Return
EndIf   

If nOpc == K_Alterar .And. BBD->BBD_STATUS <> "4"
   MsgInfo(STR0010) //"Nao e possivel alterar um paciente em espera..."
   BBD->( dbGoto(nRecBBD) )
   Return
EndIf   

If nOpc <> K_Visualizar .And. nOpc <> K_Excluir
   nOpc := K_Atend
EndIf   

If nOpc == K_Atend .And. BBD->BBD_STATUS == "4" .And. nOpcUpt <> K_Alterar
   MsgInfo(STR0011) //"Atendimento ja realizado..."
   BBD->( dbGoto(nRecBBD) )
   Return
EndIf 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё testa se existem registros no Browse...                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BBD->(Eof())
	BBD->( dbGoto(nRecBBD) )
   	Return
EndIf    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё O paciente deve estar em espera...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If 	nOpc == K_Atend .And.;
	BBD->BBD_STATUS <> '5' .And.;
	BBD->BBD_STATUS <> '6' .And.;
	nOpcUpt <> K_Alterar 
	MsgInfo(STR0012) //"O Paciente deve estar em espera para ser atendido pelo Medico"       
	BBD->( dbGoto(nRecBBD) )
	Return		
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё testa se pode alterar...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Atend .And. BBD->BBD_STATUS <> "4" .And. nOpc <> K_Visualizar
   MsgInfo(STR0013) //"Nao e possivel alterar ou visualizar sem realizar o atendimento"
   BBD->( dbGoto(nRecBBD) )
   Return
EndIf              

cBTHquedoe := ""
cBTHquecli := ""
cBTHquIfam := ""
cBTHdesrec := ""
cBTHqueexa := ""
cBTHquecon := ""
cBTHquepri := ""
cCadastro  := STR0001
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no usuario...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1")+BBD->BBD_CODPAC))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend .And. nOpcUpt <> K_Alterar
	Copy cAliasEnc To Memory Blank
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados...                                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	M->BTH_DATA   := dDataBase
	M->BTH_HORINI := Time()
	M->BTH_CODPAC := BBD->BBD_CODPAC
	M->BTH_NOMPAC := BBD->BBD_NOME          
	If BTH->(Fieldpos("BTH_TIPPAC") )> 0
		M->BTH_TIPPAC := BBD->BBD_TIPPAC	
	Endif	
	M->BTH_IDADE  := If(!Empty(BA1->BA1_DATNAS),Calc_Idade(dDataBase,BA1->BA1_DATNAS),0)	
	M->BTH_QUEDOE := ""
	M->BTH_QUECLI := ""
	M->BTH_QUIFAM := ""
	M->BTH_DESREC := ""
	M->BTH_QUEEXA := ""
	M->BTH_QUECON := ""	
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no atendimento da consulta posicionada...                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BTH->(DbSetOrder(1))
	If BBD->BBD_STATUS == "4" .And. BTH->(MsSeek(xFilial("BTH")+BBD->(BBD_NUMATE))) 
  	    
  	    Copy cAliasEnc To Memory 
	
		// na primeira vez, ao entrar no sistema, nao estava preencehndo este campo - inexplicavel (AGS 02/03/2004)
		// mesmo tendo inicializador padrao. So ocorria na 1. vez que entrava no programa
		M->BTH_QUEDOE := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_QUEDOE","BS7_MEMO")
		M->BTH_QUECLI := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_QUECLI","BS7_MEMO")
		M->BTH_QUIFAM := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_QUIFAM","BS7_MEMO")
		M->BTH_DESREC := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_DESREC","BS7_MEMO")
		M->BTH_QUEEXA := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_QUEEXA","BS7_MEMO")
		M->BTH_QUECON := posicione("BS7",1,xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+"BTH_QUECON","BS7_MEMO")
	
		nRecBTH    := BTH->(Recno())
		cBTHcodate := M->BTH_CODATE
		cBTHquepri := M->BTH_QUEPRI
		cBTHquedoe := M->BTH_QUEDOE
		cBTHquecli := M->BTH_QUECLI
		cBTHquIfam := M->BTH_QUIFAM
		cBTHdesrec := M->BTH_DESREC
		cBTHqueexa := M->BTH_QUEEXA
		cBTHquecon := M->BTH_QUECON
		cBTHidade  := M->BTH_IDADE
		dBTHdatret := M->BTH_DATRET
		nBTHpeso   := M->BTH_PESO
		nBTHaltura := M->BTH_ALTURA
		cBTHpreart := M->BTH_PREART
		cBTHfrecar := M->BTH_FRECAR
		nBTHtemper := M->BTH_TEMPER
		cBTHCID    := M->BTH_CID
		dBTHdata   := M->BTH_DATA
		cBTHhorini := M->BTH_HORINI
		cBTHhorfin := M->BTH_HORFIN  
	Else
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Realizo uma pesquisa invalida para posicionar em EOF e              Ё
		//Ё retornar campos vazios                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BTH->(MsSeek(xFilial("BTH")+Replicate("Z",len(BBD->(BBD_NUMATE)))))
  	    Copy cAliasEnc To Memory  
  	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona no usuario...                                                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA1->(DbSetOrder(2))
		BA1->(MsSeek(xFilial("BA1")+BBD->BBD_CODPAC))  
		M->BTH_CODPAC := BBD->BBD_CODPAC
  		M->BTH_NOMPAC := BBD->BBD_NOME    
		M->BTH_IDADE  := If(!Empty(BA1->BA1_DATNAS),Calc_Idade(dDataBase,BA1->BA1_DATNAS),0)	
	EndIf	
EndIf   

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados das Solicitacoes...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BTI" TO aCabBTI For .T.
If nOpc == K_Incluir
   Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
Else
   BTI->(DbSetOrder(1))
   If ! BTI->(MsSeek(xFilial("BTI")+BBD->BBD_NUMATE))
      Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
   Else
      Store COLS "BTI" TO aDadBTI FROM aCabBTI VETTRAB aTrbBTI While BTI->(BTI_FILIAL+BTI_CODATE) == xFilial("BTI")+BBD->BBD_NUMATE
   EndIf
EndIf    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da Obstetricia.....                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BPJ" TO aCabBPJ For .T.
If nOpc == K_Incluir                                                                                   
   Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
Else
   BPJ->(DbSetOrder(1))
   If ! BPJ->(MsSeek(xFilial("BPJ")+BBD->BBD_NUMATE+BBD->BBD_CODPAC))
      Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
   Else
      Store COLS "BPJ" TO aDadBPJ FROM aCabBPJ VETTRAB aTrbBPJ While BPJ->(BPJ_FILIAL+BPJ_CODATE+BPJ_CODPAC) == xFilial("BPJ")+BBD->BBD_NUMATE+BBD->BBD_CODPAC
   EndIf
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta evolucao do paciente...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BTH" TO aCabEvo For .T.

BTH->(DbSetOrder(4))
If BTH->(MsSeek(xFilial("BTH")+BBD->(BBD_MATVID)))
   Store COLS "BTH" TO aDadEvo FROM aCabEvo VETTRAB aTrbEvo While BTH->(BTH_FILIAL+BTH_MATVID) == xFilial("BTH")+BBD->(BBD_MATVID) //For BTH->(Recno()) <> nRecBTH
   lEvol := Len(aDadEvo)>0
EndIf

If nRecBTH > 0
	BTH->(DbSetOrder(nOrdBTH))
	BTH->(DbGoTo(nRecBTH))
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no proximo horario...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend .And. BBD->BBD_STATUS == "4" .And. nOpcUpt <> K_Alterar
   BBD->(DbSkip())
   BBD->( dbGoto(nRecBBD) )
   Return
EndIf
                                                                              
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Motivo da verIficacao de periodicidade neste ponto:          		         Ё
//|  A rotina de periodicidade da marcacao soh concidera agendas ja 			 |
//|  confirmadas pela recepcao e que ja geraram guias ativas. Caso o atendente	 |
//|  Marque duas agendas, uma apos a outra, a rotina nao ira coompreender a 	 |
//|  periodicidade. Entao ao efetuar o atendimento medico, o sistema efetuara	 |
//|  novamente esta verIficacao e caso seja constatada, o segundo atendimento 	 |
//|  sera caracterizado automaticamente como REVISAO/RETORNO.					 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lPeriod := .F.
If BBD->BBD_TIPO <> '2' .And. Empty(BBD->BBD_NUMATE)
	aRet := PLSA300CAR(BBD->BBD_CODPAC,IIf(BBD->( FieldPos("BBD_ATERNA") )>0,BBD->BBD_ATERNA,"0"),BBD->BBD_CODIGO,BBD->BBD_Local,BBD->BBD_CODESP,.F.)
	lRet := IIf( ValType(aRet[1]) == 'L', aRet[1], .F.)
	
	// So trata se for critica de periodicidade...
	If !lRet .and. Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018' .and. Empty(BBD->BBD_USRFRC) // Desconsiderar se foi forcado.
		BR8->( dbSetorder(01) )
		If BR8->( MsSeek(xFilial("BR8")+BBD->BBD_CODPAD+BBD->BBD_CODPRO) )
			cDesPro := Alltrim(BR8->BR8_DESCRI)
		EndIf
		
		While .T.
			nOpcao := Aviso(STR0014, STR0015,; //"Periodicidade", "A periodicidade permitida foi excedida. Este atendimento serА caracterizada como REVISцO!"
			{"&"+STR0016, STR0017, STR0018})//"Detalhes""Continuar""Retornar"
			
			If nOpcao == 1
				// Visualiza critica com todos os detalhes padroes...
				PLSMOVCRI("1",{BBD->BBD_CODPAD,BBD->BBD_CODPRO,cDesPro,"001"},aRet[2],.F.)
				
			ElseIf nOpcao == 2
				lPeriod := .T.
				Exit
				
			Else
				Return(.F.)
				
			EndIf
		Enddo
	ElseIf !lRet .and. Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018' .and. !Empty(BBD->BBD_USRFRC)
		Aviso(STR0034, STR0035,; //"Periodicidade"###"Este atendimento foi forГado pelo atendimento!"
		{STR0017})	 //"Continuar"
		
	EndIf
EndIf
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta file de entrada e saida (msg)...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFileI := cPrefFil+BBD->(BBD_CODIGO)+"I.SMF"
cFileO := cPrefFil+BBD->(BBD_CODIGO)+"O.SMF"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza status quando entrar em atendimento...                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend .and. BBD->BBD_STATUS == '5' // entra apenas se o paciente estiver em espera. 
												 // Nao pode ser considerado na alteracao.
	BBD->(RecLock("BBD",.F.))
    	BBD->BBD_STATUS := '6'
	    BBD->BBD_HORENT := Left(Time(),5)
		BBD->BBD_CODCAN	:= ''
		BBD->BBD_HORCAN	:= ''
		If BBD->( FieldPos("BBD_DATCAN") ) > 0
		   BBD->BBD_DATCAN := Ctod('')
		EndIf
	    BBD->BBD_USUOPE	:= PLRETOPE() 
	BBD->(MsUnlock())
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Altera mensagem para o medico visualizar que esta atendendo uma revisao...   |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BBD->BBD_TIPO == '2' .or. lPeriod
	cCadastro += " - REVISцO"
EndIf
/*
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё IntegraГЦo com o Prontuario Eletronico do GestЦo Hospitalar                  |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

╠╠╨          Ё    aDataPls[1] := Codigo Paciente (Carteirinha)            ╨╠╠ 
╠╠╨          Ё    aDataPls[2] := Codigo Atendimento PLS(BBD/BTH)          ╨╠╠ 
╠╠╨          Ё    aDataPls[3] := Codigo Plano paciente PLSxGH(BI3_HSPPLA) ╨╠╠ 
╠╠╨          Ё    aDataPls[4] := Codigo RDA / Medico PLS                  ╨╠╠ 
╠╠╨          Ё    aDataPls[5] := Codigo CBO Especialidade Medico PLS      ╨╠╠ 
╠╠╨          Ё    aDataPls[6] := BBD_CODIGO								   ╠╠
╠╠╨          Ё    aDataPls[7] := BBD_CODINT								  ╨╠╠ 
╠╠╨          Ё    aDataPls[8] := BBD_CODLOC								  ╨╠╠ 
╠╠╨          Ё    aDataPls[9] := BBD_DATA								  ╨╠╠ 
╠╠╨          Ё    aDataPls[10] := BBD_ATEHSP							  ╨╠╠ 
╠╠╨          Ё    aDataPls[10] := BBD_STATUS							  ╨╠╠ 
*/
If lIntHsp         
	If !Empty(BA1->BA1_CODPLA)
		cCodPlaGH	:= Posicione("BI3",1,xFilial("BI3")+BA1->BA1_CODINT+BA1->BA1_CODPLA,"BI3_HSPPLA") 
	Else 
		DbSelectArea("BA3")
		DbSetOrder(1)
		If DbSeek(xFilial("BA3") + BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC)
			cCodPlaGH	:= Posicione("BI3",1,xFilial("BI3")+BA1->BA1_CODINT+BA3->BA3_CODPLA,"BI3_HSPPLA") 
		EndIf
	EndIf
	If Empty(cCodPlaGH)
		MsgInfo(STR0044)	//"и necessАrio atribuir o cСdigo do Plano para o GestЦo Hospitalar, no cadastro do Plano (BI3_HSPPLA)!"
		Return()
	Else
		aDataPls[1] := BBD->BBD_CODPAC
		aDataPls[2] := BBD->BBD_NUMATE
		aDataPls[3] := cCodPlaGH 
		aDataPls[4] := BAU->BAU_CODIGO
		aDataPls[5] := Posicione("BAQ",1,xFilial("BAQ")+BA1->BA1_CODINT+BBD->BBD_CODESP,"BAQ_CBOS")
		aDataPls[6] := BBD->BBD_CODIGO
		aDataPls[7] := BBD->BBD_CODINT
		aDataPls[8] := BBD->BBD_CODLOC
		aDataPls[9] := DTOS(BBD->BBD_DATA) 
		aDataPls[10] := BBD->BBD_ATEHSP
		aDataPls[11] := BBD->BBD_STATUS		
				
		HS_MntMA7("GCY", 0, IIf(nOpc == K_Visualizar,2,IIf(nOpc == K_Alterar,4,3)),,,,,lIntHsp,aDataPls)
		Hs_TabPLS("F",xFilial("BI3"), .T.)		
		If Type("__cRegAtGh")<>"U" .AND. !Empty(__cRegAtGh)
			cAteHsp := __cRegAtGh		
			nOpca 	:= __nOpcAnmGH
		EndIf
	EndIf
EndIf
       
If !lIntHsp // Utiliza o Prontuario do PLS
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define dialogo...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	
	
	  DEFINE MSDIALOG oDlg TITLE cCadastro FROM 050,100 TO 88,235 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define folder...                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ExistBlock("PL305ATM")
		aUserFld  := ExecBlock("PL305ATM",.F.,.F.,{.F.})
		nQtdUsFld := Len(aUserFld)
	EndIf
	
	aTitulo	:= {STR0006,STR0019}
	aPages 	:= {"PLA035_1","PLA035_2"}
	
	If lEvol
		aadd(aTitulo,STR0020)
		aadd(aTitulo,STR0021)
		aadd(aPages,"PLA035_3")
		aadd(aPages,"PLA035_4")
	Else
		aadd(aTitulo,STR0021)
		aadd(aPages,"PLA035_3")
	EndIf
	
	For Ifld := 1 To Len(aUserFld)
		aadd(aTitulo,aUserFld[Ifld])
		aadd(aPages,"PLA035_"+AllTrim(str(nQtdUsFld+Ifld)))
	Next
	
	
	oFolder := TFolder():New(032,004,aTitulo,aPages,oDlg,,,, .T.,.F.,520,240,)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define enchoice...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	M->BTH_QUEDOE := cBTHquedoe
	M->BTH_QUECLI := cBTHquecli
	M->BTH_QUIFAM := cBTHquIfam
	M->BTH_DESREC := cBTHdesrec
	M->BTH_QUEEXA := cBTHqueexa
	M->BTH_QUECON := cBTHquecon
	
	If BTH->(Fieldpos("BTH_TIPPAC") )> 0
		cFieldBTH := "BTH_CODPAC,BTH_NOMPAC,BTH_CODATE,BTH_QUEPRI,BTH_QUEDOE,BTH_QUECLI,BTH_QUIFAM,BTH_DESREC,BTH_QUEEXA,BTH_QUECON,BTH_IDADE,BTH_DATRET,BTH_PESO,BTH_ALTURA,BTH_PREART,BTH_TEMPER,BTH_CID,BTH_DESCID,BTH_TIPPAC"
	Else
   		cFieldBTH := "BTH_CODPAC,BTH_NOMPAC,BTH_CODATE,BTH_QUEPRI,BTH_QUEDOE,BTH_QUECLI,BTH_QUIFAM,BTH_DESREC,BTH_QUEEXA,BTH_QUECON,BTH_IDADE,BTH_DATRET,BTH_PESO,BTH_ALTURA,BTH_PREART,BTH_TEMPER,BTH_CID,BTH_DESCID"
	Endif

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ponto de entrada para adicionar campos do Alias BTH no folder Atendimento Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ExistBlock("PLFIL305")
	    cFieldBTH += "," + ExecBlock("PLFIL305",.F.,.F.)
	EndIf

	STORE FIELD "BTH" TO aCpo01 FOR AllTrim(X3_CAMPO) $ cFieldBTH .Or. (SX3->X3_PROPRI == "U" .And. SX3->X3_VISUAL <> "V")
	
	aSvaTela := {}
	aTela    := {}
	aGets    := {}
	cVar     := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
	aadd(aSvaTela,{})
	
	oEnc01 := MsMGet():New(cAliasEnc ,nRecBTH ,K_Alterar,,,,aCpo01,{005,005,220,375},aCpo01,,,,,oFolder:aDialogs[1],,,.T.,cVar)       
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta calendario para melhor visualizacao da data de retorno...          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oPainelC := TPanel():New(05,376,,oFolder:aDialogs[1],,,,,,300,70) 
	
	oCalend:= MsCalend():New(01,01,oPainelC)
	oCalend:ColorDay(1,CLR_HRED)
	oCalend:ColorDay(7,CLR_HRED)
	oCalend:dDiaAtu:=dDataBase
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta browse com as solicitacoes de exames...                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oBrwBTI := TPLSBRW():New(010,005,380,170,nil  ,oFolder:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBTI,aDadBTI,.F.,"BTI",K_Alterar,STR0036,nil,nil,nil,aTrbBTI) //"Solicitacoes"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta browse evolucao do paciente...                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lEvol  
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	//Ё Carrega memos das evolucoes ja preenchidas e alimenta vetor              Ё
   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды        
   		nPosCodAte := ascan(aCabEvo,{|x|x[2] == "BTH_CODATE"})
   		nPosQUEDOE := ascan(aCabEvo,{|x|x[2] == "BTH_QUEDOE"})  
   		nPosQUECLI := ascan(aCabEvo,{|x|x[2] == "BTH_QUECLI"})
  		nPosQUIFAM := ascan(aCabEvo,{|x|x[2] == "BTH_QUIFAM"})
   		nPosDESREC := ascan(aCabEvo,{|x|x[2] == "BTH_DESREC"})
   		nPosQUEEXA := ascan(aCabEvo,{|x|x[2] == "BTH_QUEEXA"})                       
   		nPosQUECON := ascan(aCabEvo,{|x|x[2] == "BTH_QUECON"})  
	
   		For nPos := 1 to len(aDadEvo)  
       		aDadEvo[nPos][nPosQUEDOE] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_QUEDOE","BS7_MEMO")   
	   		aDadEvo[nPos][nPosQUECLI] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_QUECLI","BS7_MEMO")
	   		aDadEvo[nPos][nPosQUIFAM] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_QUIFAM","BS7_MEMO")
      		aDadEvo[nPos][nPosDESREC] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_DESREC","BS7_MEMO")
      		aDadEvo[nPos][nPosQUEEXA] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_QUEEXA","BS7_MEMO")
       		aDadEvo[nPos][nPosQUECON] := posicione("BS7",1,xFilial("BS7")+"BTH"+aDadEvo[nPos][nPosCodAte]+space(38)+"BTH_QUECON","BS7_MEMO")
   		Next	
	
	   oBrwBTH := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabEvo,aDadEvo,.F.,"BTH",K_Visualizar,STR0037,nil,nil,nil,aTrbEvo) //"Evolucao do Paciente"
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Monta browse com a Ficha Obstetrica...                                   Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[4],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,STR0038,nil,nil,nil,aTrbBPJ) //"Obstetricia"
	Else
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Monta browse com a Ficha Obstetrica...                                   Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil , nil ,nil ,nil ,nil, .T. , nil ,.T. ,nil ,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,STR0038,nil,nil,nil,aTrbBPJ) //"Obstetricia"
	EndIf   
	
	If nQtdUsFld > 0
		aUserFolders := {}
		nTotUsFld  	 := Len(oFolder:aDialogs) - nQtdUsFld
		
		For nFld := Len(oFolder:aDialogs) To Len(oFolder:aDialogs)-nQtdUsFld Step -1
			aadd(aUserFolders,oFolder:aDialogs[nFld])
		Next nFld
		
		ExecBlock("PL305ATM",.F.,.F.,{.T.,aUserFolders})
		
	EndIf
	oFolder:bChange := { |nFolder| PLSA305FOL(nFolder) }
	
	If nOpc == K_Atend
	   nHMsg := FCreate(cFileI)
	   FClose(nHMsg)
	   FErase(cFileO)
	EndIf   
	
	If ExistBlock("PLS305BOT")
		aButtons := ExecBlock("PLS305BOT",.F.,.F.)
	EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ativa o dialogo...                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCanc,.F.,aButtons)       
	EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata confirmacao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	If nOpc == K_Atend .Or. nOpc == K_Alterar
		
		PLSA305Grv(nOpcUpt, nRecBBD,(nOpc == K_Atend),lPeriod)
		
		BBD->(DbSkip())
	ElseIf nOpc == K_Cancelar
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicio da transacao...                                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Salva variaveis                                                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cCodAte := BBD->BBD_NUMATE
		cCodPac := BBD->BBD_CODPAC
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza agenda como efetuada...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Copy "BBD" To Memory
		
		M->BBD_NUMATE := ""
		M->BBD_STATUS := "1"

		BBD->(PLUPTENC("BBD",K_Alterar))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza arquivo de consultas a partir de agendas medicas...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !lIntHsp
			While .T.
				If  BS7->(MsSeek(xFilial("BS7")+"BTH"+BTH->BTH_CODATE))
					If  BS7->(RecLock("BS7",.F.))
						BS7->(dbDelete())
						BS7->(msUnLock())
					EndIf
				Else
					Exit
				EndIf
			EndDo
			
			BTH->(PLUPTENC("BTH",K_Excluir))
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Excluia...                                                               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aChave := {}
			aadd(aChave,{"BTI_CODATE",cCodAte})
			oBrwBTI:Grava(aChave)
			While .T.
				If  BS7->(MsSeek(xFilial("BS7")+"BTI"+cCodAte))
					If  BS7->(RecLock("BS7",.F.))
						BS7->(dbDelete())
						BS7->(msUnLock())
					EndIf
				Else
					Exit
				EndIf
			EndDo
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Excluia...                                                               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aChave := {}
			aadd(aChave,{"BPJ_CODATE",cCodAte})
			aadd(aChave,{"BPJ_CODPAC",cCodPac})
			oBrwBPJ:Grava(aChave)
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Finaliza transacao...                                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		End Transaction
	EndIf
	dbCommitAll()
Else
	If nOpc == K_Atend .And. nOpcUpt <> K_Alterar
		/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Necessario alterar BBD neste passo?                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BBD->(RecLock("BBD",.F.))
		BBD->BBD_STATUS := '5'
		BBD->BBD_HORENT := ''
		BBD->BBD_CODCAN	:= ''
		BBD->BBD_HORCAN	:= ''
		If BBD->( FieldPos("BBD_DATCAN") ) > 0
			BBD->BBD_DATCAN := Ctod('')
		EndIf
		BBD->BBD_USUOPE	:= PLRETOPE()
		BBD->(MsUnlock())
		*/
		nHMsg := FCreate(cFileO)
		fWrite(nHMsg,cSala+M->BTH_CODPAC,_nBytes)
		FClose(nHMsg)
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( dbGoto(nRecBBD) )
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305NUM Ё Autor Ё Tulio Cesar         Ё Data Ё 08.01.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna o proximo numero...                                Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305Num(dDataBase)

Local cAno := Subs(dtos(dDataBase),1,4)
Local cRet      
Local nTam := 08
Local nDIf := 1

BTH->(DbSetOrder(1))
BTH->(MsSeek(xFilial("BTH")+cAno+Replicate("9",8),.T.))

BTH->(DbSkip(-1))

nRec := BTH->( RecNo() )
While .T.
	If BTH->(BTH_FILIAL+Subs(BTH_CODATE,1,4)) == xFilial("BTH")+cAno
	   cRet := Subs(BTH->BTH_CODATE,1,4)+StrZero(Val(Subs(BTH->BTH_CODATE,5,8))+nDIf,nTam)
	   If !MsSeek( xFilial("BTH")+cRet )
	   		Exit
	   EndIf 
	   BTH->( dbGoto(nRec) )
	   nDIf++
	Else
	   cRet := cAno+StrZero(1,nTam)
	   Exit
	EndIf       
Enddo

Return(cRet)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305TEL Ё Autor Ё Tulio Cesar         Ё Data Ё 08.01.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Abaixa posicao do mBrowse e exibe mensagens...             Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305Tel(dDataBase,oBrw,cCodInt,cLocal,cCdAmbu,cDsAmbu)
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305GRV Ё Autor Ё Tulio Cesar         Ё Data Ё 08.07.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Grava os dados sem a necessidade de se fechar a tela...    Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLSA305Grv(nOpc, nRecBBD, lAtend, lPeriod)     
Local i
Local nH           
Local aChave                                                                  
Local aMovim	:= {}
LOCAL lMovim    := .F.
LOCAL lReturn   := .F.
Private aDadUsr := {}
Private cCodAte
DEFAULT lAtend	:= .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abre semaforo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := PLSAbreSem("SEMNUMATE.SMF")            

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se existe na base de dados...                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 3
	cCodAte := GetSx8Num("BBD","BBD_NUMATE")
	
Else
   cCodAte := BBD->BBD_NUMATE
   BTH->(DbSetOrder(1))
   BTH->(MsSeek(xFilial("BTH")+cCodAte))
EndIf   

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Garante que o registro vai estar posicionado corretamente...             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( 	dbGoto(nRecBBD) )
    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se estiver em preriodicidade, trata como retorno...                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lPeriod 
	//Altera o tipo da consulta para seja caracterizada como REVISAO/RETORNO
	BBD->( RecLock("BBD", .F.) )
		// Altera para o tipo 
		BBD->BBD_TIPO := '2'
	BBD->( MsUnlock() )
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da transacao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava a movimentacao em primeiro lugar, caso haja criticas, retorna sem fazer nada...|
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 3 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nao gera conta medica para retorno/revisao...            				 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->BBD_TIPO <> '2' .And. Empty(BBD->BBD_NUMMOV)
		aMovim := 	PLSMOVMC( BBD->( Recno() ),"1",BBD->BBD_CODPAD,BBD->BBD_CODPRO,nil,BBD->BBD_CODLOC,BBD->BBD_CODESP )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se houver criticas, apresento e logo em seguida retorna...				 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !aMovim[1] 
			PLSFechaSem(nH,"SEMNUMATE.SMF")
			
			lReturn := .T.
		EndIf
  	EndIf
  	
	If !lReturn
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁAtualiza situacao da agenda, marcando-a como atendida...  				 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BBD->( Reclock("BBD", .F.) )
			BBD->BBD_NUMATE := cCodAte 
			If BBD->BBD_TIPO <> '2' .And. Len(aMovim) > 0
				BBD->BBD_NUMMOV := aMovim[2]
			endIf
			BBD->BBD_STATUS := '4'
			BBD->BBD_HORSAI := Left(Time(),5)
			BBD->BBD_USUOPE	:= PLRETOPE() 
		BBD->( MsUnlock() )
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza mais uma consulta atendida para a sala aberta...                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BGF->(DbSetOrder(3))
	   	If BGF->(MsSeek(xFilial("BGF")+cCodSala+DTOS(dDataBase)))
	    	BGF->(RecLock("BGF",.F.))
		    	BGF->BGF_NATEND := BGF->BGF_NATEND + 1
		    BGF->(MsUnLock())
	   	EndIf   
	EndIf
EndIf   

If (IIf(Type("lIntHsp") == "L", !lIntHsp, .T.)) .AND. !lReturn // IntegraГЦo Prontuario Eletronico Gestao Hospitalar
	If nOpc == 3
	   M->BTH_DATA   := dDataBase
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza prontuario...                                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  nFolderAnt == 1
	    cBTHcodate := M->BTH_CODATE
	    cBTHquepri := M->BTH_QUEPRI
	    cBTHquedoe := M->BTH_QUEDOE
	    cBTHquecli := M->BTH_QUECLI
	    cBTHquIfam := M->BTH_QUIFAM
	    cBTHdesrec := M->BTH_DESREC
	    cBTHqueexa := M->BTH_QUEEXA
	    cBTHquecon := M->BTH_QUECON
	    cBTHidade  := M->BTH_IDADE 
	    dBTHdatret := M->BTH_DATRET
	    nBTHpeso   := M->BTH_PESO  
	    nBTHaltura := M->BTH_ALTURA
	    cBTHpreart := M->BTH_PREART
	    cBTHfrecar := M->BTH_FRECAR
	    nBTHtemper := M->BTH_TEMPER
	    cBTHCID    := M->BTH_CID   
	EndIf
	M->BTH_CODATE := cCodAte                                                  
	M->BTH_QUEPRI := cBTHquepri
	M->BTH_QUEDOE := cBTHquedoe
	M->BTH_QUECLI := cBTHquecli
	M->BTH_QUIFAM := cBTHquIfam
	M->BTH_DESREC := cBTHdesrec
	M->BTH_QUEEXA := cBTHqueexa
	M->BTH_QUECON := cBTHquecon
	M->BTH_MATANT := BBD->BBD_MATANT
	M->BTH_CODCRE := BBD->BBD_CODIGO
	M->BTH_CODINT := BBD->BBD_CODINT
	M->BTH_CODLOC := BBD->BBD_CODLOC
	M->BTH_MATVID := BBD->BBD_MATVID
	M->BTH_CODPAC := BBD->BBD_CODPAC
	M->BTH_NOMPAC := BBD->BBD_NOME
	M->BTH_NOMCRE := Posicione("BAU",1,xFilial("BAU")+BBD->BBD_CODIGO,"BAU_NOME")             
	If BTH->(Fieldpos("BTH_TIPPAC") )> 0
   		M->BTH_TIPPAC := BBD->BBD_TIPPAC  
	Endif	
	M->BTH_DESLOC := "" //Implementar depois com calma...
	M->BTH_DATA   := dBTHdata
	M->BTH_HORINI := cBTHhorini
	M->BTH_DATRET := dBTHdatret
	M->BTH_PESO   := nBTHpeso
	M->BTH_ALTURA := nBTHaltura
	M->BTH_PREART := cBTHpreart
	M->BTH_FRECAR := cBTHfrecar
	M->BTH_TEMPER := nBTHtemper
	M->BTH_CID    := cBTHcid
	M->BTH_IDADE  := cBTHidade
	
	If     nOpc == 3
	       M->BTH_HORFIN := Time()
	       BTH->(PLUPTENC("BTH",K_Incluir))
	Else
	       M->BTH_HORFIN := Time()
	       BTH->(PLUPTENC("BTH",K_Alterar))
	EndIf   
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_QUEDOE"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_QUEDOE"
	EndIf
	BS7->BS7_MEMO := cBTHquedoe
	BS7->(msUnLock())
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_QUECLI"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_QUECLI"
	EndIf
	BS7->BS7_MEMO := cBTHquecli
	BS7->(msUnLock())
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_QUIFAM"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_QUIFAM"
	EndIf
	BS7->BS7_MEMO := cBTHquIfam
	BS7->(msUnLock())
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_DESREC"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_DESREC"
	EndIf
	BS7->BS7_MEMO := cBTHdesrec
	BS7->(msUnLock())
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_QUEEXA"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_QUEEXA"
	EndIf
	BS7->BS7_MEMO := cBTHqueexa
	BS7->(msUnLock())
	
	If  BS7->(MsSeek(xFilial("BS7")+"BTH"+cCodAte+space(38)+"BTH_QUECON"))
	    BS7->(RecLock("BS7",.F.))
	Else
	    BS7->(RecLock("BS7",.T.))
	    BS7->BS7_FILIAL := xFilial("BS7")
	    BS7->BS7_ALIAS  := "BTH"
	    BS7->BS7_CHAVE  := cCodAte
	    BS7->BS7_CAMPO  := "BTH_QUECON"
	EndIf
	BS7->BS7_MEMO := cBTHquecon
	BS7->(msUnLock())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava solicitacoes...                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aChave := {} 
	aadd(aChave,{"BTI_CODATE",cCodAte})
	oBrwBTI:Grava(aChave)
	
	nDel := len(oBrwBTI:aHeader) + 1
	For i := 1 to len(oBrwBTI:aCols)
	    If  ! oBrwBTI:aCols[i,nDel]
	        cCodPad := oBrwBTI:fieldget("BTI_CODPAD",i)
	        cCodPro := oBrwBTI:fieldget("BTI_CODPRO",i)
	        cResult := oBrwBTI:fieldget("BTI_RESULT",i)
	        If  BS7->(MsSeek(xFilial("BS7")+"BTI"+cCodAte+cCodPad+cCodPro+space(20)+"BTI_RESULT"))
	            BS7->(RecLock("BS7",.F.))
	        Else
	            BS7->(RecLock("BS7",.T.))
	            BS7->BS7_FILIAL := xFilial("BS7")
	            BS7->BS7_ALIAS  := "BTI"
	            BS7->BS7_CHAVE  := cCodAte+cCodPad+cCodPro
	            BS7->BS7_CAMPO  := "BTI_RESULT"
	        EndIf
	        BS7->BS7_MEMO := cResult
	        BS7->(msUnLock())
	    EndIf
	Next    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava Obstetricia....                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetKeysBPJ(oBrwBPJ,cCodAte,BBD->BBD_CODPAC)	
	aChave := {} 	
	aadd(aChave,{"BPJ_CODATE",cCodAte})
	aadd(aChave,{"BPJ_CODPAC",BBD->BBD_CODPAC})
	oBrwBPJ:Grava(aChave) 
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction

If !lReturn
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza semaforo da reserva de horarios...                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpc == 3
	   nHMsg := FCreate(cFileO)
	   fWrite(nHMsg,cSala+M->BTH_CODPAC,_nBytes)
	   FClose(nHMsg)
	EndIf                    
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha o semaforo unIficado da geracao de guias...                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSFechaSem(nH,"SEMNUMATE.SMF")  
	
	//зддддддддддддддддддддддддддддддд©
	//ЁGrava o CID nas tabelas de GuiaЁ
	//юддддддддддддддддддддддддддддддды
	If Len(aMovim) > 2
		BD5->(DBGoTo(aMovim[3])) // a chave utilizada no BBD_NUMMOV se repete
		BEA->(DBGoTo(aMovim[4]))
		lMovim := .T.
	EndIf
	BD5->(dbSetOrder(1))
	If lMovim .Or. BD5->( dbSeek( xFilial("BD5") + BBD->BBD_NUMMOV ) )
		
		BD5->(RecLock("BD5",.F.))
		
		BD5->BD5_TIPPAC := IIf(BTH->( FieldPos("BTH_TIPPAC") ) > 0,BTH->BTH_TIPPAC, getNewPar("MV_PLSTPAA","9") )
		BD5->(MsUnlock())
		
		BEA->( DbSetorder(13) )
		If  lMovim .Or. BEA->( DbSeek(xFilial("BEA")+Iif(!lMovim,BD5->BD5_NUMATE,BD5->())) )
			BEA->(RecLock("BEA", .F.))
			
			BEA->BEA_TIPADM := "6"
			BEA->BEA_TIPPAC := IIf(BTH->( FieldPos("BTH_TIPPAC") ) > 0,BTH->BTH_TIPPAC, getNewPar("MV_PLSTPAA","9") )
			BEA->BEA_TRACON := "0"
			BEA->BEA_TIPATE := "04"
			
			BEA->(MsUnlock())
		Endif
		
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprissao de guias somente para consultas ou encaixes...                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->BBD_TIPO $ '1,4'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime a guia do atendimento...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BBD->BBD_CODEMP == cInterc
			If Aviso(STR0039,STR0040,{STR0041,STR0042}) == 1 //"Impressao"###"Imprimir a guia agora ?"###"Sim"###"Nao"
			   PLSA090Ima()
			EndIf
		EndIf
	EndIf	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Confirma numeracao do atendimento...                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( ConfirmSX8() )
EndIf

Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA305GUI Ё Autor Ё Tulio Cesar          Ё Data Ё 27.01.03 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Espelha dados de um atendimento em um PEG/GUIA              Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Function PLSA305GUI(cNumAte,dDataBase)

Local I__f        := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara variaveis da rotina...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nH          := PLSAbreSem("PLSA305ESP.SMF")
Local cNumGuia
Local nFor     
Local nTmp
Local nAux
Local aFiles             
Local cAliasAux
Local nPos       
Local cAliasPri                     
Local cCpoFase 
Local aColsAux
Local cCampos
Local aStruBBD    := BBD->(DbStruct())
Local aRetCal     := PLSXVLDCAL(dDataBase,BBD->BBD_CODINT,.F.)
Local cAnoBase    := aRetCal[4]
Local cMesBase    := aRetCal[5]
Local nHESP       := 0
Local nStackSX8   := GetSx8Len()

Private cOpeRDA   := BBD->BBD_CODINT
Private cCodRDA   := BBD->BBD_CODIGO
Private cNomRDA   := BAU->BAU_NOME
Private cTipRDA   := BAU->BAU_TIPPE
Private cFunGRV
Private cTipGRV
Private cTipoGuia 
Private cGuiRel   
Private cNewPEG
Private aDadUSR   := PLSDADUSR(BBD->BBD_CODPAC,"1",.T.,BBD->BBD_DATA)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica se existe o PEG eletronico do mes para o credenciado...         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BCI->(DbSetOrder(4))

nHESP := PLSAbreSem("PLSPEG.SMF")
If ! BCI->(MsSeek(xFilial("BCI")+cOpeRDA+cCodRDA+cAnoBase+cMesBase+"211"))

   cNewPEG := PLSA175Cod(cOpeRDA,GetNewPar("MV_PLSPEGE","0000"))
   
   BCI->(RecLock("BCI",.T.))
   BCI->BCI_FILIAL := xFilial("BCI")
   BCI->BCI_CODOPE := cOpeRDA
   BCI->BCI_PROTOC := CriaVar("BCI_PROTOC")
   BCI->BCI_CODLDP := GetNewPar("MV_PLSPEGE","0000")
   BCI->BCI_CODPEG := cNewPEG
   BCI->BCI_OPERDA := cOpeRDA
   BCI->BCI_CODRDA := cOpeRDA
   BCI->BCI_TIPSER := GetNewPar("MV_PLSTPSP","01")
   BCI->BCI_TIPGUI := GetNewPar("MV_PLSTPGC","01")

   BCL->(DbSetOrder(1))
   BCL->(MsSeek(xFilial("BCL")+cOpeRDA+BCI->BCI_TIPGUI))
   BCI->BCI_QTDGUI := 1
   BCI->BCI_VLRGUI := 0 //REVER
   BCI->BCI_DATREC := dDataBaseBase
   BCI->BCI_DTPRPG := ctod("")
   BCI->BCI_QTDDIG := 1
   BCI->BCI_VALDIG := 0 //REVER
   BCI->BCI_CODCOR := BCL->BCL_CODCOR
   BCI->BCI_FASE   := "1"
   BCI->BCI_SITUAC := "1"
   
   If BCI->( FieldPos("BCI_STTISS") ) > 0 .AND. BCI->BCI_STTISS < "2" 
		BCI->BCI_STTISS := "2" //Em anАlise
	EndIf       
   BCI->BCI_MES    := cMesBase
   BCI->BCI_ANO    := cAnoBase
   BCI->BCI_TIPO   := "2"
   BCI->(MsUnLock())

   While GetSx8Len() > nStackSX8
	   BCI->( ConfirmSX8() )
   EndDo		   
   
Else
   BCL->(DbSetOrder(1))
   BCL->(MsSeek(xFilial("BCL")+cOpeRDA+BCI->BCI_TIPGUI))
EndIf
PLSFechaSem(nHESP,"PLSPEG.SMF")

cTipoGuia := BCL->(BCL_TIPGUI)
cGuiRel   := BCL->BCL_GUIREL
cFunGRV   := BCL->BCL_FUNGRV
cTipGRV   := BCL->BCL_TIPGRV
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio do processo de gravacao das guias...                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aFiles   := PLSA500Fil(BCI->BCI_CODOPE,BCI->BCI_TIPGUI)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os Objetivos...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aFiles)

    cAliasAux := aFiles[nFor,1]

    If Empty(cAliasPri)
    
       cAliasPri := aFiles[nFor,1]
       cNumGuia  := PLSA500NUM(cAliasPri,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
       
    EndIf   

    If aFiles[nFor,3] == "2"

       Copy cAliasAux To Memory Blank

       For nAux := 1 To Len(aStruBBD)
           If TYPE(cAliasPri+"->"+StrTran(aStruBBD[nAux,1],"BBD",cAliasPri)) <> "U"
              &("M->"+cAliasAux+Subs(aStruBBD[nAux,1],4,10)) := &("BBD->"+aStruBBD[nAux,1])
           EndIf   
       Next                            

       &("M->"+cAliasAux+"_CODOPE") := BCI->BCI_CODOPE
       &("M->"+cAliasAux+"_CODLDP") := BCI->BCI_CODLDP
       &("M->"+cAliasAux+"_CODPEG") := BCI->BCI_CODPEG
       &("M->"+cAliasAux+"_NUMERO") := cNumGuia
       &("M->"+cAliasAux+"_TIPGUI") := BCI->BCI_TIPGUI
       
       PLUPTENC(cAliasAux,K_Incluir)
    Else                       
	   FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0043, 0, 0, {})//"Gravacao de itens nao implementada"
    EndIf   
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa funcao de gravacao dos dados...                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! Empty(cFunGRV)
   If cTipGRV == "1"                         
      aPar   := {K_Incluir,cOpeRDA,BCI->BCI_CODLDP,BCI->BCI_CODPEG,cNumGuia,.T.}
       cMacro := (AllTrim(cFunGRV)+"(aPar)")
       &(cMacro)
    Else
       ExecBlock(cFunGRV,.F.,.F.,{K_Incluir})
    EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Muda a fase da guia...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCpoFase := (cAliasPri+"->"+cAliasPri+"_FASE")

If ! Empty(BCL->BCL_FUNMFS)
   If BCL->BCL_TIPGRV == "1"                         
      aPar   := {cAliasPri,"1",cOpeRDA,cTipoGuia,&cCpoFase,BCI->BCI_CODLDP,BCI->BCI_CODPEG,"",BCL->BCL_GUIREL,.T.,dDataBase}
      cMacro := (AllTrim(BCL->BCL_FUNMFS)+"(aPar)")
      aRetAux := &(cMacro)
   Else
      aRetAux := ExecBlock(BCL->BCL_FUNMFS,.F.,.F.,{cAliasPri,"2",cOpeRDA,"2"&cCpoFase,BCI->BCI_CODLDP,BCI->BCI_CODPEG,"",BCL->BCL_GUIREL,.T.,dDataBase})
   EndIf
EndIf 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava ultimos dados na guia de autorizacao...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->(RecLock("BBD",.F.))
BBD->BBD_ANOPAG := cAnoBase
BBD->BBD_MESPAG := cMesBase
BBD->BBD_OPEPEG := cOpeRDA
BBD->BBD_CODLDP := BCI->BCI_CODLDP
BBD->BBD_CODPEG := BCI->BCI_CODPEG
BBD->BBD_NUMGUI := cNumGuia
BBD->(MsUnLock())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza transacao fisica...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSFechaSem(nH,"PLSA305ESP.SMF")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return


Function PLSA305ATU

BBD->(MsSeek(xFilial("BBD")))

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305FOL Ё Autor Ё Angelo Sperandio    Ё Data Ё 10.02.04 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Funcao para salvar/compor campos de memoria conforme o     Ё╠╠╠
╠╠Ё          Ё folder utilizado, em funcao de haver 2 folders utilizando  Ё╠╠╠
╠╠Ё          Ё o mesmo alias (BTH)                                        Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305FOL(nFolder)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva/compoe campos de memoria conforme o folder utilizado               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nFolder == 1 
    M->BTH_CODATE := cBTHcodate
    M->BTH_QUEPRI := cBTHquepri
    M->BTH_QUEDOE := cBTHquedoe
    M->BTH_QUECLI := cBTHquecli
    M->BTH_QUIFAM := cBTHquIfam
    M->BTH_DESREC := cBTHdesrec
    M->BTH_QUEEXA := cBTHqueexa
    M->BTH_QUECON := cBTHquecon
    M->BTH_IDADE  := cBTHidade 
    M->BTH_DATRET := dBTHdatret
    M->BTH_PESO   := nBTHpeso  
    M->BTH_ALTURA := nBTHaltura
    M->BTH_PREART := cBTHpreart
    M->BTH_FRECAR := cBTHfrecar
    M->BTH_TEMPER := nBTHtemper
    M->BTH_CID    := cBTHCID   
Else
    If  nFolderAnt == 1
        cBTHcodate := M->BTH_CODATE
        cBTHquepri := M->BTH_QUEPRI
        cBTHquedoe := M->BTH_QUEDOE
        cBTHquecli := M->BTH_QUECLI
        cBTHquIfam := M->BTH_QUIFAM
        cBTHdesrec := M->BTH_DESREC
        cBTHqueexa := M->BTH_QUEEXA
        cBTHquecon := M->BTH_QUECON
        cBTHidade  := M->BTH_IDADE 
        dBTHdatret := M->BTH_DATRET
        nBTHpeso   := M->BTH_PESO  
        nBTHaltura := M->BTH_ALTURA
        cBTHpreart := M->BTH_PREART
        cBTHfrecar := M->BTH_FRECAR
        nBTHtemper := M->BTH_TEMPER
        cBTHCID    := M->BTH_CID   
    EndIf
EndIf    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva numero do folder utilizado                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nFolderAnt := nFolder
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA305INI Ё Autor Ё Angelo Sperandio    Ё Data Ё 06.03.04 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Funcao para retornar conteudo de campo memo da tabela      Ё╠╠╠
╠╠Ё          Ё BS7-Campos Memo, com base no BTH corrente                  Ё╠╠╠
╠╠Ё          Ё Utilizada no inicializador padrao dos campos memo do BTH   Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSA305INI(cCampo)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cRet := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa BS7-Campos Memo                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BS7->(dbsetOrder(1))
If  BS7->(MsSeek(xFilial("BS7")+"BTH"+BTH->BTH_CODATE+space(38)+cCampo))
    cRet := BS7->BS7_MEMO
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao existe o campo memo no BS7 ou ele esta vazio, retorna um          Ё
//Ё caracter nao visivel, pois se retornar vazio ou espacos, o microsiga     Ё
//Ё ira exibir o conteudo do campo do BTH posicionado (padrao que tem que    Ё
//Ё ser revisto ???)                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  empty(cRet)
    cRet := chr(13)
EndIf    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(cRet)        
   
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA260LEG Ё Autor ЁGeraldo Felix Junior Ё Data Ё 04.10.03 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exibe a legenda...                                         Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA305Leg()

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё04/01/2007Ё╠╠
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

Local aRetRotina := {}

If !GetMv("MV_INTPEGH",,.F.)   
	aRetRotina := {	{ STR0004  , "AxPesqui"   , 0 , K_Pesquisar  , 0, .F.},; //"Pesquisar"
							{ STR0005  , "PLSA305MOV" , 0 , K_Visualizar , 0, Nil},; //"Visualizar"
							{ STR0006  , "PLSA305MOV" , 0 , K_Atend      , 0, Nil},; //"Atendimento"
							{ STR0007  , "PLSA305MOV" , 0 , K_Alterar    , 0, Nil},; //"Alterar" 
							{ STR0008  , "PLSA305MOV" , 0 , K_Cancelar   , 0, Nil},; //"Cancelar" 
							{ STR0030  , "PLSA305ATU" , 0 , 6            , 0, Nil},; //"Atualizar"
							{ STR0031  , "PLSA305LEG" , 0 , K_Visualizar , 0, .F.}}  //"Legenda"   	
Else // Caso tenha integraГЦo com o Prontuario Eletronico do GestЦo Hospitalar nЦo habilita a alteraГЦo/cancelamento
	aRetRotina := {	{ STR0004  , "AxPesqui"   , 0 , K_Pesquisar  , 0, .F.},; //"Pesquisar"
							{ STR0005  , "PLSA305MOV" , 0 , K_Visualizar , 0, Nil},; //"Visualizar"
							{ STR0006  , "PLSA305MOV" , 0 , K_Atend      , 0, Nil},; //"Atendimento"
							{ STR0030  , "PLSA305ATU" , 0 , 6            , 0, Nil},; //"Atualizar"
							{ STR0031  , "PLSA305LEG" , 0 , K_Visualizar , 0, .F.}}  //"Legenda"   	
EndIf					
						
Return(aRetRotina)

/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁSetKeysBPJ╨Autor  ЁPLS-Team            ╨ Data Ё 23/02/2011  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁAltera o valor do acols, antes da gravao.                   ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       |PLSA305                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function SetKeysBPJ(oBrwBPJ,cCodAte,cCodPac)

Local nPosCodPac := 0
Local nPosCodAte := 0
Local nXItem := 0

nPosCodPac := Ascan(oBrwBPJ:aHeader, {|x|Upper(x[2]) == "BPJ_CODPAC"})
nPosCodAte := Ascan(oBrwBPJ:aHeader, {|x|Upper(x[2]) == "BPJ_CODATE"})  

If nPosCodPac > 0 .Or. nPosCodAte > 0
	For nXItem := 1 To Len(oBrwBPJ:aCols)
		If nPosCodPac > 0 
			oBrwBPJ:aCols[nXItem,nPosCodPac] := cCodPac 
		EndIf
		If nPosCodAte > 0 		
			oBrwBPJ:aCols[nXItem,nPosCodAte] := cCodAte 
		EndIf		
	Next nXItem		
EndIf
	
Return .T. 

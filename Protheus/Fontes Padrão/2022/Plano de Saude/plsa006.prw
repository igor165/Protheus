#INCLUDE "PLSA006.ch"
#include "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA006   ºAutor  ³Microsiga           º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Browse da Tabela BAU para selecao de uma RDA.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSA006()

Private aCols     := {}
Private aHeader   := {}
Private cCadastro := Fundesc() //"Rede de Atendimento"
Private cAlias    := "BAU"
Private aRotina   := {}
Private aCores    := {}

aAdd( aRotina, {STR0002     , "AxPesqui"    , 0, 1} ) //"Pesquisar  "
aAdd( aRotina, {STR0003     , "PLSA006Sel"  , 0, 2} ) //"Selecionar "

mBrowse( 6,1,22,75,"BAU")

Return NIL       
                     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA006   ºAutor  ³Microsiga           º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Browse da tabela BB8 com RDA Filtrada.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSA006Sel()

Local cChave		:= BAU->BAU_FILIAL+BAU->BAU_CODIGO
Local cFiltro		:= " BB8_FILIAL+BB8_CODIGO = '" + cChave + "'"  
Private aIndices  := {}
Private aCols     := {}
Private aHeader   := {}
Private cCadastro := STR0004 //"Locais de Atendimento"
Private cAlias    := "BB8"
Private aRotina   := {}
Private aCores    := {}
Private bFiltraBrw:= {|| FilBrowse(cAlias, @aIndices, @cFiltro)}

aAdd( aRotina, {STR0002   , "PesqBrw"    , 0, 1} ) //"Pesquisar  " // quando a função FilBrowse for utilizada a função de pesquisa deverá ser a PesqBrw ao invés da AxPesqui
aAdd( aRotina, {STR0005   , "PLSA006Cop" , 0, 2} ) //"Copiar "

Eval( bFiltraBrw )
dbSelectArea(cAlias)
dbGoTop()

mBrowse( ,,,,cAlias,,,,,,aCores)
EndFilBrw(cAlias,aIndices)

Return NIL       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA006CopºAutor  ³Microsiga           º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de processamento da Clonagem do Local de		      º±±
±±º          ³ atendimento e das tabelas relacionadas.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pls                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSA006Cop() 
Local nOpca       := 0
Local aSays       := {}, aButtons := {}
Private cCadastro := STR0006  //"Clonagem de Local de Atendimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,STR0007) //"Esta rotina irá efetuar a clonagem do Local de Atendimento escolhido."
aadd(aSays,STR0008 ) //" Deseja realmente realizar a Clonagem? "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons,, 250 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa calculo                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpca == 1
	Processa({|lEnd| PLSCopAt(@lEnd)},STR0009,STR0010,.F.) //"Processando"###"Aguarde, processando clonagem do Atendimento"
        MsgInfo(STR0011) //"Clonagem realizada com sucesso !"
Endif
       
Return  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCopAt  ºAutor  ³Microsiga           º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Clonagem do Local de atendimento e das tabelas   º±±
±±º          ³ relacionadas.                                              º±±                                                          
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSCopAt(lEnd)

Local cCodInt   := BB8->BB8_CODINT
Local cRDA      := BB8->BB8_CODIGO
Local cCodLoc   := ""
Local cLocOri   := BB8->BB8_CODLOC
Local cLocal    := BB8->BB8_LOCAL    
Local cDesLoc   := BB8->BB8_DESLOC
Local cCEP      := BB8->BB8_CEP
Local cTipLog   := BB8->BB8_TIPLOG
Local cEnd      := BB8->BB8_END
Local cNum      := BB8->BB8_NR_END
Local cComEnd   := BB8->BB8_COMEND
Local cMunici   := BB8->BB8_CODMUN
Local cMun      := BB8->BB8_MUN
Local cEstado   := BB8->BB8_EST
Local cBairro   := BB8->BB8_BAIRRO
Local cDDD      := BB8->BB8_DDD
Local cTel      := BB8->BB8_TEL
Local cFax      := BB8->BB8_FAX
Local cContato  := BB8->BB8_CONTAT
Local cCarCon   := BB8->BB8_CARCON
Local cGuiMed   := BB8->BB8_GUIMED
Local cTmpCon   := BB8->BB8_TMPCON
Local cObrCli   := BB8->BB8_OBRCLI
Local cVigus    := BB8->BB8_VIGUS
Local cFormul   := BB8->BB8_FORMUL
Local cExpres   := BB8->BB8_EXPRES
Local cCorres   := BB8->BB8_CORRES
Local cCrPloc   := BB8->BB8_CRPLOC
Local cCodide   := BB8->BB8_CODIDE
Local cCodtab   := BB8->BB8_CODTAB
Local cTabPre   := BB8->BB8_TABPRE
Local cTrtexe   := BB8->BB8_TRTEXE
Local cEmail    := BB8->BB8_EMAIL
Local cWeb      := BB8->BB8_WEB
Local cDatBlo   := BB8->BB8_DATBLO
Local nBanda    := BB8->BB8_BANDA
Local cCnes     := BB8->BB8_CNES
Local cCarSol   := BB8->BB8_CARSOL
Local cRegMun   := BB8->BB8_REGMUN
Local nUco      := BB8->BB8_UCO  
Local nValch    := BB8->BB8_VALCH 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa regua de processamento                                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(50)

Begin Transaction  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BB8 - Folder-> Local de Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT DISTINCT BB8_CODLOC "
cSQL += "FROM "+RetSQLName("BB8")+" "+ "BB8 " 
cSQL += "WHERE "
cSQL += "BB8_FILIAL = '"+xFilial("BB8")+"' AND "
cSQL += "BB8_CODIGO = '"+cRDA+"' AND "
cSQL += "BB8_CODINT = '"+cCodInt+"' AND "
cSQL += "BB8.D_E_L_E_T_ = ''"
cSQL += "ORDER BY BB8_CODLOC"

PLSQuery(cSQL,"TrbBB8")

BB8->(DbSetOrder(3))//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_LOCAL  + BB8_CODLOC  

While TrbBB8->(!EOF()) 
	IncProc("...")
	cCodLoc :=  TrbBB8->BB8_CODLOC
	TrbBB8->(dbSkip())
EndDo

If Select("TrbBB8") > 0
	TrbBB8->(dbCloseArea())
Endif

cCodLoc := Soma1(cCodLoc)
    
BB8->(Reclock("BB8",.T.))
    BB8->BB8_FILIAL := xFilial("BB8") 
    BB8->BB8_CODINT := cCodInt
    BB8->BB8_CODIGO := cRDA
    BB8->BB8_CODLOC := cCodLoc
   	BB8->BB8_LOCAL  := cLocal    
   	BB8->BB8_DESLOC := cDesLoc  
   	BB8->BB8_CEP	:= cCEP
    BB8->BB8_TIPLOG	:= cTipLog
    BB8->BB8_END	:= cEnd
	BB8->BB8_NR_END := cNum
	BB8->BB8_COMEND := cComEnd
	BB8->BB8_CODMUN := cMunici
    BB8->BB8_MUN	:= cMun
	BB8->BB8_EST	:= cEstado
	BB8->BB8_BAIRRO := cBairro
	BB8->BB8_DDD	:= cDDD
	BB8->BB8_TEL	:= cTel
	BB8->BB8_FAX	:= cFax
	BB8->BB8_CONTAT := cContato
	BB8->BB8_CARCON := cCarCon
	BB8->BB8_GUIMED := cGuiMed
	BB8->BB8_TMPCON := cTmpCon
	BB8->BB8_OBRCLI := cObrCli
	BB8->BB8_VALCH	:= nValch 
	BB8->BB8_VIGUS	:= cVigus
	BB8->BB8_FORMUL	:= cFormul
	BB8->BB8_EXPRES	:= cExpres
	BB8->BB8_CORRES	:= cCorres
	BB8->BB8_CRPLOC	:= cCrPloc
	BB8->BB8_CODIDE	:= cCodide
	BB8->BB8_CODTAB	:= cCodtab
	BB8->BB8_TABPRE	:= cTabPre
	BB8->BB8_TRTEXE	:= cTrtexe
	BB8->BB8_EMAIL	:= cEmail
	BB8->BB8_WEB	:= cWeb
	BB8->BB8_DATBLO	:= cDatBlo
	BB8->BB8_BANDA	:= nBanda
	BB8->BB8_CNES	:= cCnes
	BB8->BB8_CARSOL	:= cCarSol
	BB8->BB8_REGMUN	:= cRegMun
	BB8->BB8_UCO 	:= nUco
BB8->(MsUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BPI - Folder-> Filme ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BPI_SEQFIL, BPI_VLRFIL, BPI_VIGDE, BPI_VIGATE, BPI_CODINT, BPI_SEQREL  "   
cSQL += "FROM "+RetSQLName("BPI")+" "+ "BPI " 
cSQL += "WHERE "
cSQL += "BPI_FILIAL = '"+xFilial("BPI")+"' AND "
cSQL += "BPI_CODIGO = '"+cRDA+"' AND "
cSQL += "BPI_CODINT = '"+cCodInt+"' AND "
cSQL += "BPI_CODLOC = '"+cLocOri+"' AND "
cSQL += "BPI.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBPI")

While TrbBPI->(!EOF())  
	IncProc("...")
	BPI->(DbSetOrder(1))//BPI_FILIAL + BPI_CODIGO + BPI_CODINT + BPI_CODLOC + BPI_SEQFIL + DTOS(BPI_VIGDE) + DTOS(BPI_VIGATE)                                                                                                                                                                                                                                                                                                                                                   
	If !BPI->( MsSeek(xFilial("BPI") + cRDA + cCodInt + cCodLoc + TrbBPI->(BPI_SEQFIL + DTOS(BPI_VIGDE) + DTOS(BPI_VIGATE)) ) )
	
		BPI->(Reclock("BPI",.T.))
		BPI->BPI_FILIAL := xFilial("BPI")
		BPI->BPI_CODIGO := cRDA
		BPI->BPI_SEQFIL := TrbBPI->BPI_SEQFIL
		BPI->BPI_VLRFIL := TrbBPI->BPI_VLRFIL 
		BPI->BPI_VIGDE  := TrbBPI->BPI_VIGDE
		BPI->BPI_VIGATE := TrbBPI->BPI_VIGATE
		BPI->BPI_CODINT := TrbBPI->BPI_CODINT 
		BPI->BPI_CODLOC := cCodLoc
		BPI->BPI_SEQREL := TrbBPI->BPI_SEQREL
		BPI->(MsUnlock()) 
	EndIf
	TrbBPI->(dbSkip()) 
EndDo

If Select("TrbBPI") > 0
	TrbBPI->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BZA - Folder-> Divisão Remuneração ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     

cSQL := "SELECT DISTINCT BZA_CODUNI, BZA_STATUS  " 
cSQL += "FROM "+RetSQLName("BZA")+" "+ "BZA " 
cSQL += "WHERE "
cSQL += "BZA_FILIAL = '"+xFilial("BZA")+"' AND "
cSQL += "BZA_CODIGO = '"+cRDA+"' AND "
cSQL += "BZA_CODINT = '"+cCodInt+"' AND "
cSQL += "BZA_CODLOC = '"+cLocOri+"' AND "
cSQL += "BZA.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBZA")

While TrbBZA->(!EOF())	
	IncProc("...")	
	BZA->(DbSetOrder(1))//BZA_FILIAL + BZA_CODIGO + BZA_CODINT + BZA_CODLOC + BZA_CODUNI                                                                                                                                                                                                                                                                                                                                                                                                                                                      
	If !BZA->( MsSeek(xFilial("BZA") + cRDA + cCodInt + cCodLoc + TrbBZA->BZA_CODUNI ) )
	
		BZA->(Reclock("BZA",.T.))
		BZA->BZA_FILIAL := xFilial("BZA")
		BZA->BZA_CODIGO := cRDA
		BZA->BZA_CODUNI := TrbBZA->BZA_CODUNI
		BZA->BZA_STATUS := TrbBZA->BZA_STATUS
		BZA->BZA_CODINT := cCodInt
		BZA->BZA_CODLOC := cCodLoc
		BZA->(MsUnlock())    
	EndIf
	TrbBZA->(dbSkip())
EndDo

If Select("TrbBZA") > 0
	TrbBZA->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BCK - Folder -> Diferenciacao da Ref/U.S. por Unidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

cSQL := "SELECT DISTINCT BCK_CODUNI, BCK_US, BCK_DESCON, BCK_VIGINI, BCK_VIGFIN " 
cSQL += "FROM "+RetSQLName("BCK")+" "+ "BCK " 
cSQL += "WHERE "
cSQL += "BCK_FILIAL = '"+xFilial("BCK")+"' AND "
cSQL += "BCK_CODIGO = '"+cRDA+"' AND "
cSQL += "BCK_CODINT = '"+cCodInt+"' AND "
cSQL += "BCK_CODLOC = '"+cLocOri+"' AND "
cSQL += "BCK.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBCK")

While TrbBCK->(!EOF())		
	IncProc("...")
	BCK->(DbSetOrder(1))//BCK_FILIAL + BCK_CODIGO + BCK_CODINT + BCK_CODLOC + BCK_CODUNI                                                                                                                                                                                                                                                                                                                                                    
	If !BCK->( MsSeek(xFilial("BCK") + cRDA + cCodInt + cCodLoc + TrbBCK->BCK_CODUNI ) )
	
		BCK->(Reclock("BCK",.T.))
		BCK->BCK_FILIAL := xFilial("BCK")
		BCK->BCK_CODIGO := cRDA
		BCK->BCK_CODUNI := TrbBCK->BCK_CODUNI
		BCK->BCK_US     := TrbBCK->BCK_US
		BCK->BCK_DESCON := TrbBCK->BCK_DESCON
		BCK->BCK_VIGINI := TrbBCK->BCK_VIGINI
		BCK->BCK_VIGFIN := TrbBCK->BCK_VIGFIN 
		BCK->BCK_CODINT := cCodInt
		BCK->BCK_CODLOC := cCodLoc
		BCK->(MsUnlock())  
	EndIf
	TrbBCK->(dbSkip())
EndDo 
     
If Select("TrbBCK") > 0
	TrbBCK->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BIN - Folder -> Grupo de Servicos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

cSQL := "SELECT DISTINCT BIN_CODGRU, BIN_DISSER " 
cSQL += "FROM "+RetSQLName("BIN")+" "+ "BIN " 
cSQL += "WHERE "
cSQL += "BIN_FILIAL = '"+xFilial("BIN")+"' AND "
cSQL += "BIN_CODIGO = '"+cRDA+"' AND "
cSQL += "BIN_CODINT = '"+cCodInt+"' AND "
cSQL += "BIN_CODLOC = '"+cLocOri+"' AND "
cSQL += "BIN.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBIN")

While TrbBIN->(!EOF())				
	IncProc("...")
	BIN->(DbSetOrder(1))//BIN_FILIAL + BIN_CODIGO + BIN_CODINT + BIN_CODLOC + BIN_CODGRU                                                                                                                                                                                                                                                                                                                                                    
	If !BIN->( MsSeek(xFilial("BIN") + cRDA + cCodInt + cCodLoc + TrbBIN->BIN_CODGRU ) )
	
		BIN->(Reclock("BIN",.T.))
		BIN->BIN_FILIAL := xFilial("BIN")
		BIN->BIN_CODIGO := cRDA
		BIN->BIN_CODGRU := TrbBIN->BIN_CODGRU
		BIN->BIN_CODINT := cCodInt
		BIN->BIN_CODLOC := cCodLoc
		BIN->BIN_DISSER := TrbBIN->BIN_DISSER
		BIN->(MsUnlock())   
	EndIf
	TrbBIN->(dbSkip())
EndDo
 
If Select("TrbBIN") > 0
	TrbBIN->(dbCloseArea())
Endif       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BSO - Folder -> Acesso Portal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

cSQL := "SELECT DISTINCT BSO_CODUSR "
cSQL += "FROM "+RetSQLName("BSO")+" "+ "BSO " 
cSQL += "WHERE "
cSQL += "BSO_FILIAL = '"+xFilial("BSO")+"' AND "
cSQL += "BSO_CODIGO = '"+cRDA+"' AND "
cSQL += "BSO_CODINT = '"+cCodInt+"' AND "
cSQL += "BSO_CODLOC = '"+cLocOri+"' AND "
cSQL += "BSO.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBSO")

While TrbBSO->(!EOF())			
	IncProc("...")
	BSO->(DbSetOrder(1))//BSO_FILIAL + BSO_CODUSR + BSO_CODIGO + BSO_CODLOC + BSO_CODINT                                                                                                                                                                                                                                                                                      
	If !BSO->( MsSeek(xFilial("BSO") + TrbBSO->BSO_CODUSR + cRDA + cCodLoc + cCodInt) )
		BSO->(Reclock("BSO",.T.))
		BSO->BSO_FILIAL := xFilial("BSO")
		BSO->BSO_CODUSR := TrbBSO->BSO_CODUSR
		BSO->BSO_CODIGO := cRDA
		BSO->BSO_CODLOC := cCodLoc
		BSO->BSO_CODINT := cCodInt
		BSO->(MsUnlock())    
	EndIf
	TrbBSO->(dbSkip())
EndDo  
 
If Select("TrbBSO") > 0
	TrbBSO->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³B24 - RDA x Local x Tabela de Precos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cSQL := "SELECT DISTINCT B24_TABPRE, B24_VIGINI, B24_VIGFIN "  
cSQL += "FROM "+RetSQLName("B24")+" "+ "B24 " 
cSQL += "WHERE "
cSQL += "B24_FILIAL = '"+xFilial("B24")+"' AND "
cSQL += "B24_CODIGO = '"+cRDA+"' AND "
cSQL += "B24_CODINT = '"+cCodInt+"' AND "
cSQL += "B24_CODLOC = '"+cLocOri+"' AND "
cSQL += "B24.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbB24")

While TrbB24->(!EOF())			
	IncProc("...")
	B24->(DbSetOrder(1))//B24_FILIAL + B24_CODIGO + B24_CODINT + B24_CODLOC + B24_TABPRE                                                                                                                                                                                                                                                                                                                                                                                                
	If !B24->( MsSeek(xFilial("B24") + cRDA + cCodInt + cCodLoc + TrbB24->B24_TABPRE ) )
		B24->(Reclock("B24",.T.))
		B24->B24_FILIAL := xFilial("B24")
		B24->B24_CODIGO := cRDA
		B24->B24_TABPRE := TrbB24->B24_TABPRE
		B24->B24_VIGINI := TrbB24->B24_VIGINI
		B24->B24_VIGFIN := TrbB24->B24_VIGFIN
		B24->B24_CODINT := cCodInt
		B24->B24_CODLOC := cCodLoc
		B24->(MsUnlock())    
	EndIf
	TrbB24->(dbSkip())
EndDo  
 
If Select("TrbB24") > 0
	TrbB24->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BAX - Folder -> Especialidades ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

cSQL := "SELECT DISTINCT BAX_FILIAL , BAX_CODIGO , BAX_CODINT , BAX_CODLOC , BAX_CODESP , BAX_CODSUB , BAX_DATINC, BAX_DATBLO, BAX_GUIMED, BAX_VALCH, BAX_VIGDE, BAX_FORMUL, BAX_EXPRES, BAX_CONESP, BAX_LIMATM, BAX_ORDPES, BAX_ESPPRI, BAX_BANDA, BAX_UCO " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX " 
cSQL += "WHERE "
cSQL += "BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBAX")

While TrbBAX->(!EOF())				
	IncProc("...")
	BAX->(DbSetOrder(1))//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
	If !BAX->( MsSeek(xFilial("BAX") + cRDA + cCodInt + cCodLoc + TrbBAX->(BAX_CODESP + BAX_CODSUB) ) )
	
		BAX->(Reclock("BAX",.T.))
		BAX->BAX_FILIAL := xFilial("BAX")
		BAX->BAX_CODIGO := cRDA
		BAX->BAX_CODESP := TrbBAX->BAX_CODESP
		BAX->BAX_CODSUB := TrbBAX->BAX_CODSUB
		BAX->BAX_CODINT := cCodInt
		BAX->BAX_CODLOC := cCodLoc
		BAX->BAX_DATINC := TrbBAX->BAX_DATINC
		BAX->BAX_DATBLO := TrbBAX->BAX_DATBLO
		BAX->BAX_GUIMED := TrbBAX->BAX_GUIMED
		BAX->BAX_VALCH  := TrbBAX->BAX_VALCH 
		BAX->BAX_VIGDE  := TrbBAX->BAX_VIGDE
		BAX->BAX_FORMUL := TrbBAX->BAX_FORMUL
		BAX->BAX_EXPRES := TrbBAX->BAX_EXPRES
		BAX->BAX_CONESP := TrbBAX->BAX_CONESP
		BAX->BAX_LIMATM := TrbBAX->BAX_LIMATM
		BAX->BAX_ORDPES := TrbBAX->BAX_ORDPES 
		BAX->BAX_ESPPRI := TrbBAX->BAX_ESPPRI
		BAX->BAX_BANDA  := TrbBAX->BAX_BANDA
		BAX->BAX_UCO    := TrbBAX->BAX_UCO
		BAX->(MsUnlock()) 
	EndIf
	TrbBAX->(dbSkip())
EndDo

If Select("TrbBAX") > 0
	TrbBAX->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BC0 - Folder -> Procedimentos Autorizados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BC0_CODESP, BC0_CODSUB, BC0_CODTAB, BC0_CODPAD, BC0_CODOPC, BC0_NIVEL, BC0_VALCH, BC0_VALREA, BC0_FORMUL, BC0_EXPRES, BC0_PERACR, BC0_TIPO, BC0_CDNV01, BC0_CDNV02, BC0_CDNV03, BC0_CDNV04, BC0_VIGDE, BC0_VIGATE, BC0_BANDA, BC0_UCO  "  
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BC0")+" "+ "BC0 "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BC0.BC0_FILIAL = '"+xFilial("BC0")+"' AND "
cSQL += "BC0.BC0_CODIGO = '"+cRDA+"' AND "
cSQL += "BC0.BC0_CODINT = '"+cCodInt+"' AND "
cSQL += "BC0.BC0_CODLOC = '"+cLocOri+"' AND "
cSQL += "BC0.BC0_CODESP = '"+BAX->BAX_CODESP+"' AND "  
cSQL += "BC0.BC0_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BC0.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBC0")

While TrbBC0->(!EOF())		
	IncProc("...")	
	BC0->(DbSetOrder(1))//BC0_FILIAL + BC0_CODIGO + BC0_CODINT + BC0_CODLOC + BC0_CODESP + BC0_CODTAB + BC0_CODOPC                                                                                                                                                                                                                                                                                                                                                    
	If !BC0->( MsSeek(xFilial("BC0") + cRDA + cCodInt + cCodLoc + TrbBC0->(BC0_CODESP + BC0_CODTAB + BC0_CODOPC) ) )
	
		BC0->(Reclock("BC0",.T.))
		BC0->BC0_FILIAL := xFilial("BC0")
		BC0->BC0_CODIGO := cRDA    
		BC0->BC0_CODINT := cCodInt		
		BC0->BC0_CODLOC := cCodLoc
		BC0->BC0_CODESP := TrbBC0->BC0_CODESP
		BC0->BC0_CODSUB := TrbBC0->BC0_CODSUB
		BC0->BC0_CODTAB := TrbBC0->BC0_CODTAB
		BC0->BC0_CODPAD := TrbBC0->BC0_CODPAD
		BC0->BC0_CODOPC := TrbBC0->BC0_CODOPC
		BC0->BC0_NIVEL  := TrbBC0->BC0_NIVEL
		BC0->BC0_VALCH  := TrbBC0->BC0_VALCH 
		BC0->BC0_VALREA := TrbBC0->BC0_VALREA
		BC0->BC0_FORMUL := TrbBC0->BC0_FORMUL 
		BC0->BC0_EXPRES := TrbBC0->BC0_EXPRES   
		BC0->BC0_PERACR := TrbBC0->BC0_PERACR
		BC0->BC0_TIPO   := TrbBC0->BC0_TIPO
		BC0->BC0_CDNV01 := TrbBC0->BC0_CDNV01
		BC0->BC0_CDNV02 := TrbBC0->BC0_CDNV02
		BC0->BC0_CDNV03 := TrbBC0->BC0_CDNV03
		BC0->BC0_CDNV04 := TrbBC0->BC0_CDNV04
		BC0->BC0_VIGDE  := TrbBC0->BC0_VIGDE
		BC0->BC0_VIGATE := TrbBC0->BC0_VIGATE
		BC0->BC0_BANDA  := TrbBC0->BC0_BANDA
		BC0->BC0_UCO    := TrbBC0->BC0_UCO 
		BC0->(MsUnlock())
	EndIf
	TrbBC0->(dbSkip())
EndDo

If Select("TrbBC0") > 0
	TrbBC0->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BZB - Botao -> Divisao Remunerecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BZB_CODESP, BZB_CODSUB, BZB_CODTAB, BZB_CODOPC, BZB_NIVEL, BZB_CODUNI, BZB_STATUS, BZB_CDNV01, BZB_CDNV02, BZB_CDNV03, BZB_CDNV04  " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BZB")+" "+ "BZB "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BZB.BZB_FILIAL = '"+xFilial("BZB")+"' AND "
cSQL += "BZB.BZB_CODIGO = '"+cRDA+"' AND "
cSQL += "BZB.BZB_CODINT = '"+cCodInt+"' AND "
cSQL += "BZB.BZB_CODLOC = '"+cLocOri+"' AND "
cSQL += "BZB.BZB_CODESP = '"+BAX->BAX_CODESP+"' AND "  
cSQL += "BZB.BZB_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BZB.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBZB")

While TrbBZB->(!EOF())		
	IncProc("...")
	BZB->(DbSetOrder(1))//BZB_FILIAL + BZB_CODIGO + BZB_CODINT + BZB_CODLOC + BZB_CODESP + BZB_CODTAB + BZB_CODOPC + BZB_NIVEL + BZB_CODUNI                                                                                                                                                                                                                                                                                                                                                    
	If !BZB->( MsSeek(xFilial("BZB") + cRDA + cCodInt + cCodLoc + TrbBZB->(BZB_CODESP + BZB_CODTAB + BZB_CODOPC + BZB_NIVEL + BZB_CODUNI) ) )
	
		BZB->(Reclock("BZB",.T.))
		BZB->BZB_FILIAL := xFilial("BZB")
		BZB->BZB_CODIGO := cRDA
		BZB->BZB_CODINT := cCodInt		
		BZB->BZB_CODLOC := cCodLoc
		BZB->BZB_CODESP := TrbBZB->BZB_CODESP
		BZB->BZB_CODSUB := TrbBZB->BZB_CODSUB 
		BZB->BZB_CODTAB := TrbBZB->BZB_CODTAB
		BZB->BZB_CODOPC := TrbBZB->BZB_CODOPC
		BZB->BZB_NIVEL  := TrbBZB->BZB_NIVEL
		BZB->BZB_CODUNI := TrbBZB->BZB_CODUNI
		BZB->BZB_STATUS := TrbBZB->BZB_STATUS
		BZB->BZB_CDNV01 := TrbBZB->BZB_CDNV01
		BZB->BZB_CDNV02 := TrbBZB->BZB_CDNV02
		BZB->BZB_CDNV03 := TrbBZB->BZB_CDNV03
		BZB->BZB_CDNV04 := TrbBZB->BZB_CDNV04
		BZB->(MsUnlock())
	EndIf
	TrbBZB->(dbSkip())
EndDo

If Select("TrbBZB") > 0
	TrbBZB->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BDN - Botao -> Diferenciar Composicao do Procedimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BDN_CODESP, BDN_CODSUB, BDN_CODTAB, BDN_CODPAD, BDN_CODOPC, BDN_CODUNI, BDN_REF   " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BDN")+" "+ "BDN "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BDN.BDN_FILIAL = '"+xFilial("BDN")+"' AND "
cSQL += "BDN.BDN_CODIGO = '"+cRDA+"' AND "
cSQL += "BDN.BDN_CODINT = '"+cCodInt+"' AND "
cSQL += "BDN.BDN_CODLOC = '"+cLocOri+"' AND "
cSQL += "BDN.BDN_CODESP = '"+BAX->BAX_CODESP+"' AND "      
cSQL += "BDN.BDN_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BDN.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBDN")

While TrbBDN->(!EOF())		
	IncProc("...")
	BDN->(DbSetOrder(1))//BDN_FILIAL + BDN_CODIGO + BDN_CODINT + BDN_CODLOC + BDN_CODESP + BDN_CODTAB + BDN_CODPAD + BDN_CODOPC + BDN_CODUNI                                                                                                                                                                                                                                                                                                                                                    
	If !BDN->( MsSeek(xFilial("BDN") + cRDA + cCodInt + cCodLoc + TrbBDN->(BDN_CODESP + BDN_CODTAB + BDN_CODPAD + BDN_CODOPC + BDN_CODUNI) ) )
	
		BDN->(Reclock("BDN",.T.))
		BDN->BDN_FILIAL := xFilial("BDN")
		BDN->BDN_CODIGO := cRDA
		BDN->BDN_CODINT := cCodInt		
		BDN->BDN_CODLOC := cCodLoc
		BDN->BDN_CODESP := TrbBDN->BDN_CODESP
		BDN->BDN_CODSUB := TrbBDN->BDN_CODSUB
		BDN->BDN_CODTAB := TrbBDN->BDN_CODTAB
		BDN->BDN_CODPAD := TrbBDN->BDN_CODPAD
		BDN->BDN_CODOPC := TrbBDN->BDN_CODOPC
		BDN->BDN_CODUNI := TrbBDN->BDN_CODUNI
		BDN->BDN_REF    := TrbBDN->BDN_REF
		BDN->(MsUnlock())
	EndIf
	TrbBDN->(dbSkip())
EndDo

If Select("TrbBDN") > 0
	TrbBDN->(dbCloseArea())
Endif
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BC1 - Folder -> Corpo Clinico / Medicos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BC1_CODRDA, BC1_ESTCR, BC1_NUMCR, BC1_SIGLCR, BC1_CODPRF, BC1_NOMPRF, BC1_PERSOC, BC1_PERDES, BC1_PERACR, BC1_CODESP, BC1_CODSUB, BC1_TIPLAN " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BC1")+" "+ "BC1 "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BC1.BC1_FILIAL = '"+xFilial("BC1")+"' AND "
cSQL += "BC1.BC1_CODIGO = '"+cRDA+"' AND "
cSQL += "BC1.BC1_CODINT = '"+cCodInt+"' AND "
cSQL += "BC1.BC1_CODLOC = '"+cLocOri+"' AND "
cSQL += "BC1.BC1_CODESP = '"+BAX->BAX_CODESP+"' AND "  
cSQL += "BC1.BC1_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BC1.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBC1")

While TrbBC1->(!EOF())		
	IncProc("...")	
	BC1->(DbSetOrder(1))//BC1_FILIAL + BC1_CODIGO + BC1_CODLOC + BC1_CODESP + BC1_CODPRF                                                                                                                                                                                                                                                                                                                                                    
	If !BC1->( MsSeek(xFilial("BC1") + cRDA + cCodLoc + TrbBC1->(BC1_CODESP + BC1_CODPRF) ) )
	
		BC1->(Reclock("BC1",.T.))
		BC1->BC1_FILIAL := xFilial("BC1")
		BC1->BC1_CODIGO := cRDA
		BC1->BC1_CODRDA := TrbBC1->BC1_CODRDA
		BC1->BC1_ESTCR  := TrbBC1->BC1_ESTCR
		BC1->BC1_NUMCR  := TrbBC1->BC1_NUMCR
		BC1->BC1_SIGLCR := TrbBC1->BC1_SIGLCR
		BC1->BC1_CODPRF := TrbBC1->BC1_CODPRF
		BC1->BC1_NOMPRF := TrbBC1->BC1_NOMPRF 
		BC1->BC1_PERSOC := TrbBC1->BC1_PERSOC
		BC1->BC1_PERDES := TrbBC1->BC1_PERDES
		BC1->BC1_PERACR := TrbBC1->BC1_PERACR 
		BC1->BC1_CODINT := cCodInt		
		BC1->BC1_CODLOC := cCodLoc
		BC1->BC1_CODESP := TrbBC1->BC1_CODESP
		BC1->BC1_CODSUB := TrbBC1->BC1_CODSUB 
		BC1->BC1_TIPLAN := TrbBC1->BC1_TIPLAN
		BC1->(MsUnlock())
	EndIf
	TrbBC1->(dbSkip())
EndDo

If Select("TrbBC1") > 0
	TrbBC1->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BE6 - Folder -> Corpo Clinico / Procedimentos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BE6_CODTAB, BE6_CODPAD, BE6_CODPRO, BE6_CODPRF, BE6_CODESP, BE6_CODSUB, BE6_PGTDIV "  
cSQL += "FROM "+RetSQLName("BC1")+" "+ "BC1, " +RetSQLName("BE6")+" "+ "BE6 "    
cSQL += "WHERE "
cSQL += "BC1.BC1_FILIAL = '"+xFilial("BC1")+"' AND "
cSQL += "BC1.BC1_CODIGO = '"+cRDA+"' AND "
cSQL += "BC1.BC1_CODINT = '"+cCodInt+"' AND "
cSQL += "BC1.BC1_CODLOC = '"+cLocOri+"' AND "
cSQL += "BC1.D_E_L_E_T_ = ' ' AND "
cSQL += "BE6.BE6_FILIAL = '"+xFilial("BE6")+"' AND "
cSQL += "BE6.BE6_CODIGO = '"+cRDA+"' AND "
cSQL += "BE6.BE6_CODINT = '"+cCodInt+"' AND "
cSQL += "BE6.BE6_CODLOC = '"+cLocOri+"' AND "
cSQL += "BE6.BE6_CODESP = BC1_CODESP  AND " 
cSQL += "BE6.BE6_CODSUB = BC1_CODSUB  AND "
cSQL += "BE6.BE6_CODPRF = BC1_CODPRF  AND "
cSQL += "BE6.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBE6")

While TrbBE6->(!EOF())		
	IncProc("...")
	BE6->(DbSetOrder(2))//BE6_FILIAL + BE6_CODIGO + BE6_CODINT + BE6_CODLOC + BE6_CODESP                                                                                                                                                                                                                                                                                                                                                    
	If !BE6->( MsSeek(xFilial("BE6") + cRDA + cCodInt + cCodLoc + TrbBE6->BE6_CODESP ) )
	
		BE6->(Reclock("BE6",.T.))
		BE6->BE6_FILIAL := xFilial("BE6")
		BE6->BE6_CODIGO := cRDA
		BE6->BE6_CODTAB := TrbBE6->BE6_CODTAB
		BE6->BE6_CODPAD := TrbBE6->BE6_CODPAD 
		BE6->BE6_CODPRO := TrbBE6->BE6_CODPRO
		BE6->BE6_CODPRF := TrbBE6->BE6_CODPRF
		BE6->BE6_CODLOC := cCodLoc
		BE6->BE6_CODINT := cCodInt		
		BE6->BE6_CODESP := TrbBE6->BE6_CODESP
		BE6->BE6_CODSUB := TrbBE6->BE6_CODSUB
		BE6->BE6_PGTDIV := TrbBE6->BE6_PGTDIV
		BE6->(MsUnlock())
	EndIf
	TrbBE6->(dbSkip())
EndDo

If Select("TrbBE6") > 0
	TrbBE6->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BGG - Folder -> Contatos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BBG_SEQUEN, BBG_NOME, BBG_CODORG, BBG_CODESP, BBG_CODSUB  " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BBG")+" "+ "BBG "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BBG.BBG_FILIAL = '"+xFilial("BBG")+"' AND "
cSQL += "BBG.BBG_CODIGO = '"+cRDA+"' AND "
cSQL += "BBG.BBG_CODINT = '"+cCodInt+"' AND "
cSQL += "BBG.BBG_CODLOC = '"+cLocOri+"' AND "
cSQL += "BBG.BBG_CODESP = '"+BAX->BAX_CODESP+"' AND "    
cSQL += "BBG.BBG_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BBG.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBBG")

While TrbBBG->(!EOF())				
	IncProc("...")
	BBG->(DbSetOrder(1))//BBG_FILIAL + BBG_CODIGO + BBG_CODINT + BBG_CODLOC + BBG_CODESP + BBG_SEQUEN                                                                                                                                                                                                                                                                                                                                                    
	If !BBG->( MsSeek(xFilial("BBG") + cRDA + cCodInt + cCodLoc + TrbBBG->(BBG_CODESP + BBG_SEQUEN) ) )
	
		BBG->(Reclock("BBG",.T.))
		BBG->BBG_FILIAL := xFilial("BBG")
		BBG->BBG_CODIGO := cRDA
		BBG->BBG_SEQUEN := TrbBBG->BBG_SEQUEN
		BBG->BBG_NOME   := TrbBBG->BBG_NOME
		BBG->BBG_CODORG := TrbBBG->BBG_CODORG 
		BBG->BBG_CODINT := cCodInt		
		BBG->BBG_CODLOC := cCodLoc
		BBG->BBG_CODESP := TrbBBG->BBG_CODESP
		BBG->BBG_CODSUB := TrbBBG->BBG_CODSUB
		BBG->(MsUnlock())
	EndIf
	TrbBBG->(dbSkip())
EndDo
 
If Select("TrbBBG") > 0
	TrbBBG->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BBI - Folder -> Planos / Planos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BBI_CODPRO, BBI_DESPRO, BBI_ATIVO, BBI_VALCH, BBI_USRECT, BBI_BLOPAG, BBI_CODTAB, BBI_CODESP, BBI_CODSUB, BBI_VERSAO, BBI_VIGDE, BBI_VIGATE, BBI_CODGRU, BBI_GUIMED, BBI_BANDA, BBI_UCO  " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BBI")+" "+ "BBI "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BBI.BBI_FILIAL = '"+xFilial("BBI")+"' AND "
cSQL += "BBI.BBI_CODIGO = '"+cRDA+"' AND "
cSQL += "BBI.BBI_CODINT = '"+cCodInt+"' AND "
cSQL += "BBI.BBI_CODLOC = '"+cLocOri+"' AND "
cSQL += "BBI.BBI_CODESP = '"+BAX->BAX_CODESP+"' AND "  
cSQL += "BBI.BBI_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BBI.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBBI")

While TrbBBI->(!EOF())						
	IncProc("...")
	BBI->(DbSetOrder(1))//BBI_FILIAL + BBI_CODIGO + BBI_CODINT + BBI_CODLOC + BBI_CODESP + BBI_CODPRO + BBI_VERSAO                                                                                                                                                                                                                                                                                                                                                    
	If !BBI->( MsSeek(xFilial("BBI") + cRDA + cCodInt + cCodLoc + TrbBBI->(BBI_CODESP + BBI_CODPRO + BBI_VERSAO) ) )
	
		BBI->(Reclock("BBI",.T.))
		BBI->BBI_FILIAL := xFilial("BBI")
		BBI->BBI_CODIGO := cRDA
		BBI->BBI_CODPRO := TrbBBI->BBI_CODPRO
		BBI->BBI_DESPRO := TrbBBI->BBI_DESPRO 
		BBI->BBI_ATIVO  := TrbBBI->BBI_ATIVO 
		BBI->BBI_VALCH  := TrbBBI->BBI_VALCH
		BBI->BBI_USRECT := TrbBBI->BBI_USRECT
		BBI->BBI_BLOPAG := TrbBBI->BBI_BLOPAG
		BBI->BBI_CODTAB := TrbBBI->BBI_CODTAB
		BBI->BBI_CODINT := cCodInt		
		BBI->BBI_CODLOC := cCodLoc
		BBI->BBI_CODESP := TrbBBI->BBI_CODESP
		BBI->BBI_CODSUB := TrbBBI->BBI_CODSUB
		BBI->BBI_VERSAO := TrbBBI->BBI_VERSAO
		BBI->BBI_VIGDE  := TrbBBI->BBI_VIGDE
		BBI->BBI_VIGATE := TrbBBI->BBI_VIGATE
		BBI->BBI_CODGRU := TrbBBI->BBI_CODGRU
		BBI->BBI_GUIMED := TrbBBI->BBI_GUIMED
		BBI->BBI_BANDA  := TrbBBI->BBI_BANDA
		BBI->BBI_UCO    := TrbBBI->BBI_UCO
		BBI->(MsUnlock())
	EndIf
	TrbBBI->(dbSkip())
EndDo

If Select("TrbBBI") > 0
	TrbBBI->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BE9 - Folder -> Planos / Procedimentos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BE9_CODTAB ,BE9_CODPAD ,BE9_CODPRO ,BE9_NIVEL ,BE9_VALCH ,BE9_BLOPAG ,BE9_VALREA ,BE9_USRECT ,BE9_ATIVO ,BE9_VLRECT ,BE9_CODGRU ,BE9_CODPLA ,BE9_PERDES ,BE9_CODESP ,BE9_CODSUB ,BE9_CDNV01 ,BE9_CDNV02 ,BE9_CDNV03 ,BE9_CDNV04 ,BE9_BANDA ,BE9_ATEND ,BE9_URG ,BE9_ELET ,BE9_INDIC ,BE9_INDAMB ,BE9_NET ,BE9_CALL ,BE9_PF ,BE9_PJ ,BE9_VIGDE ,BE9_VIGATE ,BE9_ATEINT ,BE9_ATEEXT ,BE9_PERACR ,BE9_UCO " 
cSQL += "FROM "+RetSQLName("BBI")+" "+ "BBI, " +RetSQLName("BE9")+" "+ "BE9 "    
cSQL += "WHERE "
cSQL += "BBI.BBI_FILIAL = '"+xFilial("BBI")+"' AND "
cSQL += "BBI.BBI_CODIGO = '"+cRDA+"' AND "
cSQL += "BBI.BBI_CODINT = '"+cCodInt+"' AND "
cSQL += "BBI.BBI_CODLOC = '"+cLocOri+"' AND "
cSQL += "BBI.D_E_L_E_T_ = ' ' AND "
cSQL += "BE9.BE9_FILIAL = '"+xFilial("BE9")+"' AND "
cSQL += "BE9.BE9_CODIGO = '"+cRDA+"' AND "
cSQL += "BE9.BE9_CODINT = '"+cCodInt+"' AND "
cSQL += "BE9.BE9_CODLOC = '"+cLocOri+"' AND "
cSQL += "BE9.BE9_CODESP = BBI_CODESP AND "  
cSQL += "BE9.BE9_CODSUB = BBI_CODSUB AND "
cSQL += "BE9.BE9_CODPLA = BBI_CODPRO AND "
cSQL += "BE9.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBE9")

While TrbBE9->(!EOF())				
	IncProc("...")
	BE9->(DbSetOrder(1))//BE9_FILIAL + BE9_CODIGO + BE9_CODINT + BE9_CODLOC + BE9_CODESP + BE9_CODPLA + BE9_CODPAD + BE9_CODPRO                                                                                                                                                                                                                                                                                                                                                    
	If !BE9->( MsSeek(xFilial("BE9") + cRDA + cCodInt + cCodLoc + TrbBE9->(BE9_CODESP + BE9_CODPLA + BE9_CODPAD + BE9_CODPRO) ) )
	
		BE9->(Reclock("BE9",.T.))
		BE9->BE9_FILIAL := xFilial("BE9")
		BE9->BE9_CODIGO := cRDA
		BE9->BE9_CODTAB := TrbBE9->BE9_CODTAB
		BE9->BE9_CODPAD := TrbBE9->BE9_CODPAD
		BE9->BE9_CODPRO := TrbBE9->BE9_CODPRO 
		BE9->BE9_NIVEL  := TrbBE9->BE9_NIVEL
		BE9->BE9_VALCH  := TrbBE9->BE9_VALCH 
		BE9->BE9_BLOPAG := TrbBE9->BE9_BLOPAG 
		BE9->BE9_VALREA := TrbBE9->BE9_VALREA
		BE9->BE9_USRECT := TrbBE9->BE9_USRECT
		BE9->BE9_ATIVO  := TrbBE9->BE9_ATIVO
		BE9->BE9_VLRECT := TrbBE9->BE9_VLRECT
		BE9->BE9_CODGRU := TrbBE9->BE9_CODGRU 
		BE9->BE9_CODPLA := TrbBE9->BE9_CODPLA
		BE9->BE9_PERDES := TrbBE9->BE9_PERDES
		BE9->BE9_CODLOC := cCodLoc		
		BE9->BE9_CODINT := cCodInt		
		BE9->BE9_CODESP := TrbBE9->BE9_CODESP
		BE9->BE9_CODSUB := TrbBE9->BE9_CODSUB
		BE9->BE9_CDNV01 := TrbBE9->BE9_CDNV01
		BE9->BE9_CDNV02 := TrbBE9->BE9_CDNV02
		BE9->BE9_CDNV03 := TrbBE9->BE9_CDNV03
		BE9->BE9_CDNV04 := TrbBE9->BE9_CDNV04
		BE9->BE9_BANDA  := TrbBE9->BE9_BANDA
		BE9->BE9_ATEND  := TrbBE9->BE9_ATEND
		BE9->BE9_URG    := TrbBE9->BE9_URG
		BE9->BE9_ELET   := TrbBE9->BE9_ELET
		BE9->BE9_INDIC  := TrbBE9->BE9_INDIC
		BE9->BE9_INDAMB := TrbBE9->BE9_INDAMB
		BE9->BE9_NET    := TrbBE9->BE9_NET
		BE9->BE9_CALL   := TrbBE9->BE9_CALL
		BE9->BE9_PF     := TrbBE9->BE9_PF
		BE9->BE9_PJ     := TrbBE9->BE9_PJ
		BE9->BE9_VIGDE  := TrbBE9->BE9_VIGDE
		BE9->BE9_VIGATE := TrbBE9->BE9_VIGATE
		BE9->BE9_ATEINT := TrbBE9->BE9_ATEINT
		BE9->BE9_ATEEXT := TrbBE9->BE9_ATEEXT
		BE9->BE9_PERACR := TrbBE9->BE9_PERACR
		BE9->BE9_UCO    := TrbBE9->BE9_UCO
		BE9->(MsUnlock())
	EndIf
	TrbBE9->(dbSkip())
EndDo

If Select("TrbBE9") > 0
	TrbBE9->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BBK - Folder -> Rede de Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BBK_CODRED, BBK_CODESP, BBK_CODSUB " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BBK")+" "+ "BBK "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BBK.BBK_FILIAL = '"+xFilial("BBK")+"' AND "
cSQL += "BBK.BBK_CODIGO = '"+cRDA+"' AND "
cSQL += "BBK.BBK_CODINT = '"+cCodInt+"' AND "
cSQL += "BBK.BBK_CODLOC = '"+cLocOri+"' AND "
cSQL += "BBK.BBK_CODESP = '"+BAX->BAX_CODESP+"' AND "   
cSQL += "BBK.BBK_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BBK.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBBK")

While TrbBBK->(!EOF())				
	IncProc("...")
	BBK->(DbSetOrder(1))//BBK_FILIAL + BBK_CODIGO + BBK_CODINT + BBK_CODLOC + BBK_CODESP + BBK_CODRED                                                                                                                                                                                                                                                                                                                                                    
	If !BBK->( MsSeek(xFilial("BBK") + cRDA + cCodInt + cCodLoc + TrbBBK->(BBK_CODESP + BBK_CODRED) ) )
	
		BBK->(Reclock("BBK",.T.))
		BBK->BBK_FILIAL := xFilial("BBK")
		BBK->BBK_CODIGO := cRDA
		BBK->BBK_CODRED := TrbBBK->BBK_CODRED
		BBK->BBK_CODINT := cCodInt		
		BBK->BBK_CODLOC := cCodLoc
		BBK->BBK_CODESP := TrbBBK->BBK_CODESP
		BBK->BBK_CODSUB := TrbBBK->BBK_CODSUB
		BBK->(MsUnlock()) 
	EndIf
	TrbBBK->(dbSkip())
EndDo

If Select("TrbBBK") > 0
	TrbBBK->(dbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BBN - Folder -> Procedimentos nao Autorizados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT DISTINCT BBN_CODPSA, BBN_CODPAD, BBN_NIVEL, BBN_CODESP, BBN_CDNV01, BBN_CDNV02, BBN_CDNV03, BBN_CDNV04, BBN_CODSUB " 
cSQL += "FROM "+RetSQLName("BAX")+" "+ "BAX, " +RetSQLName("BBN")+" "+ "BBN "    
cSQL += "WHERE "
cSQL += "BAX.BAX_FILIAL = '"+xFilial("BAX")+"' AND "
cSQL += "BAX.BAX_CODIGO = '"+cRDA+"' AND "
cSQL += "BAX.BAX_CODINT = '"+cCodInt+"' AND "
cSQL += "BAX.BAX_CODLOC = '"+cLocOri+"' AND "
cSQL += "BAX.D_E_L_E_T_ = ' ' AND "
cSQL += "BBN.BBN_FILIAL = '"+xFilial("BBN")+"' AND "
cSQL += "BBN.BBN_CODIGO = '"+cRDA+"' AND "
cSQL += "BBN.BBN_CODINT = '"+cCodInt+"' AND "
cSQL += "BBN.BBN_CODLOC = '"+cLocOri+"' AND "
cSQL += "BBN.BBN_CODESP = '"+BAX->BAX_CODESP+"' AND "
cSQL += "BBN.BBN_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
cSQL += "BBN.D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbBBN")

While TrbBBN->(!EOF())						
	IncProc("...")
	BBN->(DbSetOrder(1))//BBN_FILIAL + BBN_CODIGO + BBN_CODINT + BBN_CODLOC + BBN_CODESP + BBN_CODPAD + BBN_CODPSA + BBN_NIVEL                                                                                                                                                                                                                                                                                                                                                    
	If !BBN->( MsSeek(xFilial("BBN") + cRDA + cCodInt + cCodLoc + TrbBBN->(BBN_CODESP + BBN_CODPAD + BBN_CODPSA + BBN_NIVEL) ) )
	
		BBN->(Reclock("BBN",.T.))
		BBN->BBN_FILIAL := xFilial("BBN")
		BBN->BBN_CODIGO := cRDA
		BBN->BBN_CODPSA := TrbBBN->BBN_CODPSA
		BBN->BBN_CODPAD := TrbBBN->BBN_CODPAD
		BBN->BBN_NIVEL  := TrbBBN->BBN_NIVEL
		BBN->BBN_CODINT := cCodInt		
		BBN->BBN_CODLOC := cCodLoc
		BBN->BBN_CODESP := TrbBBN->BBN_CODESP
		BBN->BBN_CDNV01 := TrbBBN->BBN_CDNV01
		BBN->BBN_CDNV02 := TrbBBN->BBN_CDNV02
		BBN->BBN_CDNV03 := TrbBBN->BBN_CDNV03
		BBN->BBN_CDNV04 := TrbBBN->BBN_CDNV04
		BBN->BBN_CODSUB := TrbBBN->BBN_CODSUB
		BBN->(MsUnlock())
	EndIf
	TrbBBN->(dbSkip())
EndDo

If Select("TrbBBN") > 0
	TrbBBN->(dbCloseArea())
Endif

End Transaction

Return
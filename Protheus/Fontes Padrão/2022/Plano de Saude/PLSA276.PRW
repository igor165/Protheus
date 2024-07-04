#INCLUDE "PLSA276.ch"
#include "protheus.ch"
#include "PLSMGER.CH"

#define K_Copiar 8

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA276 ³ Autor ³ Eduardo Motta        ³ Data ³ 08.01.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Grupo de Operadoras                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA276(aRotAuto,nOpcAuto,lPlsServer,nReg)
PRIVATE lPlsAuto   := (ValType(aRotAuto)=="A")
PRIVATE bDelLine   := { || PLSCHKDEL( { { "BA0","BA0_GRUOPE",BA2->BA2_GRUOPE } } ) }
PRIVATE aRotina    := MenuDef(.F.)
                         
PRIVATE cAlias     := "BA2"
PRIVATE cCadastro  := Fundesc()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define parametros default...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nOpcAuto   := K_Incluir               
DEFAULT lPlsServer := PLSServer()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a chamada de acordo com tipo...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lPlsAuto
    If nOpcAuto == K_Alterar .Or. nOpcAuto == K_Excluir
       BA2->(DbGoTo(nReg))
    Endif   
    MsRotAuto(nOpcAuto,aRotAuto,cAlias)
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Chama funcao de Browse...                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA2->(DbSetOrder(1))
   BA2->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil))
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ 		   ³ Autor ³ TOTVS    			³ Data ³ 00/00/0000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Verifica se GRUPO OPERADORA (BA2) TEM VIGENCIA (BGH)        ³±±
±±³           ³ e TABELAS RELACIONADAS (BGH,BGI,BMG,BMT,BSM,BSX)            ³±±
±±³           ³ e nao deixa excluir                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ³
//³						    	³
//³Alexander  11/04/2005                                        		 		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function Plsa276Exc(cAlias,nReg,nOpc,nMenu)   
            
  do case
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Tratamento para Grupo Operadora com Vigencia						  ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 case cAlias = "BA2"
		BGH->(DbSetOrder(1)) //BGH_FILIAL + BGH_GRUOPE + BGH_CODSEQ
		if BGH->( MsSeek( BA2->( BA2_FILIAL+BA2_GRUOPE ) ) )
		   MsgInfo('Existe VIGENCIA para este GRUPO OPERADORA!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Tratamento para Vigencia com Acomodacao e Tab.Precos				 ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 case cAlias = "BGH"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BGI Vigencias/Tab.Precos		   	   												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BGI->(DbSetOrder(1)) //BGI_FILIAL + BGI_GRUOPE + BGI_CODSEQ + BGI_CODPAD + BGI_CODPRO + BGI_NIVEL
		if BGI->(MsSeek(xFilial("BGH")+BGH->(BGH_GRUOPE+BGH_CODSEQ)))
		   MsgInfo('Existe TAB. PREÇO para esta VIGENCIA!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif                                              
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Tratamento para Tab.Preco com SubItens X Procedimentos X Espec X Produto	   ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 case cAlias = "BGI"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BMQ Grp.Ope X Procedimentos X SubItens												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BMQ->(DbSetOrder(1)) //BMQ_FILIAL + BMQ_GRUOPE + BMQ_CODSEQ + BMQ_CODPAD + BMQ_CODPRO + BMQ_CODUNM + BMQ_NIVEL
		if BMQ->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   MsgInfo('Existe SUB-ITEN para esta TAB. PREÇO!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif 	          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BMT Grp.Ope X Procedimentos X Espec. 											   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BMT->(DbSetOrder(1)) //BMT_FILIAL + BMT_GRUOPE + BMT_CODSEQ + BMT_CODPAD + BMT_CODPRO + BMT_CODESP + BMT_NIVEL
		if BMT->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   MsgInfo('Existe PROCEDIMENTOS para esta TAB. PREÇO!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif 	          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BSM Grp.Ope X Procedimentos X Produto											   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BSM->(DbSetOrder(1)) //BSM_FILIAL + BSM_GRUOPE + BSM_CODSEQ + BSM_CODPAD + BSM_CODPRO + BSM_CODPLA + BSM_NIVEL
		if BSM->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   MsgInfo('Existe PRODUTO para esta TAB. PREÇO!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif                     
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Tratamento para Vigencia com Prod.X Unidade								   ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 case cAlias = "BSM"
 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³BSX Grp.Operadora X Prod.X Unidade  												   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BSX->(DbSetOrder(1)) //BSX_FILIAL + BSX_GRUOPE + BSX_CODSEQ + BSX_CODPAD + BSX_CODPRO + BSX_CODPLA + BSX_CODUNM + BSX_NIVEL
		if BSX->( MsSeek( xFilial("BSM")+BSM->(BSM_GRUOPE+BSM_CODSEQ+BSM_CODPAD+BSM_CODPRO+BSM_CODPLA) ) )
		   MsgInfo('Existe UNIDADE para este PRODUTO!'+CHR(13)+'Impossivel fazer a EXCLUSÃO!')
		   return
		endif 	          
	endcase
    AxDeleta(cAlias,nReg,nOpc,,,,)
Return 


Function Plsa276Vg()
Local cFil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina    := { { STRPL01   	, 'AxPesqui'   , 0 ,K_Pesquisar },;
                         { STRPL02  	, 'AxVisual'   , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'PlSA276Inc' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'Plsa276Alt' , 0 ,K_Alterar   },;
                         { STRPL05	 	, 'Plsa276Exc'   , 0 ,K_Excluir },; //Alexander AxDeleta
	                     { STR0001		, 'PlSA276Sel' , 0 ,K_Alterar   },; //"Selecionar"
						 { STR0002     	, 'PLSA276CLO' , 0 ,K_Copiar    }} //Alexander 08/04/2005                      //"Copiar"

                         
PRIVATE cAlias     := "BGH"
PRIVATE cCadastro
PRIVATE cCodInt := PLSINTPAD()
aadd(aRotina,{ OemtoAnsi(STR0015)	,'PL276DifID()',0,K_Alterar})		//"Period. Dif. Idade"

cCadastro  := PLSRetTit(cAlias)

cFil := "BGH_FILIAL = '"+xFilial("BGH")+"' AND BGH_GRUOPE = '"+BA2->BA2_GRUOPE+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BGH->(DbSetOrder(1))
BHG->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,nil,,cFil))
DbSelectArea(cAlias)

Return .T.

Function Plsa276Inc(cAlias,nReg,nOpc)

Return AxInclui(cAlias,nReg,nOpc,,,,"Plsa276OK()")

Function Plsa276Alt(cAlias,nReg,nOpc)

Return AxAltera(cAlias,nReg,nOpc,,,,,"Plsa276OK(.T.)")

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PLSA276OK  ³ Autor ³ Alexander			³ Data ³ 23.06.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ oK da inclusao												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/          
Function PLSA276OK(lNotNotInc)
Local nReg 		:= BGH->(Recno())
Local lRet		:= .T.
LOCAL lTipAte   := (BGH->( FieldPos("BGH_TIPATE") ) > 0)
LOCAL cSql 		:= ""

Default lNotNotInc := .F.

cSql := " SELECT R_E_C_N_O_ REG FROM "+RetSqlName("BGH")+" Where BGH_GRUOPE = '"+M->BGH_GRUOPE+"' " 
cSql += " AND BGH_FINATE = '"+M->BGH_FINATE+"' "
cSql += " AND ( BGH_DATFIN = ' ' OR BGH_DATFIN >= '" + DtoS(M->BGH_DATINI) + "') "
cSql += " AND ( BGH_TABPAG = '" + M->BGH_TABPAG + "' OR BGH_TABREC = '" + M->BGH_TABREC + "' ) "
If lTipAte .AND. !(EmpTy(M->BGH_TIPATE))
	cSql += " AND BGH_TIPATE = '" + M->BGH_TIPATE + "' "
elseIf lTipAte .AND. (EmpTy(M->BGH_TIPATE))
	cSql += " AND BGH_TIPATE IN ('3', ' ') "
endIf
If lNotNotInc
	cSql += " AND R_E_C_N_O_ <> " + Alltrim(str(nReg))
endIf
cSql += " AND D_E_L_E_T_ = ' ' "

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),"TRBBGH",.T.,.T.)	

While !TRBBGH->( Eof() ) .AND. lRet
	BGH->( dbGoto(TRBBGH->REG) )
	If M->BGH_TABPAG == BGH->BGH_TABPAG
		Aviso( "Atenção", "A tabela de pagamento, com as mesmas configurações de regime e finalidade de atendimento, tem outra Vigência válida na data inicial desta", { "Ok" }, 2 )
		lRet := .F.
	elseif M->BGH_TABREC == BGH->BGH_TABREC
		Aviso( "Atenção", "A tabela de cobrança, com as mesmas configurações de regime e finalidade de atendimento, tem outra Vigência válida na data inicial desta", { "Ok" }, 2 )
		lRet := .F.
	endIf
	TRBBGH->( DbSkip() ) 
EndDo

TRBBGH->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no registro corrente											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BGH->( DbGoto(nReg) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ Plsa276Seq ³ Autor ³ Alexander			³ Data ³ 08/04/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Gera numero sequencial da tabela BGH						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276Seq()
Local aAreaBGH	:= BGH->(GetArea())
Local nSeq		:= 0

BeginSql Alias "TrbSeq"
	SELECT BGH.BGH_CODSEQ FROM %table:BGH% BGH
	WHERE BGH_FILIAL = %exp:xFilial("BGH")%
	AND BGH_GRUOPE 	= %exp:BGH->BGH_GRUOPE%
	AND BGH.%NotDel%
Endsql

While !TrbSeq->(EoF())
	nSeq:= Val(TrbSeq->BGH_CODSEQ)
	TrbSeq->(DbSkip())
EndDo

nSeq := StrZero(nSeq + 1,Len(BGH->BGH_CODSEQ))

TrbSeq->(DbCloseArea())
RestArea(aAreaBGH)

Return nSeq

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ 		   ³ Autor ³ TOTVS    			³ Data ³ 00/00/0000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276Sel()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'Plsa276Exc' , 0 ,K_Excluir   },;//Alexander AxDeleta
                         { STR0005, 'PLSA276UND', 0, K_Excluir },; //"Dif.p/Unidade"
                         { STR0006, 'PLSA276ESP', 0, K_Excluir },; //"Dif.p/Espec."
                         { STR0007, 'PLSA276PRO', 0, K_Excluir }} //"Dif.p/Produto"
                         
PRIVATE cAlias     := "BGI"
PRIVATE cCadastro  := PLSRetTit(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nova rotina de Niveis de Hospital										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aRotina,{ STR0016, 'Plsa276HOS', 0, K_Excluir })//"Dif.p/Niv. Hospital"

cFil := "BGI_FILIAL = '"+xFilial("BGI")+"' AND BGI_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND BGI_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BGI->(DbSetOrder(1))
BGI->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,nil,,cFil))
DbSelectArea(cAlias)
Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ 		   ³ Autor ³ TOTVS    			³ Data ³ 00/00/0000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276und()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'AxDeleta' , 0 ,K_Excluir   }}
PRIVATE cAlias     := "BMQ"
PRIVATE cCadastro  

If ! PLSALIASEX(cAlias)
   MsgStop(STR0008) //"Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BMQ"
   Return
Endif   

cCadastro := PLSRetTit(cAlias)

cFil := "BMQ_FILIAL = '"+xFilial("BMQ")+"' AND BMQ_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND BMQ_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND BMQ_CODPRO = '"+BGI->BGI_CODPRO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BMQ->(DbSetOrder(1))
BMQ->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil,,cFil))
DbSelectArea(cAlias)

Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ 		   ³ Autor ³ TOTVS    			³ Data ³ 00/00/0000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276ESP()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'AxDeleta' , 0 ,K_Excluir   }}
PRIVATE cAlias     := "BMT"
PRIVATE cCadastro  

If ! PLSALIASEX(cAlias)
   MsgStop(STR0009) //"Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BMT"
   Return
Endif   

cCadastro := PLSRetTit(cAlias)

cFil := "BMT_FILIAL = '"+xFilial("BMT")+"' AND BMT_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND BMT_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND BMT_CODPRO = '"+BGI->BGI_CODPRO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BMT->(DbSetOrder(1))

BMT->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,nil,,cFil))
DbSelectArea(cAlias)

Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ 		   ³ Autor ³ TOTVS    			³ Data ³ 00/00/0000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276PRO()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'Plsa276Exc' , 0 ,K_Excluir   },; //Alexander AxDeleta
                         { STR0010 , 'PLSA276PUN', 0, K_Excluir } } //"Dif.Unidade"
PRIVATE cAlias     := "BSM"
PRIVATE cCadastro  

If ! PLSALIASEX(cAlias)
   MsgStop(STR0011) //"Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BSM"
   Return
Endif   

cCadastro := PLSRetTit(cAlias)

cFil := "BSM_FILIAL = '"+xFilial("BSM")+"' AND BSM_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND BSM_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND BSM_CODPRO = '"+BGI->BGI_CODPRO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BSM->(DbSetOrder(1))

BSM->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil,,cFil))
DbSelectArea(cAlias)

Return

Function PLSA276PUN()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'AxDeleta' , 0 ,K_Excluir   }}
PRIVATE cAlias     := "BSX"
PRIVATE cCadastro  

If ! PLSALIASEX(cAlias)
   MsgStop(STR0012) //"Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BSX"
   Return
Endif   

cCadastro := PLSRetTit(cAlias)

cFil := "BSX_FILIAL = '"+xFilial("BSX")+"' AND BSX_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND BSX_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND BSX_CODPRO = '"+BGI->BGI_CODPRO+"' AND BSX_CODPLA = '"+BSM->BSM_CODPLA+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BSX->(DbSetOrder(1))

BSX->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil,,cFil))
DbSelectArea(cAlias)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para Copiar a vigencia e todos os registros de tabelas relacionadas³
//³Alexander 08/04/2005                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
function PLSA276CLO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavei Local                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nJ
Local nI
Local dDataInicio
Local nCodSeq
Local nContBGI
Local nContBMQ
Local nContBMT
Local nContBSM
Local nContBSX
Local aDadosBGH := {}
Local nColsBGH  := Len(BGH->(DbStruct())) 
Local aDadosBGI := {}
Local nColsBGI  := Len(BGI->(DbStruct())) 
Local aDadosBMQ := {}
Local nColsBMQ  := Len(BMQ->(DbStruct())) 
Local aDadosBMT := {}
Local nColsBMT  := Len(BMT->(DbStruct())) 
Local aDadosBSM := {}
Local nColsBSM  := Len(BSM->(DbStruct())) 
Local aDadosBSX := {}
Local nColsBSX  := Len(BSX->(DbStruct()))     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se a vigencia esta sem data final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(BGH->BGH_DATFIN)
    MsgInfo('Impossivel fazer copia de VIGENCIA FECHADA!')
    return
endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavei Privada                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
private cPerg       := "PLS276"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SX1                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSX1()                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a pergunta para inserir a Nova data inicial no registro clonado      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Pergunte(cPerg,.T.)  
   return 
endif             
dDataInicio := mv_par01 //Data Inicial
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega matriz com o registro a ser clonado do BGH Vigencias do grupo operadora     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BGH->(DbSetOrder(1)) //BGH_FILIAL + BGH_GRUOPE + BGH_CODSEQ
aadd(aDadosBGH,Array(nColsBGH))
For nI := 1 to nColsBGH
   aDadosBGH[1,nI] := BGH->(FieldGet(nI))
Next                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega matriz com o registro a ser clonado do BGI Vigencias/Tab.Precos		   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nContBGI := 0
nContBMQ := 0
nContBMT := 0
nContBSM := 0
nContBSX := 0
BGI->(DbSetOrder(1)) //BGI_FILIAL + BGI_GRUOPE + BGI_CODSEQ + BGI_CODPAD + BGI_CODPRO + BGI_NIVEL
if BGI->(MsSeek(xFilial("BGH")+BGH->(BGH_GRUOPE+BGH_CODSEQ)))
   while !(BGI->(eof())) .and. ( xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ) == xFilial("BGH")+BGH->(BGH_GRUOPE+BGH_CODSEQ) )
   	    nContBGI++
	    aadd(aDadosBGI,array(nColsBGI))
	    for nI := 1 to nColsBGI
	      aDadosBGI[nContBGI,nI] := BGI->(FieldGet(nI))
	    next                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega matriz com o registro a ser clonado do BMQ Grp.Ope X Procedimentos X SubItens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BMQ->(DbSetOrder(1)) //BMQ_FILIAL + BMQ_GRUOPE + BMQ_CODSEQ + BMQ_CODPAD + BMQ_CODPRO + BMQ_CODUNM + BMQ_NIVEL
		if BMQ->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   while !(BMQ->(Eof())) .and. ( xFilial("BMQ")+BMQ->(BMQ_GRUOPE+BMQ_CODSEQ+BMQ_CODPAD+BMQ_CODPRO) == xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO) )
		   	   nContBMQ++
			   aadd(aDadosBMQ,Array(nColsBMQ))
			   For nI := 1 to nColsBMQ
			     aDadosBMQ[nContBMQ,nI] := BMQ->(FieldGet(nI))
			   Next                           
			   BMQ->(DbSkip())
		   enddo	   
		endif 	          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega matriz com o registro a ser clonado do BMT Grp.Ope X Procedimentos X Espec. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BMT->(DbSetOrder(1)) //BMT_FILIAL + BMT_GRUOPE + BMT_CODSEQ + BMT_CODPAD + BMT_CODPRO + BMT_CODESP + BMT_NIVEL
		if BMT->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   while !(BMT->(Eof())) .and. ( xFilial("BMT")+BMT->(BMT_GRUOPE+BMT_CODSEQ+BMT_CODPAD+BMT_CODPRO) == xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO) )
		   	   nContBMT++
			   aadd(aDadosBMT,Array(nColsBMT))
			   For nI := 1 to nColsBMT
			     aDadosBMT[nContBMT,nI] := BMT->(FieldGet(nI))
			   Next                           
			   BMT->(DbSkip())
		   enddo	   
		endif 	          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega matriz com o registro a ser clonado do BSM Grp.Ope X Procedimentos X Produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BSM->(DbSetOrder(1)) //BSM_FILIAL + BSM_GRUOPE + BSM_CODSEQ + BSM_CODPAD + BSM_CODPRO + BSM_CODPLA + BSM_NIVEL
		if BSM->(MsSeek(xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)))
		   while !(BSM->(Eof())) .and. ( xFilial("BSM")+BSM->(BSM_GRUOPE+BSM_CODSEQ+BSM_CODPAD+BSM_CODPRO) == xFilial("BGI")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO) )
		   	   nContBSM++
			   aadd(aDadosBSM,Array(nColsBSM))
			   For nI := 1 to nColsBSM
			     aDadosBSM[nContBSM,nI] := BSM->(FieldGet(nI))
			   Next                           
	   		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³Carrega matriz com o registro a ser clonado do BSX Grp.Operadora X Prod.X Unidade   ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   BSX->(DbSetOrder(1)) //BSX_FILIAL + BSX_GRUOPE + BSX_CODSEQ + BSX_CODPAD + BSX_CODPRO + BSX_CODPLA + BSX_CODUNM + BSX_NIVEL
			   if BSX->( MsSeek( xFilial("BSM")+BSM->(BSM_GRUOPE+BSM_CODSEQ+BSM_CODPAD+BSM_CODPRO+BSM_CODPLA) ) )
			      while !(BSX->(Eof())) .and. ( xFilial("BSX")+BSX->(BSX_GRUOPE+BSX_CODSEQ+BSX_CODPAD+BSX_CODPRO+BSX_CODPLA) == xFilial("BSM")+BSM->(BSM_GRUOPE+BSM_CODSEQ+BSM_CODPAD+BSM_CODPRO+BSM_CODPLA) )
			     	   nContBSX++
					   aadd(aDadosBSX,Array(nColsBSX))
					   For nI := 1 to nColsBSX
					     aDadosBSX[nContBSX,nI] := BSX->(FieldGet(nI))
					   Next                           
					   BSX->(DbSkip())
				  enddo	   
			   endif 	          
			   BSM->(DbSkip())
		   enddo	   
		endif 	          
	    BGI->(DbSkip())
   enddo	    
endif 	          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a DATA FINAL do registro clonado com a data inicio do novo registro menos 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BGH->(RecLock("BGH"))
 BGH->BGH_DATFIN := dDataInicio-1
BGH->(MsUnlock())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ anterior mais 1 BGH Vigencias do grupo operadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBGH)
    BGH->(RecLock("BGH",.T.))
	For nJ := 1 To nColsBGH
		BGH->(FieldPut(nJ,aDadosBGH[nI,nJ]))
	Next   
	BGH->BGH_DATINI := dDataInicio
	nCodSeq 		:= StrZero( ( Val(BGH->BGH_CODSEQ)+1 ),Len( BGH->BGH_CODSEQ ) ) 
	BGH->BGH_CODSEQ := nCodSeq
  	BGH->(DbUnlock())
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ NOVO BGI Vigencias/Tab.Precos					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBGI)
    BGI->(RecLock("BGI",.T.))
	For nJ := 1 To nColsBGI
		BGI->(FieldPut(nJ,aDadosBGI[nI,nJ]))
	Next   
	BGI->BGI_CODSEQ := nCodSeq
  	BGI->(DbUnlock())
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ NOVO BMQ Grp.Ope X Procedimentos X SubItens			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBMQ)
    BMQ->(RecLock("BMQ",.T.))
	For nJ := 1 To nColsBMQ
		BMQ->(FieldPut(nJ,aDadosBMQ[nI,nJ]))
	Next   
	BMQ->BMQ_CODSEQ := nCodSeq
  	BMQ->(DbUnlock())
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ NOVO BMT Grp.Ope X Procedimentos X Espec.				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBMT)
    BMT->(RecLock("BMT",.T.))
	For nJ := 1 To nColsBMT
		BMT->(FieldPut(nJ,aDadosBMT[nI,nJ]))
	Next   
	BMT->BMT_CODSEQ := nCodSeq
  	BMT->(DbUnlock())
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ NOVO BSM Grp.Ope X Procedimentos X Produto			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBSM)
    BSM->(RecLock("BSM",.T.))
	For nJ := 1 To nColsBSM
		BSM->(FieldPut(nJ,aDadosBSM[nI,nJ]))
	Next   
	BSM->BSM_CODSEQ := nCodSeq
  	BSM->(DbUnlock())
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Novo Registro com o BGH_CODSEQ NOVO BSX Grp.Operadora X Prod.X Unidade				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDadosBSX)
    BSX->(RecLock("BSX",.T.))
	For nJ := 1 To nColsBSX
		BSX->(FieldPut(nJ,aDadosBSX[nI,nJ]))
	Next   
	BSX->BSX_CODSEQ := nCodSeq
  	BSX->(DbUnlock())
Next

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaSX1  ³ Autor ³ Angelo Sperandio      ³ Data ³ 05/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza perguntas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CriaSX1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Iniciliza variaveis                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRegs	:=	{}
aadd(aRegs,{cPerg,"01",STR0013,"","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})			 //"Data de Inicio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SX1                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PlsVldPerg(aRegs)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ Plsa276HOS ³ Autor ³ TOTVS    			³ Data ³ 10/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa276HOS()
Local cFil
PRIVATE aRotina    := { { STRPL01  , 'AxPesqui' , 0 ,K_Pesquisar },;
                         { STRPL02 , 'AxVisual' , 0 ,K_Visualizar},;
       				     { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   },;
       				     { STRPL04  	, 'AxAltera' , 0 ,K_Alterar   },;
                         { STRPL05	 , 'Plsa276Exc' , 0 ,K_Excluir   },; //Alexander AxDeleta
                         { STR0017 , 'PLSA276CNI', 0, K_Incluir } } //"Carrega Níveis"
PRIVATE cAlias     := "B7U"
PRIVATE cCadastro  

cCadastro := PLSRetTit(cAlias)

cFil := "B7U_FILIAL = '"+xFilial("B7U")+"' AND B7U_GRUOPE = '"+BGH->BGH_GRUOPE+"' AND B7U_CODSEQ = '"+BGH->BGH_CODSEQ+"' AND B7U_CODPRO = '"+BGI->BGI_CODPRO+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
B7U->(DbSetOrder(1))                                   	

B7U->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil,,cFil))
DbSelectArea(cAlias)

Return  

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PLSA276CNI ³ Autor ³ TOTVS    			³ Data ³ 10/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA276CNI()  
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" ) 
Local aNiveis := {}

B7S->(DbSetOrder(1))
B7S->(DbSeek(xFilial("B7S")))   
B7U->(DbSetOrder(1))
While B7S->(!Eof()) .And. B7S->B7S_FILIAL == xFilial("B7S")          

	If !B7U->(DbSeek(xFilial("B7U")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)+B7S->B7S_CODIGO))   
		aAdd(aNiveis,{.F.,B7S->B7S_CODIGO,B7S->B7S_DESNIV})
	EndIf
		
   	B7S->(dbSkip())
End

If len(aNiveis) > 0
	DEFINE MSDIALOG oDlg TITLE STR0019 FROM 0,0 TO 400,380 PIXEL  //"Níveis de Hospital - Intercâmbio"
	
	@ 005,005 SAY oSay PROMPT STR0020 OF oDlg PIXEL SIZE 0100, 015 //"Selecione os níveis"
	
	@ 015,005 LISTBOX oEmpresa FIELDS HEADER "",STR0021,STR0022 FIELDSIZES 14,35 SIZE 183,160 PIXEL OF oDlg //"Código","Descrição"
	
	oEmpresa:SetArray(aNiveis)
	oEmpresa:bLine      := {|| {If(aNiveis[oEmpresa:nAt,1],oOk,oNo),aNiveis[oEmpresa:nAt,2],aNiveis[oEmpresa:nAt,3] }}
	oEmpresa:bLDblClick := {|| aNiveis[oEmpresa:nAt,1] := !aNiveis[oEmpresa:nAt,1], oEmpresa:DrawSelect() }
       
	@ 0180, 040 BUTTON oBtn PROMPT STR0023    SIZE 045,016 ACTION MarDesNiv( @oEmpresa,@aNiveis, .T. ) OF oDlg PIXEL //"Marca Todos"
	@ 0180, 090 BUTTON oBtn PROMPT STR0024    SIZE 045,016 ACTION MarDesNiv( @oEmpresa,@aNiveis, .F. ) OF oDlg PIXEL //"Desmarca Todos"
	@ 0180, 140 BUTTON oBtn PROMPT STR0025    SIZE 045,016 ACTION copyNiveis( aNiveis,oDlg ) OF oDlg PIXEL //"Confirmar"
	      
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	MsgInfo(STR0026) //"Não há registros para adicionar."
EndIf

Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ MarDesNiv  ³ Autor ³ TOTVS    			³ Data ³ 11/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Marca ou Desmarca registros de niveis  						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarDesNiv(oEmpresa,aNiveis,lMarca)   
Local nX := 0 

For nX := 1 to len(aNiveis)
	If lMarca
		aNiveis[nX][1]  := .T. 
		oEmpresa:aArray[nX][1] := .T.
	Else
		aNiveis[nX][1]  := .F.   
		oEmpresa:aArray[nX][1] := .F.
	EndIf
Next

Return

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ copyNiveis ³ Autor ³ TOTVS    			³ Data ³ 11/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function copyNiveis(aNiveis,oDlg)  
Local nX := 0     

B7U->(DbSetOrder(1))//B7U_FILIAL + B7U_GRUOPE + B7U_CODSEQ + B7U_CODPAD + B7U_CODPRO + B7U_NIVHOS + B7U_NIVEL 
For nX := 1 to len(aNiveis)
	If aNiveis[nX][1] .And. !B7U->(DbSeek(xFilial("B7U")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)+aNiveis[nX][2]))
 		B7U->(RecLock("B7U",.T.))
			B7U->B7U_FILIAL := xFilial("B7U") 
			B7U->B7U_CODSEQ := BGI->BGI_CODSEQ    
			B7U->B7U_GRUOPE := BGI->BGI_GRUOPE
			B7U->B7U_CODPAD := BGI->BGI_CODPAD
			B7U->B7U_CODPRO := BGI->BGI_CODPRO
			B7U->B7U_NIVEL  := BGI->BGI_NIVEL 
			B7U->B7U_CDNV01 := BGI->BGI_CDNV01 
			B7U->B7U_CDNV02 := BGI->BGI_CDNV02 
			B7U->B7U_CDNV03 := BGI->BGI_CDNV03 
			B7U->B7U_CDNV04 := BGI->BGI_CDNV04 
			B7U->B7U_NIVHOS := aNiveis[nX][2]
			B7U->B7U_DESNIV := aNiveis[nX][3]
		B7U->(MsUnlock())
	EndIf
Next
oDlg:End()

Return

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ copyNiveis ³ Autor ³ TOTVS    			³ Data ³ 11/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³                                       						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL276FiVld(cField)
Local lRet  := .T.
Local aArea := {}
Do Case
	Case cField == "B7U_NIVHOS"
		aArea := B7S->(GetArea())
		B7S->(DbSetOrder(1))
		If !B7S->(DbSeek(xFilial("B7S")+M->B7U_NIVHOS))
 			MsgInfo(STR0027)//"Não foi encontrado o nível digitado na tabela B7S."
			lRet := .F.
		EndIf
		RestArea(aArea)  
		
		aArea := B7U->(GetArea())
		B7U->(DbSetOrder(1))
		If B7U->(DbSeek(xFilial("B7U")+BGI->(BGI_GRUOPE+BGI_CODSEQ+BGI_CODPAD+BGI_CODPRO)+M->B7U_NIVHOS))   
			MsgInfo(STR0028) //"Registro já foi digitado."
			lRet := .F.
		EndIf
		RestArea(aArea)  
EndCase	
                           
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³02/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef(lAll)
default lAll := .T.
Private aRotina := {	{ STRPL01	, 'AxPesqui'   , 0 , K_Pesquisar , 0, .F.},;
						{ STRPL02	, 'AxVisual'   , 0 , K_Visualizar, 0, Nil},;
       				    { STRPL03	, 'AxInclui'   , 0 , K_Incluir   , 0, Nil},;
       				    { STRPL04	, 'AxAltera'   , 0 , K_Alterar   , 0, Nil},;
       				    { STRPL05	, 'Plsa276Exc' , 0 , K_Excluir   , 0, Nil},;
       				    { STR0014	, 'PlSA276Vg'  , 0 , K_Alterar   , 0, Nil}} //"Vigencias"

If lAll

	aadd( aRotina, { STRPL01   	, 'AxPesqui'   , 0 ,K_Pesquisar } )
	aadd( aRotina, { STRPL02  	, 'AxVisual'   , 0 ,K_Visualizar} )
	aadd( aRotina, { STRPL03  	, 'PlSA276Inc' , 0 ,K_Incluir   } )
	aadd( aRotina, { STRPL04  	, 'AxAltera'   , 0 ,K_Alterar   } )
	aadd( aRotina, { STRPL05	 	, 'Plsa276Exc'   , 0 ,K_Excluir } )
	aadd( aRotina, { STR0001		, 'PlSA276Sel' , 0 ,K_Alterar   } )
	aadd( aRotina, { STR0002     , 'PLSA276CLO' , 0 ,K_Copiar   } )
	aadd( aRotina, { OemtoAnsi(STR0015)	,'PL276DifID()',0,K_Alterar} )
	aadd( aRotina, { STRPL03  	, 'AxInclui' , 0 ,K_Incluir   } )
	aadd( aRotina, { STR0005, 'PLSA276UND', 0, K_Excluir } )
	aadd( aRotina, { STR0006, 'PLSA276ESP', 0, K_Excluir } )
	aadd( aRotina, { STR0007, 'PLSA276PRO', 0, K_Excluir } )
	aadd( aRotina, { STR0016, 'Plsa276HOS', 0, K_Excluir } )
	aadd( aRotina, { STRPL05	, 'AxDeleta'  , 0, K_Excluir } )
	aadd( aRotina, { STR0010 , 'PLSA276PUN', 0, K_Excluir } )
	aadd( aRotina, { STR0017 , 'PLSA276CNI', 0, K_Incluir } )
                         
endIf

Return(aRotina)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL276DifID
função para chamada do PlVigDifId.  Criada para que o cadastro de privilégios funcione corretamente.
@author    Oscar
@since     29/04/2019
/*/
//------------------------------------------------------------------------------------------
function PL276DifID()

return PlVigDifId("BGH","BGH->(BGH_FILIAL+BGH_GRUOPE+BGH_CODSEQ)",BGH->BGH_DIFIDA)
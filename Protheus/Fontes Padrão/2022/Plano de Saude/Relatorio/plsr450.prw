#include "PROTHEUS.CH"
#include "PLSMGER.CH"

STATIC aCodProErro := {}
static objCENFUNLGP := CENFUNLGP():New() 
Static lAutoSt := .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSR450  ³ Autor ³ Alexander Santos       ³ Data ³ 14.06.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³Emite relatorio de faturamento de intercambio eventual      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR450                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³			 ³      ³  			  ³ 						              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define nome da funcao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLSR450(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lAuto := lAutoSt

PRIVATE cCodIntOri   	//Operadora Origem
PRIVATE cCodIntDes  	//Operadora Destino
PRIVATE nStatusFA		//A Faturar / Faturado
PRIVATE cMesBase		//Mes de Base
PRIVATE cAnoBase		//Ano de Base
PRIVATE cNumeLote		//Numero do Lote
PRIVATE nConverte       //nConverte
PRIVATE dDataAP
PRIVATE cNumTSe1		//Numero do Titulo do SE1

PRIVATE aResumo		:= {}
PRIVATE pMoeda      := "@E 99,999.99"
PRIVATE pMoeda1     := "@E 99,999,999.99"
PRIVATE nQtdLin     := 64     
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := "" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDH"
PRIVATE nLi         := 1   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {} 
PRIVATE lAbortPrint := .F.
PRIVATE nColuna     := 01 
PRIVATE aLinha      := {}
PRIVATE cPerg       := "PLR450"
PRIVATE cRel        := "PLSR450"
PRIVATE cTitulo     := FunDesc() //"Faturamento de Intercâmbio"      
PRIVATE cCabec1     := ""
PRIVATE cCabec2 	:= ""
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 

lAutoSt := lAuto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSRelTop()
   Return
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
	cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto .AND. nLastKey  == 27 
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca os parametros...  Sai se o usuario clicar no X                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte(cPerg,.F.)   
   Return 
endif             
cCodIntOri  := Mv_Par01
cCodIntDes  := Mv_Par02
nStatusFA	:= Mv_Par03
cMesBase	:= Mv_Par04
cAnoBase	:= Mv_Par05
cNumeLote	:= Mv_Par06
nConverte   := mv_par07
dDataAP     := mv_par08

aCodProErro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o numero do titulo correspondente no se1							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BTO->( DbSetOrder(1) ) //BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
BTO->( MsSeek( xFilial("BTO")+cCodIntOri+cNumeLote+cCodIntDes ) )
cNumTSe1 := BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
	SetDefault(aReturn,cAlias) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo += " - Competencia: "+cMesBase+"/"+cAnoBase
if !lAuto
	MsAguarde({|| RBDHImp() }, cTitulo, "Aguarde..", .T.)
else
	RBDHImp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ RBDHImp	 ³ Autor ³ Alexander Santos      ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function RBDHImp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL
LOCAL cCodNum
LOCAL cVlrSenha := '---------'
LOCAL cVlrPAne  := Space(6)
LOCAL nVlrTad   := 0
LOCAL nVlrTpf   := 0                        
LOCAL cCodPro
LOCAL cCodPeg
LOCAL cNumNot
PRIVATE cTipGui 
PRIVATE cOpeOri                                     
PRIVATE cCodSer
PRIVATE cCodSeq
PRIVATE cDesOpe := '---------'
PRIVATE cEmpOri               
PRIVATE cDescNota := 'Notas'
PRIVATE cDescIten := 'Itens Serviços'             
PRIVATE cDescQtd  := 'Qtds  Serviços'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	MsProcTxt(PLSTR0001) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz filtro no arquivo...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := " SELECT BDH.BDH_CODINT,BDH.BDH_OPEORI,BDH.BDH_EMPORI,BDH.BDH_NUMFAT, "
cSQL += " 		 BD6.BD6_CODOPE,BD6.BD6_CODLDP,BD6.BD6_TIPGUI,BD6.BD6_CODPEG,BD6.BD6_NUMERO,BD6.BD6_MATANT,BD6.BD6_NOMUSR,BD6.BD6_DATPRO,BD6.BD6_CODPLA,BD6.BD6_DESPRO,BD6.BD6_CODRDA,BD6.BD6_CODPRO,BD6.BD6_QTDPRO,BD6.BD6_TPPF,BD6.BD6_CODEMP,BD6.BD6_SEQUEN,BD6.BD6_NUMIMP,BD6.BD6_ORIMOV, "
cSQL += " 	     (BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE) CHAVEBD5BE4, "
cSQL += "        BD7.BD7_CODUNM,BD7.BD7_VLRTAD,BD7.BD7_VLRTPF, "
cSQL += "        (BD6.BD6_CODTAB+BD6.BD6_CODPAD+BD6.BD6_CODPRO+BD7.BD7_CODUNM) CHAVEBD4 "
cSQL += "  FROM "+RetSQLName("BDH")+" BDH, "+RetSQLName("BD6")+" BD6, "+RetSQLName("BD7")+" BD7 "//+RetSQLName("BA1")+" BA1 "
cSQL += " WHERE BDH.BDH_FILIAL = '"+xFilial("BDH")+"'"
cSQL += "   AND BDH.BDH_CODINT = '"+cCodIntOri+"' " 
cSQL += "   AND BDH.BDH_OPEORI = '"+cCodIntDes+"' "
If nStatusFA == 1 //A Faturar
   cSQL += "   AND BDH.BDH_MESFT  <= '"+cMesBase+"' "
   cSQL += "   AND BDH.BDH_ANOFT  <= '"+cAnoBase+"' " 
   cSQL += "   AND BDH.BDH_STATUS = '1' "
Else //Faturado
   cSQL += "   AND BDH.BDH_STATUS = '0' "
   cSQL += "   AND BDH.BDH_PREFIX = '"+BTO->BTO_PREFIX+"' "
   cSQL += "   AND BDH.BDH_NUMTIT = '"+BTO->BTO_NUMTIT+"' "
   cSQL += "   AND BDH.BDH_PARCEL = '"+BTO->BTO_PARCEL+"' "
   cSQL += "   AND BDH.BDH_TIPTIT = '"+BTO->BTO_TIPTIT+"' "
Endif                              
cSQL += "   AND BDH.D_E_L_E_T_ = ' ' "
cSQL += "   AND BD6.BD6_FILIAL = '"+xFilial("BD6")+"'"
cSQL += "   AND BD6.BD6_OPEUSR = BDH.BDH_CODINT "  
cSQL += "   AND BD6.BD6_CODEMP = BDH.BDH_CODEMP " 
cSQL += "   AND BD6.BD6_MATRIC = BDH.BDH_MATRIC " 
cSQL += "   AND BD6.BD6_TIPREG = BDH.BDH_TIPREG " 
cSQL += "   AND BD6.BD6_SEQPF  = BDH.BDH_SEQPF "  
cSQL += "   AND BD6.BD6_ANOPAG = BDH.BDH_ANOFT "
cSQL += "   AND BD6.BD6_MESPAG = BDH.BDH_MESFT "
cSQL += "   AND BD6.D_E_L_E_T_ = ' ' "

cSQL += "   AND BD7.BD7_FILIAL = '"+xFilial("BD7")+"'"
cSQL += "   AND BD7.BD7_CODOPE = BD6.BD6_CODOPE "
cSQL += "   AND BD7.BD7_OPEUSR = BD6.BD6_OPEUSR "
cSQL += "   AND BD7.BD7_CODEMP = BD6.BD6_CODEMP "
cSQL += "   AND BD7.BD7_MATRIC = BD6.BD6_MATRIC "
cSQL += "   AND BD7.BD7_TIPREG = BD6.BD6_TIPREG "
cSQL += "   AND BD7.BD7_CODLDP = BD6.BD6_CODLDP "
cSQL += "   AND BD7.BD7_CODPEG = BD6.BD6_CODPEG "
cSQL += "   AND BD7.BD7_NUMERO = BD6.BD6_NUMERO "
cSQL += "   AND BD7.BD7_ORIMOV = BD6.BD6_ORIMOV "
cSQL += "   AND BD7.BD7_SEQUEN = BD6.BD6_SEQUEN "
cSQL += "   AND BD7.BD7_ANOPAG = BD6.BD6_ANOPAG "
cSQL += "   AND BD7.BD7_MESPAG = BD6.BD6_MESPAG "
cSQL += "   AND BD7.D_E_L_E_T_ = ' ' "

cSQL += " ORDER BY BDH.BDH_OPEORI,BDH.BDH_EMPORI,BD6.BD6_TIPGUI,BD6.BD6_CODPEG,BD6.BD6_NUMERO,BD6.BD6_MATANT,BD6.BD6_DATPRO,BD6_SEQUEN"
PLSQuery(cSQL,"BDHTRB")   

If BDHTRB->( Eof() )
   if !lAutoSt
	   MsgInfo('Não existem registros para os parametros informados !')
   endif
   BDHTRB->(DbCloseArea())
   Return
EndIf
BDHTRB->( DbGotop() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega a Data da Emissao da Cobrança no cabecalho do lote					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nStatusFA == 1 //A Faturar
   cDatCob := 'Em Aberto'
Else
   BDC->( DbSetOrder(1) )
   BDC->( MsSeek( xFilial('BDC')+BDHTRB->BDH_NUMFAT ) )
   cDatCob := DtoC(BDC->BDC_DATGER)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta order para o bea													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEA->( DbSetOrder(12) ) //BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao dos detalhes...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !BDHTRB->(Eof())
 	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Exibe mensagem...                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      if !lAutoSt
		  MsProcTXT("Imprimindo "+BDHTRB->BD6_MATANT+"...")
      endif
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica se foi abortada a impressao...                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      EndIf      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inicio da Impressao												 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If cTipGui <> BDHTRB->BD6_TIPGUI .or. cCodNum <> BDHTRB->BD6_NUMERO .or.;                         
	     cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI .or.;
	     cCodPeg <> BDHTRB->BD6_CODPEG 
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Limpa o tipo de servico											 ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	  	  cCodSer := ''
 	  	  cCodSeq := ''
          If !Empty(cCodNum) .and. (cCodNum <> BDHTRB->BD6_NUMERO .or. cTipGui <> BDHTRB->BD6_TIPGUI .or. cCodPeg <> BDHTRB->BD6_CODPEG ) 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Imprime Total Adm e Fat. Moderador								    ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             ImpTotAdm(nVlrTad,nVlrTpf)
 			 cCodNum := BDHTRB->BD6_NUMERO		 	  
 			 cCodPeg := BDHTRB->BD6_CODPEG
          	 nVlrTad := 0
	  		 nVlrTpf := 0 
	      EndIf                           
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Monta cabecalho...                                                       ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  If cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI
		 	  cOpeOri := BDHTRB->BDH_OPEORI 
		 	  BA0->( DbSetOrder(1) ) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		 	  If BA0->( MsSeek( xFilial("BA0")+cOpeOri ) )                         
			 	 cDesOpe := BA0->BA0_NOMINT
			  EndIf
		 	  cEmpOri := BDHTRB->BDH_EMPORI 
			  cCabec1 := "Unimed Cobr:"+cOpeOri+' - '+cDesOpe+Space(2)+"Empresa:"+cEmpOri+Space(2)+" Dt. Emissão Cobrança: "+cDatCob
 			  nLi 	  := 1
		  EndIf				 
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Imprime cabecalho...                                                     ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If nLi > nQtdLin .or. nLi == 1
    	     RBDHCabec(1)
	      Endif                  
 	  	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Imprime Guia														 ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		  If cTipGui <> BDHTRB->BD6_TIPGUI
		 	  cTipGui := BDHTRB->BD6_TIPGUI 
 			  cCodNum := BDHTRB->BD6_NUMERO		 	  
 			  cCodPeg := BDHTRB->BD6_CODPEG
	  		  @ ++nLi,nColuna pSay Iif(cTipGui == '01','Consulta',Iif(cTipGui == '02','Serviço','Hospitalar'))
	  		  @ ++nLi,nColuna pSay Replicate('_',15)
	  	  EndIf	  
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	  //³ Descricao do Usuario										 	 ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          If  len(alltrim(BDHTRB->BD6_MATANT)) == 17
              cMat := TransForm(BDHTRB->BD6_MATANT,"@R !!!!.!!!!.!!!!!!.!!-!")
          Else
              cMat := TransForm(BDHTRB->BD6_MATANT,"@R !!!.!!!!.!!!!!!.!!-!") + space(1)
          Endif
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Verifica o tipo de Guia para pegar a senha							   ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If Val(BDHTRB->BD6_TIPGUI) <= 2 
		      BD5->( DbSetOrder(1) )//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
		      If BD5->( MsSeek( xFilial("BD5")+BDHTRB->CHAVEBD5BE4 ) )
		         cVlrSenha := BD5->BD5_SENHA
		      EndIf    
	      Else 
		      BE4->( DbSetOrder(1) )//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		      If BE4->( MsSeek( xFilial("BE4")+BDHTRB->CHAVEBD5BE4 ) )
		         cVlrSenha := BE4->BE4_SENHA
		      EndIf    
	      EndIf    
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Verifica se tem porte aneste.											   ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If BDHTRB->BD7_CODUNM == 'PA'
		      BD4->(DbSetOrder(1))// BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODIGO + DTOS(BD4_VIGINI)
		      If BD4->( MsSeek( xFilial("BD4")+BDHTRB->CHAVEBD4 ) )
		         cVlrPAne := Str( Floor( BD4->BD4_VALREF ) )
		      EndIf    
	      EndIf                               
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Pega o numero da autorizacao											   ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      cNumNot := BDHTRB->BD6_NUMIMP
	      If Empty(cNumNot)
		     BEA->( MsSeek( xFilial("BEA")+BDHTRB->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) ) )
		     cNumNot := AllTrim(BEA->BEA_NUMAUT)+Space(16-Len(AllTrim(BEA->BEA_NUMAUT)))
		  EndIf    
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	  //³ Imprime														 ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      @ ++nLi,nColuna	 pSay BDHTRB->BD6_CODLDP	 	+Space(2)+;
	      						  BDHTRB->BD6_CODPEG	 	+Space(2)+;
	      			     	 	  BDHTRB->BD6_NUMERO		+Space(2)+;
	      			     	 	  cNumNot					+Space(4)+;
	      				 		  cMat						+Space(2)+;
	      				 		  BDHTRB->BD6_NOMUSR 
	      				 
		@ ++nLi,nColuna      pSay DtoC(BDHTRB->BD6_DATPRO)
		@   nLi,(nColuna+9)  pSay cVlrSenha				
	    @   nLi,(nColuna+20) pSay BDHTRB->BD6_CODPLA		
		@   nLi,(nColuna+27) pSay BDHTRB->BD6_CODRDA
	  EndIf
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Imprime BD6...                                                  	 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If cCodSer <> BDHTRB->BD6_CODPRO .Or. cCodSeq <> BDHTRB->BD6_SEQUEN
          If !Empty(cCodSer)
             ++nLi
          EndIf   
	      cCodSer := BuscaCod(BDHTRB->BD6_CODPRO,BDHTRB->BD6_DATPRO)                                  
	      cCodSeq := BDHTRB->BD6_SEQUEN
		  @ nLi,(nColuna+38)  pSay cVlrPAne
		  @ nLi,(nColuna+46)  pSay Left(BDHTRB->BD6_DESPRO,40)
		  @ nLi,(nColuna+88)  pSay cCodSer                    
	  	  @ nLi,(nColuna+103) pSay AllTrim(Str(BDHTRB->BD6_QTDPRO))
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Para resumo de Itens													   ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescIten,1)	     
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Para resumo de Qtd de Itens											   ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescQtd,BDHTRB->BD6_QTDPRO)
	  EndIf                                        
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Imprime BD7...                                                  	 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cCodPro := BDHTRB->BD7_CODUNM
      @ ++nLi,(nColuna+88)  pSay BDHTRB->BD7_CODUNM+Space(Abs(Len(BDHTRB->BD7_CODUNM)-28))+;
				 			     TransForm(BDHTRB->(BD7_VLRTPF-BD7_VLRTAD),pMoeda)         
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Para resumo de Composicao do procedimento								   ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,BDHTRB->BD7_CODUNM,BDHTRB->(BD7_VLRTPF-BD7_VLRTAD))      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Totais															 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  nVlrTad += BDHTRB->BD7_VLRTAD                   
	  nVlrTpf += BDHTRB->(BD7_VLRTPF-BD7_VLRTAD)
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acessa proximo registro...                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      BDHTRB->(DbSkip())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ verifica proxima pagina...                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If nLi > nQtdLin
          RBDHCabec(1) 
      Endif                  
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Se mudou de empresa e ou operadora								 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !BDHTRB->( Eof() ) .and. (cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI) 
	      If Len(aResumo) > 0              
		     ImpTotAdm(nVlrTad,nVlrTpf)
			 nVlrTad := 0
			 nVlrTpf := 0  
   	         cCodNum := ''
   	         cTipGui := ''                 
   	         cCodPeg := ''
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		     //³ Cabecalho e Resumo Empresa											³
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 RBDHCabec(2) 
			 ImpResumo(1,cOpeOri,cEmpOri)                            
			 If cOpeOri <> BDHTRB->BDH_OPEORI
				 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			     //³ Cabecalho e Resumo Operadora										³
			     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				 RBDHCabec(2)
				 ImpResumo(2,cOpeOri,cEmpOri)                            
			 EndIf
		  EndIf
	  EndIf
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Total Adm e Fat. Moderador								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ImpTotAdM(nVlrTad,nVlrTpf)
nVlrTad := 0
nVlrTpf := 0  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho e Resumo Empresa	  									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RBDHCabec(2)
ImpResumo(1,cOpeOri,cEmpOri)                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho e Resumo Operadora 									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := "Unimed Cobr:"+cOpeOri+' - '+cDesOpe+Space(2)+" Dt. Emissão Cobrança: "+cDatCob
RBDHCabec(2)
ImpResumo(2,cOpeOri,cEmpOri)                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho e Resumo Geral do Relatorio							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RBDHCabec(3)
ImpResumo(3,cOpeOri,cEmpOri)                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape do relatorio...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	Roda(0,space(10),cTamanho)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BDHTRB->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. Len(aCodProErro) > 0
   PLSCRIGEN(aCodProErro,{ {"Critica","@C",200} },"Criticas")
Endif


If !lAutoSt .AND. aReturn[5] == 1 
   Set Printer To
   Ourspool(cRel)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
                        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ ImpToTAdm ³ Autor ³ Alexander Santos     ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Total Administracao e Fator Moderador			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function ImpTotAdm(nVlrTad,nVlrTpf)      
      LOCAL cDescText
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Imprime valor Administracao/Fator Moderador						 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cDescText := IiF(BDHTRB->BD6_TPPF == '1','F.Moderador   ','Taxa Administ ')	      
	  @ ++nLi,89  pSay cDescText				+Space(Abs(Len(cDescText)-16))+Space(12)+;
	  				   TransForm(nVlrTad,pMoeda)
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Resumo de Taxas													 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescText,nVlrTad)      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Resumo de Notas													 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescNota,1)      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Imprime Total da Guia												 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  @ ++nLi,89 pSay 'Total Nota'+Space(14)+;
	 				  			   TransForm((nVlrTpf+nVlrTad),pMoeda1)
Return	


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ ImpResumo ³ Autor ³ Alexander Santos     ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Resumo											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function ImpResumo(nTipo,cOpe,cEmp)      
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaracao de Variaveis											   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
    LOCAL cDesAux
    LOCAL nQtdTEmp := 0
	LOCAL nQtdTGer := 0
    LOCAL nVlrTGer := 0
	LOCAL nVlrTCon := 0
	LOCAL nVlrTSer := 0
	LOCAL nVlrTHos := 0            
	LOCAL nVlrTEmp := 0
    LOCAL aResuAux := {}      
    LOCAL aResuOld := {}
    LOCAL cDesc    := 'Total da Empresa :'  
    LOCAL ni
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta matriz para impressao do resumo da Operadora				   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aResuOld := aClone(aResumo)         
    
    If nTipo == 2
	   cDesc    := 'Total da Operadora :'
       For nI := 1 To Len(aResumo)
           If aResumo[nI,1] == cOpe 
		      nPos := Ascan( aResuAux, { |x| x[3] == aResumo[nI,3] } )
		      If nPos <> 0 
			     aResuAux[nPos,4] += aResumo[nI,4]
			     aResuAux[nPos,5] += aResumo[nI,5]
			     aResuAux[nPos,6] += aResumo[nI,6]
		      Else
	           	 AaDd(aResuAux,{aResumo[nI,1],'T',aResumo[nI,3],aResumo[nI,4],aResumo[nI,5],aResumo[nI,6]})
           	  EndIf
           EndIf
       Next
       cEmp    := 'T'                     
       aResumo := aClone(aResuAux)
    ElseIf nTipo == 3      
       For nI := 1 To Len(aResumo)
           If aResumo[nI,1] == cOpe 

		      nPos := Ascan( aResuAux, { |x| x[2] == aResumo[nI,2] } )
		      
		      If nPos <> 0 
	              If aResumo[nI,3] == cDescNota 
	                 aResuAux[nPos,3] += (aResumo[nI,4]+aResumo[nI,5]+aResumo[nI,6])
	              ElseIf aResumo[nI,3] <> cDescIten .and. aResumo[nI,3] <> cDescQtd
			     	 aResuAux[nPos,4] += (aResumo[nI,4]+aResumo[nI,5]+aResumo[nI,6])
			      EndIf	
		      Else
	              If aResumo[nI,3] == cDescNota 
					 AaDd(aResuAux,{aResumo[nI,1],aResumo[nI,2],(aResumo[nI,4]+aResumo[nI,5]+aResumo[nI,6]),0})	                 
	              ElseIf aResumo[nI,3] <> cDescIten .and. aResumo[nI,3] <> cDescQtd
			     	 AaDd(aResuAux,{aResumo[nI,1],aResumo[nI,2],0,(aResumo[nI,4]+aResumo[nI,5]+aResumo[nI,6])})
			      EndIf	
           	  EndIf
           	  
           EndIf
       Next
       aResumo := aClone(aResuAux)
	EndIf                                                        
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ordena por operadora empresa e descricao						   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aSort(aResumo,,, { |x, y| x[1] < y[1] .and. x[2] < y[2]})	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Impressao dos itens da matriz 									   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nTipo <> 3      
	    For nI := 1 To 3
	        do Case 
	           Case nI == 1
				    cDesAux := cDescNota
			   Case nI == 2	
				    cDesAux := cDescIten
			   Case nI == 3	
				    cDesAux := cDescQtd
			EndCase	
			nPos := Ascan( aResumo, { |x| x[1] == cOpe .and. x[2] == cEmp .and. x[3] == cDesAux } )
			@ ++nLi,nColuna      pSay aResumo[nPos,3]
			@   nLi,(nColuna+31) pSay TransForm(aResumo[nPos,4],pMoeda1)
			@   nLi,(nColuna+62) pSay TransForm(aResumo[nPos,5],pMoeda1)
			@   nLi,(nColuna+93) pSay TransForm(aResumo[nPos,6],pMoeda1)
		Next	
		++nLi												   
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Impressao dos Valores  da matriz								   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len(aResumo)       
		    If 	aResumo[nI,1] == cOpe .and. aResumo[nI,2] == cEmp .and.;
		        aResumo[nI,3] <> cDescNota .and. aResumo[nI,3] <> cDescIten	.and. aResumo[nI,3] <> cDescQtd
				@ ++nLi,nColuna 	 pSay aResumo[nI,3]
				@   nLi,(nColuna+31) pSay TransForm(aResumo[nI,4],pMoeda1)
				@   nLi,(nColuna+62) pSay TransForm(aResumo[nI,5],pMoeda1)
				@   nLi,(nColuna+93) pSay TransForm(aResumo[nI,6],pMoeda1)
				nVlrTCon  += aResumo[nI,4]
				nVlrTSer  += aResumo[nI,5]
				nVlrTHos  += aResumo[nI,6]            
			EndIf	
		Next	
		nVlrTEmp  += (nVlrTCon+nVlrTSer+nVlrTHos)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Impressao do Valor Total										   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ ++nLi,nColuna 	 pSay 'Valor Total'
		@   nLi,(nColuna+31) pSay TransForm(nVlrTCon,pMoeda1)
		@   nLi,(nColuna+62) pSay TransForm(nVlrTSer,pMoeda1)
		@   nLi,(nColuna+93) pSay TransForm(nVlrTHos,pMoeda1)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Impressao do Valor Total Geral									   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ ++nLi,nColuna 	 pSay Replicate('_',nLimite)
		@ ++nLi,nColuna 	 pSay cDesc
		@   nLi,(nColuna+31) pSay TransForm(nVlrTEmp,pMoeda1)
		@ ++nLi,nColuna 	 pSay Replicate('_',nLimite)              
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Se for para impressao de operadora retorna com a matriz			   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else 
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Impressao do Resumo Geral da Operadora							   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len(aResumo)       
		    If 	aResumo[nI,1] == cOpe  
		    
				@ ++nLi,1  pSay aResumo[nI,2]
				@   nLi,33 pSay aResumo[nI,3]
				@   nLi,66 pSay TransForm(aResumo[nI,4],pMoeda1)

				++nQtdTEmp
				nQtdTGer  += aResumo[nI,3]
				nVlrTGer  += aResumo[nI,4]
			EndIf	
		Next	         
		@ ++nLi,1  pSay Replicate('_',132)
		++nLi
		
		@ ++nLi,1  pSay 'Total Empresas :'+AllTrim( Str( nQtdTEmp ) )
		@   nLi,33 pSay 'Total Notas :'	 +AllTrim( Str( nQtdTGer ) )
		@   nLi,66 pSay 'Total Geral :'	 +TransForm(nVlrTGer,pMoeda1)

		@ ++nLi,1  pSay Replicate('_',132)
		
	EndIf	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Retorna com a matriz original no caso de Resumo Operadora ou Geral	 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aResumo := aClone(aResuOld)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ ChkResumo ³ Autor ³ Alexander Santos     ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Checa se pode incluir no resumo							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function ChkResumo(cOpe,cEmp,cTipGui,cDesc,nValor)      
    LOCAL nPos 	  := Ascan( aResumo, { |x| x[1] == cOpe .and. x[2] == cEmp .and. x[3] == cDesc } ) 
    LOCAL nVlrCon := 0
    LOCAL nVlrSer := 0
    LOCAL nVlrHos := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode somar se nao inclui								 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipGui == '01'
	   nVlrCon := nValor
	ElseIf cTipGui == '02'
	   nVlrSer := nValor
	ElseIf cTipGui == '03'
	   nVlrHos := nValor
	EndIf   
	   
	If nPos > 0
	   aResumo[nPos,4] += nVlrCon
	   aResumo[nPos,5] += nVlrSer
	   aResumo[nPos,6] += nVlrHos
	Else
	   AaDd(aResumo,{cOpe,cEmp,cDesc,nVlrCon,nVlrSer,nVlrHos})
	EndIf
Return                                                                       



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ RBDHCabec ³ Autor ³ Alexander Santos     ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Cabecalho                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function RBDHCabec(nTipo)      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))

If nTipo == 1
	@ ++nLi,1 pSay	"Local"				+Space(1)+;
					"Peg"				+Space(7)+;
				    "Guia"			    +Space(6)+;
				    "Nota"			    +Space(19)+;
				    "Cod. Beneficiario"	+Space(6)+;
				    "Nome"           	
	
	@ ++nLi,1  pSay	"Data"							+Space(5)+;    
    			    "Senha"					   		+Space(6)+;    
				    "Plano"							+Space(2)+;    
			        "Prestador"						+Space(2)+;    
					"P.Anes"		 				+Space(2)+;    
					"Descrição do Procedimento"		+Space(17)+;    
	                "Codigo Proced."	 			+Space(2)+;    	
					"Qtd. Proc."	   				+Space(2)+;    	
					"Vl. Cobraça"	

	@ ++nLi,0   pSay Replicate('_',132)
	
ElseIf nTipo == 2	

	nLi := nLi + 2
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cabecalho do Resumo												   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@   nLi,0   pSay Replicate('_',nLimite)
	
	@ ++nLi,1 	pSay 'Tipo de Nota'
	@   nLi,32  pSay 'Consulta'
	@   nLi,63  pSay 'Serviço'
	@   nLi,93  pSay 'Hospitalar'
	
	@ ++nLi,0 	pSay Replicate('_',nLimite)              
	
ElseIf nTipo == 3	

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cabecalho do Resumo	Geral										   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ ++nLi,1	pSay 'Empresa'
	@   nLi,33 	pSay 'Qtd. Notas'
	@   nLi,66 	pSay 'Valor Total'
	
EndIf	

nLi ++
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return                                                                       


Static Function BuscaCod(cCodPro,dData)
LOCAL __cCodPad := GETMV("MV_PLSTBPD")

BR8->(DbSetOrder(1))
BR8->(DbSeek(xFilial("BR8")+__cCodPad+cCodPro))

If BR8->BR8_TPPROC == "0"
   If nConverte == 1 .And. dtos(dData) >= dtos(dDataAP)
      BW0->(DbSetOrder(1))
      If BW0->(DbSeek(xFilial("BW0")+__cCodPad+cCodPro)) //alterar
   	     cCodPro := Subs(Alltrim(BW0->BW0_CODPR2),1,8)
      Else
         aadd(aCodProErro,{cCodPro+" nao encontrado no de/para"})
      Endif   
   Endif
Endif

Return(cCodPro)

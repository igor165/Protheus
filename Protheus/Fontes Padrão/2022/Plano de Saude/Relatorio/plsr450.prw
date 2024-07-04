#include "PROTHEUS.CH"
#include "PLSMGER.CH"

STATIC aCodProErro := {}
static objCENFUNLGP := CENFUNLGP():New() 
Static lAutoSt := .F.
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSR450  Ё Autor Ё Alexander Santos       Ё Data Ё 14.06.05 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao ЁEmite relatorio de faturamento de intercambio eventual      Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR450                                                    Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё			 Ё      Ё  			  Ё 						              Ё╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define nome da funcao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSR450(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
PRIVATE cTitulo     := FunDesc() //"Faturamento de IntercБmbio"      
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
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa ambiente do relatorio somente top...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! PLSRelTop()
   Return
Endif    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint (padrao)                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao (padrao)                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. nLastKey  == 27 
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os parametros...  Sai se o usuario clicar no X                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o numero do titulo correspondente no se1							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BTO->( DbSetOrder(1) ) //BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
BTO->( MsSeek( xFilial("BTO")+cCodIntOri+cNumeLote+cCodIntDes ) )
cNumTSe1 := BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora (padrao)                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	SetDefault(aReturn,cAlias) 
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTitulo += " - Competencia: "+cMesBase+"/"+cAnoBase
if !lAuto
	MsAguarde({|| RBDHImp() }, cTitulo, "Aguarde..", .T.)
else
	RBDHImp()
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё RBDHImp	 Ё Autor Ё Alexander Santos      Ё Data Ё 14.06.05 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime detalhe do relatorio...                            Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function RBDHImp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
PRIVATE cDescIten := 'Itens ServiГos'             
PRIVATE cDescQtd  := 'Qtds  ServiГos'
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	MsProcTxt(PLSTR0001) 
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Faz filtro no arquivo...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	   MsgInfo('NЦo existem registros para os parametros informados !')
   endif
   BDHTRB->(DbCloseArea())
   Return
EndIf
BDHTRB->( DbGotop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega a Data da Emissao da CobranГa no cabecalho do lote					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nStatusFA == 1 //A Faturar
   cDatCob := 'Em Aberto'
Else
   BDC->( DbSetOrder(1) )
   BDC->( MsSeek( xFilial('BDC')+BDHTRB->BDH_NUMFAT ) )
   cDatCob := DtoC(BDC->BDC_DATGER)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta order para o bea													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(12) ) //BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da impressao dos detalhes...                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !BDHTRB->(Eof())
 	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Exibe mensagem...                                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      if !lAutoSt
		  MsProcTXT("Imprimindo "+BDHTRB->BD6_MATANT+"...")
      endif
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Verifica se foi abortada a impressao...                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      EndIf      
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Inicio da Impressao												 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If cTipGui <> BDHTRB->BD6_TIPGUI .or. cCodNum <> BDHTRB->BD6_NUMERO .or.;                         
	     cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI .or.;
	     cCodPeg <> BDHTRB->BD6_CODPEG 
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Limpa o tipo de servico											 Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 	  	  cCodSer := ''
 	  	  cCodSeq := ''
          If !Empty(cCodNum) .and. (cCodNum <> BDHTRB->BD6_NUMERO .or. cTipGui <> BDHTRB->BD6_TIPGUI .or. cCodPeg <> BDHTRB->BD6_CODPEG ) 
			 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			 //Ё Imprime Total Adm e Fat. Moderador								    Ё
			 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             ImpTotAdm(nVlrTad,nVlrTpf)
 			 cCodNum := BDHTRB->BD6_NUMERO		 	  
 			 cCodPeg := BDHTRB->BD6_CODPEG
          	 nVlrTad := 0
	  		 nVlrTpf := 0 
	      EndIf                           
		  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		  //Ё Monta cabecalho...                                                       Ё
		  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		  If cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI
		 	  cOpeOri := BDHTRB->BDH_OPEORI 
		 	  BA0->( DbSetOrder(1) ) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		 	  If BA0->( MsSeek( xFilial("BA0")+cOpeOri ) )                         
			 	 cDesOpe := BA0->BA0_NOMINT
			  EndIf
		 	  cEmpOri := BDHTRB->BDH_EMPORI 
			  cCabec1 := "Unimed Cobr:"+cOpeOri+' - '+cDesOpe+Space(2)+"Empresa:"+cEmpOri+Space(2)+" Dt. EmissЦo CobranГa: "+cDatCob
 			  nLi 	  := 1
		  EndIf				 
		  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		  //Ё Imprime cabecalho...                                                     Ё
		  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	      If nLi > nQtdLin .or. nLi == 1
    	     RBDHCabec(1)
	      Endif                  
 	  	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Imprime Guia														 Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  		  If cTipGui <> BDHTRB->BD6_TIPGUI
		 	  cTipGui := BDHTRB->BD6_TIPGUI 
 			  cCodNum := BDHTRB->BD6_NUMERO		 	  
 			  cCodPeg := BDHTRB->BD6_CODPEG
	  		  @ ++nLi,nColuna pSay Iif(cTipGui == '01','Consulta',Iif(cTipGui == '02','ServiГo','Hospitalar'))
	  		  @ ++nLi,nColuna pSay Replicate('_',15)
	  	  EndIf	  
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	  //Ё Descricao do Usuario										 	 Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          If  len(alltrim(BDHTRB->BD6_MATANT)) == 17
              cMat := TransForm(BDHTRB->BD6_MATANT,"@R !!!!.!!!!.!!!!!!.!!-!")
          Else
              cMat := TransForm(BDHTRB->BD6_MATANT,"@R !!!.!!!!.!!!!!!.!!-!") + space(1)
          Endif
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Verifica o tipo de Guia para pegar a senha							   Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Verifica se tem porte aneste.											   Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	      If BDHTRB->BD7_CODUNM == 'PA'
		      BD4->(DbSetOrder(1))// BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODIGO + DTOS(BD4_VIGINI)
		      If BD4->( MsSeek( xFilial("BD4")+BDHTRB->CHAVEBD4 ) )
		         cVlrPAne := Str( Floor( BD4->BD4_VALREF ) )
		      EndIf    
	      EndIf                               
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Pega o numero da autorizacao											   Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	      cNumNot := BDHTRB->BD6_NUMIMP
	      If Empty(cNumNot)
		     BEA->( MsSeek( xFilial("BEA")+BDHTRB->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) ) )
		     cNumNot := AllTrim(BEA->BEA_NUMAUT)+Space(16-Len(AllTrim(BEA->BEA_NUMAUT)))
		  EndIf    
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	  //Ё Imprime														 Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Imprime BD6...                                                  	 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
		  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		  //Ё Para resumo de Itens													   Ё
		  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescIten,1)	     
		  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		  //Ё Para resumo de Qtd de Itens											   Ё
		  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescQtd,BDHTRB->BD6_QTDPRO)
	  EndIf                                        
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Imprime BD7...                                                  	 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cCodPro := BDHTRB->BD7_CODUNM
      @ ++nLi,(nColuna+88)  pSay BDHTRB->BD7_CODUNM+Space(Abs(Len(BDHTRB->BD7_CODUNM)-28))+;
				 			     TransForm(BDHTRB->(BD7_VLRTPF-BD7_VLRTAD),pMoeda)         
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Para resumo de Composicao do procedimento								   Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,BDHTRB->BD7_CODUNM,BDHTRB->(BD7_VLRTPF-BD7_VLRTAD))      
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Totais															 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  nVlrTad += BDHTRB->BD7_VLRTAD                   
	  nVlrTpf += BDHTRB->(BD7_VLRTPF-BD7_VLRTAD)
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro...                                         Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BDHTRB->(DbSkip())
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё verifica proxima pagina...                                         Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nLi > nQtdLin
          RBDHCabec(1) 
      Endif                  
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Se mudou de empresa e ou operadora								 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !BDHTRB->( Eof() ) .and. (cOpeOri <> BDHTRB->BDH_OPEORI .or. cEmpOri <> BDHTRB->BDH_EMPORI) 
	      If Len(aResumo) > 0              
		     ImpTotAdm(nVlrTad,nVlrTpf)
			 nVlrTad := 0
			 nVlrTpf := 0  
   	         cCodNum := ''
   	         cTipGui := ''                 
   	         cCodPeg := ''
			 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		     //Ё Cabecalho e Resumo Empresa											Ё
		     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			 RBDHCabec(2) 
			 ImpResumo(1,cOpeOri,cEmpOri)                            
			 If cOpeOri <> BDHTRB->BDH_OPEORI
				 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			     //Ё Cabecalho e Resumo Operadora										Ё
			     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				 RBDHCabec(2)
				 ImpResumo(2,cOpeOri,cEmpOri)                            
			 EndIf
		  EndIf
	  EndIf
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Total Adm e Fat. Moderador								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ImpTotAdM(nVlrTad,nVlrTpf)
nVlrTad := 0
nVlrTpf := 0  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cabecalho e Resumo Empresa	  									   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RBDHCabec(2)
ImpResumo(1,cOpeOri,cEmpOri)                            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cabecalho e Resumo Operadora 									   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCabec1 := "Unimed Cobr:"+cOpeOri+' - '+cDesOpe+Space(2)+" Dt. EmissЦo CobranГa: "+cDatCob
RBDHCabec(2)
ImpResumo(2,cOpeOri,cEmpOri)                            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cabecalho e Resumo Geral do Relatorio							   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RBDHCabec(3)
ImpResumo(3,cOpeOri,cEmpOri)                            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime rodape do relatorio...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	Roda(0,space(10),cTamanho)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BDHTRB->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. Len(aCodProErro) > 0
   PLSCRIGEN(aCodProErro,{ {"Critica","@C",200} },"Criticas")
Endif


If !lAutoSt .AND. aReturn[5] == 1 
   Set Printer To
   Ourspool(cRel)
End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
                        
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё ImpToTAdm Ё Autor Ё Alexander Santos     Ё Data Ё 14.06.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime Total Administracao e Fator Moderador			   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function ImpTotAdm(nVlrTad,nVlrTpf)      
      LOCAL cDescText
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Imprime valor Administracao/Fator Moderador						 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cDescText := IiF(BDHTRB->BD6_TPPF == '1','F.Moderador   ','Taxa Administ ')	      
	  @ ++nLi,89  pSay cDescText				+Space(Abs(Len(cDescText)-16))+Space(12)+;
	  				   TransForm(nVlrTad,pMoeda)
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Resumo de Taxas													 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescText,nVlrTad)      
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Resumo de Notas													 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  ChkResumo(cOpeOri,cEmpOri,cTipGui,cDescNota,1)      
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Imprime Total da Guia												 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  @ ++nLi,89 pSay 'Total Nota'+Space(14)+;
	 				  			   TransForm((nVlrTpf+nVlrTad),pMoeda1)
Return	


/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё ImpResumo Ё Autor Ё Alexander Santos     Ё Data Ё 14.06.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime Resumo											   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function ImpResumo(nTipo,cOpe,cEmp)      
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Declaracao de Variaveis											   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды             
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
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Monta matriz para impressao do resumo da Operadora				   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Ordena por operadora empresa e descricao						   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aSort(aResumo,,, { |x, y| x[1] < y[1] .and. x[2] < y[2]})	
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Impressao dos itens da matriz 									   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Impressao dos Valores  da matriz								   Ё
	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Impressao do Valor Total										   Ё
	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		@ ++nLi,nColuna 	 pSay 'Valor Total'
		@   nLi,(nColuna+31) pSay TransForm(nVlrTCon,pMoeda1)
		@   nLi,(nColuna+62) pSay TransForm(nVlrTSer,pMoeda1)
		@   nLi,(nColuna+93) pSay TransForm(nVlrTHos,pMoeda1)
	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Impressao do Valor Total Geral									   Ё
	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		@ ++nLi,nColuna 	 pSay Replicate('_',nLimite)
		@ ++nLi,nColuna 	 pSay cDesc
		@   nLi,(nColuna+31) pSay TransForm(nVlrTEmp,pMoeda1)
		@ ++nLi,nColuna 	 pSay Replicate('_',nLimite)              
	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Se for para impressao de operadora retorna com a matriz			   Ё
	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Else 
    	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Impressao do Resumo Geral da Operadora							   Ё
	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Retorna com a matriz original no caso de Resumo Operadora ou Geral	 Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aResumo := aClone(aResuOld)

Return


/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё ChkResumo Ё Autor Ё Alexander Santos     Ё Data Ё 14.06.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Checa se pode incluir no resumo							   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function ChkResumo(cOpe,cEmp,cTipGui,cDesc,nValor)      
    LOCAL nPos 	  := Ascan( aResumo, { |x| x[1] == cOpe .and. x[2] == cEmp .and. x[3] == cDesc } ) 
    LOCAL nVlrCon := 0
    LOCAL nVlrSer := 0
    LOCAL nVlrHos := 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se pode somar se nao inclui								 	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё RBDHCabec Ё Autor Ё Alexander Santos     Ё Data Ё 14.06.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime Cabecalho                                          Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function RBDHCabec(nTipo)      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
					"DescriГЦo do Procedimento"		+Space(17)+;    
	                "Codigo Proced."	 			+Space(2)+;    	
					"Qtd. Proc."	   				+Space(2)+;    	
					"Vl. CobraГa"	

	@ ++nLi,0   pSay Replicate('_',132)
	
ElseIf nTipo == 2	

	nLi := nLi + 2
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Cabecalho do Resumo												   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@   nLi,0   pSay Replicate('_',nLimite)
	
	@ ++nLi,1 	pSay 'Tipo de Nota'
	@   nLi,32  pSay 'Consulta'
	@   nLi,63  pSay 'ServiГo'
	@   nLi,93  pSay 'Hospitalar'
	
	@ ++nLi,0 	pSay Replicate('_',nLimite)              
	
ElseIf nTipo == 3	

    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Cabecalho do Resumo	Geral										   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ ++nLi,1	pSay 'Empresa'
	@   nLi,33 	pSay 'Qtd. Notas'
	@   nLi,66 	pSay 'Valor Total'
	
EndIf	

nLi ++
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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

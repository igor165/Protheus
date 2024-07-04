
#Include "PLSMGER.CH"
#include "PROTHEUS.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR511 Ё Autor Ё Tulio Cesar            Ё Data Ё 14.05.04 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Relatorio de empresas reajustadas                          Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR511()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define nome da funcao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSR511(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Default lAuto := .F.

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR511"
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := FunDesc() //"Empresas Reajustadas"
PRIVATE cDesc1      := FunDesc() //"Empresas Reajustadas"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BHW"
PRIVATE cPerg       := "PLR511"
PRIVATE cRel        := "PLSR511"
PRIVATE nLi         := 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

lAutoSt := lAuto
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
	SetDefault(aReturn,cAlias)
endif

aAlias := {"BA0", "BPE", "BG9", "BPF", "BYC", "BI3", "BG9", "BQC", "AAD", "BT6", "BYF", "BHL", "BK2", "BA1", "BFQ"}
objCENFUNLGP:setAlias(aAlias)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
	Processa({|| R511Imp() }, cTitulo, "", .T.)
else
	R511Imp()
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R511Imp  Ё Autor Ё Tulio Cesar           Ё Data Ё 24.05.01 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Relatorio de Empresas reajustadas...                       Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/
Static Function R511Imp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cCodOpe
LOCAL cMes
LOCAL cAno
LOCAL cGrupoDe
LOCAL cGrupoAte
LOCAL cContDe,nCnt
LOCAL cContAte
LOCAL cSubDe
LOCAL cSubAte
LOCAL cSQL                        
LOCAL cPerg      := "PLR511"
LOCAL aSubCon    := {}                          
LOCAL aDados     := {}
LOCAL aDadOpc	 := {}
LOCAL nFor  
LOCAL nAux
LOCAL nInd,nVlr
LOCAL cLinha
LOCAL cLinPad
LOCAL aFamilias  := {}
LOCAL nVlrAnt 	 := 0
LOCAL nPerRea 	 := 0
LOCAL nVlrRea 	 := 0
LOCAL aCampos	 := {}
LOCAL nCpo
Local lAchou     := .F.
     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca dados de parametros...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)

cCodOpe   := mv_par01
cMes      := mv_par02
cAno      := mv_par03
cGrupoDe  := mv_par04
cGrupoAte := mv_par05
cContDe   := mv_par06
cContAte  := mv_par07
cSubDe    := mv_par08
cSubAte   := mv_par09
cMatDe	  := mv_par10
cMatAte	  := mv_par11
cTipoUs	  := mv_par12
nVencDe	  := mv_par13
nVencAte  := mv_par14
nImpOpc	  := mv_par15

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega campos especificos de usuario para impressao no relatorio.       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                      
aCampos := PlsUserCpo()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca no BD todos os reajustes do ano/mes informado...                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName("BHW")+" WHERE "
cSQL += "BHW_FILIAL = '"+xFilial("BHW")+"' AND "
cSQL += "BHW_ANOMES = '"+cAno+cMes+"' AND "
If cTipoUs <> 3
	cSql += "(BHW_TIPOUS = '"+Alltrim(Str(cTipoUs))+"' OR BHW_TIPOUS = '3') AND "
Endif
cSQL += "D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"PLS511")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existem registros....                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLS511->(Eof())
   PLS511->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia a leitura de todos os reajustes do mes...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! PLS511->(Eof())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
	//Ё Posiciona no BHW...                                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BHW->(DbGoTo(PLS511->REG))
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
    //Ё Inicio da leitura de todos os grupos empresas...                         Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BPD->(DbSetOrder(1))
    If BPD->(DbSeek(xFilial("BPD")+BHW->(BHW_CODINT+BHW_CODREA)))
    	While ! BPD->(Eof()) .And. BPD->(BPD_FILIAL+BPD_OPEREA+BPD_CODREA) == xFilial("BPD")+BHW->(BHW_CODINT+BHW_CODREA)
        	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
	        //Ё Bypassa de acordo com o filtro...                                        Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If ! ( BPD->BPD_CODEMP >= cGrupoDe .And. BPD->BPD_CODEMP <= cGrupoAte )
            	BPD->(DbSkip())
           		Loop
            Endif   
            
        	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
	        //Ё Trata filtro de pessoa fisica / juridica...                              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If cTipoUs <> 3 .and. BPD->BPD_TIPO # Alltrim(Str(cTipoUs))
            	BPD->(DbSkip())
           		Loop
            Endif   
            	
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
            //Ё Para cada grupo empresa le contratos e subcontratos (PJ)...              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPD->BPD_TIPO == "2"
        	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
    	        //Ё Arvore para cada contrato...                                             Ё
	            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            	BPE->(DbSetOrder(1))
             	If BPE->(DbSeek(xFilial("BPE")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_CODEMP)))
	            	While ! BPE->(Eof()) .And. BPE->(BPE_FILIAL+BPE_OPEREA+BPE_CODREA+BPE_CODEMP) ==;
                                                xFilial("BPE")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_CODEMP)
                       	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Bypassa de acordo com o filtro...                                        Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                       	If ! ( BPE->BPE_CONEMP >= cContDe .And. BPE->BPE_CONEMP <= cContAte )
                           	BPE->(DbSkip())
                           	Loop
                       	Endif   
                       	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Arvore para cada subcontrato...                                          Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                       	BPF->(DbSetOrder(1))
                       	If BPF->(DbSeek(xFilial("BPF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)))
                          	While ! BPF->(Eof()) .And. BPF->(BPF_FILIAL+BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON) == ;
                               	                          xFilial("BPF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)
                           		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                                //Ё Bypassa de acordo com o filtro...                                        Ё
                             	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                                If ! ( BPF->BPF_SUBCON >= cSubDe .And. BPF->BPF_SUBCON <= cSubAte )
                                  	BPF->(DbSkip())
                                   	Loop
                                Endif   
                                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                                //Ё Arvore para subcontrato x produto x valores...                           Ё
                                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                                BYC->(DbSetOrder(2))
                                If BYC->(DbSeek(xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
	                               	While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA+BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB) == ;
                                       	                           xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)
                                      
    	                           		BQC->(DbSetOrder(1))
                                        BQC->(DbSeek(xFilial("BQC")+BPE->(BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
                                              
                                      	BT6->(DbSetOrder(1))
                                       	BT6->(DbSeek(xFilial("BT6")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)))
                                             
                                        BG9->(DbSetOrder(1))
                                        BG9->(DbSeek(xFilial("BG9")+BQC->(BQC_CODINT+BQC_CODEMP)))
                                              
                                        BI3->(DbSetOrder(1))
                                        If BI3->(DbSeek(xFilial("BI3")+BYC->(BYC_CODOPE+BYC_CODPRO+BYC_VERPRO)))
        	                              	cQuebPro := BYC->(BYC_CODPRO+BYC_VERPRO)
                                                 
                                            aadd(aSubCon,{objCENFUNLGP:verCamNPR("BPF_SUBCON", BPF->BPF_SUBCON)+"-"+objCENFUNLGP:verCamNPR("BPF_VERSUB", BPF->BPF_VERSUB),;
                                                              Subs(BQC->BQC_DESCRI,1,17),;
                                                              Subs(BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI),1,20),;
                                                              Subs(Posicione("AAD",1,xFilial("AAD")+BYC->BYC_INDREA,"AAD_DESCRI"),1,10),;
                                                              BYC->BYC_PERREA,;
                                                              If(AllTrim(BT6->BT6_MODPAG)=="1","PP ","CO "),;
                                                              {},;
                                                              BPE->BPE_CODEMP,;
                                                              BPE->BPE_CONEMP,;
                                                              BPF->BPF_SUBCON,;
                                                              BPF->BPF_VERSUB,;
                                                              BG9->BG9_DESCRI,;
                                                              BPF->BPF_NFAM,;
                                                              {},;
                                                              BQC->( Recno() )})
                                            lFlag := .T.

                                            While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA+BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB+BYC_CODPRO+BYC_VERPRO) == ;
                                                                            xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro
                                               	aadd(aDados,{If(lFlag,"Mensalidade",Space(11)),Str(BYC->BYC_IDAINI,3),Str(BYC->BYC_IDAFIN,3),Str(BYC->BYC_VLRANT,13,2),Str(BYC->BYC_VLRREA,13,2)})
                                               	lFlag := .F.
	                                            BYC->(DbSkip())
											Enddo  
			
			                                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
            			                    //Ё Arvore para subcontrato x produto x adesoes...                           Ё
                        			        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                                    		BYE->(DbSetOrder(3))
			                                If BYE->(DbSeek(xFilial("BYE")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+;
			                                   										BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB+cQuebPro))))

												lFlag := .T.    
        		                                While ! BYE->(Eof()) .And. BYE->(BYE_FILIAL+BYE_OPEREA+BYE_CODREA+BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB+BYE_CODPRO+BYE_VERPRO) == ;
                	                                                     xFilial("BYE")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro
                            			            aadd(aDados,{If(lFlag,"Adesao     ",Space(11)),Str(BYE->BYE_IDAINI,3),Str(BYE->BYE_IDAFIN,3),Str(BYE->BYE_VLRANT,13,2),Str(BYE->BYE_VLRREA,13,2)})
                    		                        BYE->(DbSkip())
		                                        Enddo  
		          							Endif
		                                     	
			                                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
            			                    //Ё Arvore para subcontrato x produto x opcionais x valores...               Ё
                        			        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                                    		BYF->(DbSetOrder(3))//BYF_FILIAL + BYF_CODOPE + BYF_CODEMP + BYF_CONEMP + BYF_VERCON + BYF_SUBCON + BYF_VERSUB + BYF_CODPRO + BYF_VERPRO + BYF_CODOPC + BYF_VEROPC
   			                                If BYF->(DbSeek(xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB+cQuebPro))))
			                                    									  
            			                       	While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+;
            			                       									  BYF_VERCON+BYF_SUBCON+BYF_VERSUB+BYF_CODPRO+BYF_VERPRO) == ;
                       			               		                           xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+;
	                        			                                       BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro
                                    		      
			                                       	BI3->(DbSetOrder(1))
            			                           	If BI3->(DbSeek(xFilial("BI3")+BYF->(BYF_CODOPE+BYF_CODOPC+BYF_VEROPC)))
                        			               		cQuebOpc := BYF->(BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC)
                                                 
	                                    	            lFlag := .T. 
    			                                        While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB+BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC) == ;
                			                                                         xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebOpc
			                                       			aadd(aDadOpc,{If(lFlag,"Opc. "+Subs(objCENFUNLGP:verCamNPR("BI3_DESCRI", AllTrim(BI3->BI3_DESCRI)),1,6),Space(11)),Str(BYF->BYF_IDAINI,3),Str(BYF->BYF_IDAFIN,3),Str(BYF->BYF_VLRANT,13,2),Str(BYF->BYF_VLRREA,13,2)})
            			                               		lFlag := .F.
                        				                    BYF->(DbSkip())
                                        		        Enddo  
			                                   		Endif   
				                                Enddo
											Endif
           								Endif   
										If Len(aSubCon) > 0
				                           	aSubCon[Len(aSubCon),07] := aClone(aDados)                            	
				                           	aSubCon[Len(aSubCon),14] := aClone(aDadOpc)
				                        Endif   
				 						aDados	:= {}
				 						aDadOpc	:= {}
           							Enddo
               					Endif                                               
	                            BPF->(DbSkip())
                    		Enddo
                      	Endif                               
                     	BPE->(DbSkip())
                    Enddo
           		Endif
			Elseif BPD->BPD_TIPO == "1"
	            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
    	        //Ё Para cada grupo empresa le as familias... (PJ)                           Ё
        	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        	    BHL->( dbSetorder(01) )
        	    If BHL->( dbSeek(xFilial("BHL")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_OPEREA+BPD_CODEMP)))
	            	While ! BHL->(Eof()) .And. BHL->(BHL_FILIAL+BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP) ==;
		                                        xFilial("BPE")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_OPEREA+BPD_CODEMP)
                                                
			         	If !lAutoSt
							IncProc("Processando "+BHL->(BHL_CODOPE+'.'+BHL_CODEMP+'.'+BHL_MATRIC))
							ProcessMessage()
						endif

              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Bypassa de acordo com o filtro de empresas...                            Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                       	If ! ( BHL->BHL_CONEMP >= cContDe .And. BHL->BHL_CONEMP <= cContAte )
                           	BHL->(DbSkip())
                           	Loop                 
                       	Endif 
                       	
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Bypassa de acordo com o filtro de familias...                            Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                       	If ! ( BHL->BHL_MATRIC >= cMatDe .And. BHL->BHL_MATRIC <= cMatAte )
                           	BHL->(DbSkip())
                           	Loop
                       	Endif 
            			
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Posiciona familia...                                                     Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    					BA3->( dbSetorder(01) )
    					BA3->( dbSeek(xFilial("BA3")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)) )
    					
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Filtra por vencimento...                                                 Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If !( BA3->BA3_VENCTO >= nVencDe .and. BA3->BA3_VENCTO <= nVencAte)
  							BHL->( dbSkip() )
  							Loop
  						Endif							
    					
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Pocisiona o produto...                                                   Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    					BI3->( dbSetorder(01) )
    					BI3->( dbSeek(xFilial("BA3")+BA3->BA3_CODPLA+BA3->BA3_VERSAO) )
    					
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Obtem o valor de cobranca da familia...                                  Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    					aVlrFam := PLSVLRFAM(BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC),cAno,cMes)
		
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Valida valor de cobranca...                                              Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  						If Len(aVlrFam[1, 2]) == 0 .or. !aVlrFam[1, 1]
  							BHL->( dbSkip() )
  							Loop
  						Endif

              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Simplifica a matriz de valores...                                        Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
						aVlrFam := aClone(aVlrFam[1][2])
						
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Adiciona a Familia na matriz nucleo...                                   Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                       	If Len(aFamilias) == 0 .or. (nPos := Ascan(aFamilias, {|x| x[1] == BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)}) ) == 0
							Aadd( aFamilias, {BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC), {}} )
							nPos := Len(aFamilias)
						Endif
						
              			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
                       	//Ё Processa os usuarios da familia...                                       Ё
                       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  						For nCnt := 1 To Len(aVlrFam)
  							If aVlrFam[nCnt][3] $ '101,102'
  							    lAchou:=.F.
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
    	    	               	//Ё Primeiro procura por reajuste da faixa especifica do usuario...          Ё
        	        	       	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYB->(DbSetOrder(1))
								If BYB->(DbSeek(xFilial("BYB")+Substr(aVlrFam[nCnt][07],1,16)+BHL->(BHL_OPEREA+BHL_CODREA)+aVlrFam[nCnt][13]))
									If BYB->BYB_VLRANT <> 0 .Or.  BYB->BYB_VLRREA <> 0 
										nVlrAnt := BYB->BYB_VLRANT
 								   		nPerRea := BYB->BYB_PERREA
 								   		nVlrRea := BYB->BYB_VLRREA
								    	lAchou:=.T.
								    Endif
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©                                    
    		    	            //Ё Depois profura por reajuste na familia...                                Ё
	        	        	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	        	        	    If !lAchou
	        	        	       	BDK->( dbSetorder(01) )
	        	        	       	If !BDK->( dbSeek(xFilial("BDK")+Substr(aVlrFam[nCnt][07],1,16)) )
										BP7->(DbSetOrder(1))
									    If !BP7->(DbSeek(xFilial("BP7")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC+;
									                                           BHL_OPEREA+BHL_CODREA+aVlrFam[nCnt][13])))
											Loop
										Else
											nVlrAnt := BP7->BP7_VLRANT
  										   	nPerRea := BP7->BP7_PERREA
  										   	nVlrRea := BP7->BP7_VLRREA
										Endif
									Else
										Loop
									Endif
								Endif
								  								
  								BA1->( dbSetorder(02) )
  								If !BA1->( dbSeek(xFilial("BA1")+aVlrFam[nCnt][07]) )
  									Loop
  								Endif
  								
				  				aLog := PL169HIST(.T.)
				  				
  								Aadd(aFamilias[nPos][2], {aVlrFam[nCnt][07],;
					   			   aVlrFam[nCnt][08],;
								   BA1->BA1_DATNAS,;
								   BA1->BA1_DATINC,;
								   aVlrFam[nCnt][04],;
								   aVlrFam[nCnt][05],;
  								   Posicione("BA1",2,xFilial("BA1")+aVlrFam[nCnt][07],"BA1_DATINC"),;
  								   nVlrAnt,;     
  								   objCENFUNLGP:verCamNPR("BHL_MESREA", BHL->BHL_MESREA)+"/"+Alltrim(objCENFUNLGP:verCamNPR("BHL_ANOREA", Str(Val(BHL->BHL_ANOREA)+1))),;			// Proximo reajuste
  								   nPerRea,;
  								   nVlrRea,;
  								   Iif(aVlrFam[nCnt][3]=='101','M','O')})
  															   
  							Endif							   
						Next
                    	BHL->( dbSkip() )
        			Enddo
        		Endif
			Endif    
         	BPD->(DbSkip())
   		Enddo
	Endif
	PLS511->(DbSkip())
Enddo
PLS511->(DbCloseArea())

If Len(aSubCon) > 0

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Lista o relatorio...                                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nLi := Cabec(cTitulo,cCabec1,cCabec2)

	cLinha := "Operadora: "+cCodOpe+" - "+objCENFUNLGP:verCamNPR("BA0_NOMINT", Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"))
	@ nLi++,0 pSay cLinha

	For nFor := 1 To Len(aSubCon)

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona o subcontrato...                                               Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BQC->( dbGoto(aSubCon[nFor][15]) )
		
		cLinha := "Empresa: "+objCENFUNLGP:verCamNPR("BPE_CODEMP", aSubCon[nFor,8])+" - "+objCENFUNLGP:verCamNPR("BG9_DESCRI", aSubCon[nFor,12])
		@ nLi++,0 pSay cLinha
		nLi ++
		
		cLinha := "Contrato: "+objCENFUNLGP:verCamNPR("BPE_CONEMP", aSubCon[nFor,9])
		@ nLi++,0 pSay cLinha
		nLi ++
		
		cLinha := "Subcontrato  			           Produto                          Indice (%)    Tipo Lancamento  Faixa Etaria Vlr.Antigo Vlr. Atual"
		@ nLi++,0 pSay cLinha
		nLi ++
		lFlag := .F.
		
		For nAux := nFor To Len(aSubCon)
			
			If (aSubCon[nAux,8]+aSubCon[nAux,9] <> ;
				aSubCon[nFor,8]+aSubCon[nFor,9])
				nFor := nAux
				lFlag := .F.
				nLI ++
				@ nLi++,0 pSay Str(objCENFUNLGP:verCamNPR("BPF_NFAM", aSubCon[nAux-1,13]),6)+" Familia(s"
				Exit
			Endif
			
			If (aSubCon[nAux,3] # aSubCon[nFor,3])
				Loop
			Endif
			
			cLinPad :=aSubCon[nAux,1]+space(01)+;
			objCENFUNLGP:verCamNPR("BQC_DESCRI", aSubCon[nAux,2])+space(01)+;
			aSubCon[nAux,3]+space(01)+;
			objCENFUNLGP:verCamNPR("AAD_DESCRI", aSubCon[nAux,4])+space(01)+;
			objCENFUNLGP:verCamNPR("BYC_PERREA", TransForm(aSubCon[nAux,5],"@E 999.99"))+space(09)+;
			objCENFUNLGP:verCamNPR("BT6_MODPAG", aSubCon[nAux,6])+space(01)
			
			// imprime os opcionais.
			For nInd := 1 To Len(aSubCon[nAux,7])
				If ! lFlag
					cLinha := cLinPad
					lFlag := .T.
				Else
					cLinha := Space(Len(cLinPad))
				Endif
				cLinha += Space(01)+aSubCon[nAux,7,nInd,1]+Space(01)+;
				objCENFUNLGP:verCamNPR("BYC_IDAINI", aSubCon[nAux,7,nInd,2])+Space(01)+;
				objCENFUNLGP:verCamNPR("BYC_IDAFIN", aSubCon[nAux,7,nInd,3])+Space(01)+;
				objCENFUNLGP:verCamNPR("BYC_VLRANT", aSubCon[nAux,7,nInd,4])+;
				objCENFUNLGP:verCamNPR("BYC_VLRREA", aSubCon[nAux,7,nInd,5])
				@ nLi ++, 0 pSay cLinha
			Next
			
			// imprime os opcionais.
			For nInd := 1 To Len(aSubCon[nAux,14])
				If ! lFlag
					cLinha := cLinPad
					lFlag := .T.
				Else
					cLinha := Space(Len(cLinPad))
				Endif
				cLinha += Space(01)+aSubCon[nAux,14,nInd,1]+Space(01)+;
				objCENFUNLGP:verCamNPR("BYF_IDAINI", aSubCon[nAux,14,nInd,2])+Space(01)+;
				objCENFUNLGP:verCamNPR("BYF_IDAFIN", aSubCon[nAux,14,nInd,3])+Space(01)+;
				objCENFUNLGP:verCamNPR("BYF_VLRANT", aSubCon[nAux,14,nInd,4])+;
				objCENFUNLGP:verCamNPR("BYF_VLRREA", aSubCon[nAux,14,nInd,5])
				@ nLi ++, 0 pSay cLinha
			Next
			         
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Imprime lista de campos especificos...                                   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nCpo := 1 To Len(aCampos)
				If BQC->( FieldPos(aCampos[nCpo][2]) ) > 0
					@ nLi ++, 0 pSay aCampos[nCpo][1]+": "+objCENFUNLGP:verCamNPR(aCampos[nCpo][2], BQC->( &(aCampos[nCpo][2]) ))
				
					If nLi >  nQtdLin 
						nli := Cabec(cTitulo,cCabec1,cCabec2)
					Endif
				Endif
			Next
			
			If nLi > nQtdLin 
				nli := Cabec(cTitulo,cCabec1,cCabec2)
			Endif	

			Exit
		Next
		cLinha := ""
		@ nLi ++, 0 pSay cLinha
		
	Next
Endif

If Len(aFamilias) > 0    
	cCabec1 := "Cod. Beneficiario     Nome                                 Dt.Nasc. Dt.In.Ope Pl  Dt.In.Pl. V.Bas.Reaj Prox.Ren  %Renov  Vl.Atual  T"
        
	nLi := 80
	For nFor := 1 To Len(aFamilias)
	         
		If nLi > nQtdLin
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Lista o relatorio...                                                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nli := Cabec(cTitulo,cCabec1,cCabec2)
		Endif
		
		cCodOpe := Substr(aFamilias[nFor][1], atCodOpe[1], atCodOpe[2])
		cCodEmp := Substr(aFamilias[nFor][1], atCodEmp[1], atCodEmp[2])
		cLinha := "Empresa: "+cCodEmp+" - "+objCENFUNLGP:verCamNPR("BG9_DESCRI", Posicione("BG9", 1, xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI"))
		nLi += 1
		@ nLi,00 pSay cLinha
		
		nLi += 2

		For nAux := nFor To Len(aFamilias)
		
			If 	Substr(aFamilias[nFor][1], atCodOpe[1], atCodOpe[2])+;
				Substr(aFamilias[nFor][1], atCodEmp[1], atCodEmp[2]) <> cCodOpe + cCodEmp .or. nLi > 55
				
				nFor := nAux
				lFlag := .F.
				Exit
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Simplifica matriz...                                                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
			aVlrAux := aClone(aFamilias[nAux][2])
			

			For nVlr := 1 To Len(aVlrAux)
				cCodOpe := Substr(aVlrAux[nVlr][1], 1, 4)
				cCodEmp := Substr(aVlrAux[nVlr][1], 5, 4)
				cMatric := objCENFUNLGP:verCamNPR("BK2_MATRIC", Substr(aVlrAux[nVlr][1], 9, 6))
				cDigito := Substr(aVlrAux[nVlr][1], 15, 3)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Testa se eh para imprimir os opcionais...                                Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				If aVlrAux[nVlr][12] == 'O' .and. nImpOpc <> 1
					Loop
				Endif
				
				If nVlr == 1
					cLinha := Transform(cCodOpe+cCodEmp+cMatric+cDigito, __cPictUsr)+Space(02)+;
							  Substr(objCENFUNLGP:verCamNPR("BA1_NOMUSR", aVlrAux[nVlr][2]),01,35)+Space(02)+;
							  objCENFUNLGP:verCamNPR("BA1_DATNAS", dToc(aVlrAux[nVlr][3]))+Space(01)+;
							  objCENFUNLGP:verCamNPR("BA1_DATINC", dToc(aVlrAux[nVlr][4]))+Space(01)+;
							  objCENFUNLGP:verCamNPR("BFQ_DESCRI", aVlrAux[nVlr][05])+Space(01)+;
							  objCENFUNLGP:verCamNPR("BA1_DATINC", dToc(aVlrAux[nVlr][7]))+Space(04)+;
							  Transform(aVlrAux[nVlr][08], "@E 9,999.99")+Space(01)+;
							  Iif(!Empty(aVlrAux[nVlr][09]),aVlrAux[nVlr][09]+' ',Space(08))+Space(02)+;
							  Transform(aVlrAux[nVlr][10], "@E 999.99")+Space(02)+;
							  Transform(aVlrAux[nVlr][11], "@E 9,999.99")+Space(02)+;
							  aVlrAux[nVlr][12]
				Else
					cLinha := Space(18)+Substr(cCodOpe+cCodEmp+cMatric+cDigito,15,2)+Space(2)+;
							  Substr(objCENFUNLGP:verCamNPR("BA1_NOMUSR", aVlrAux[nVlr][2]),01,35)+Space(02)+;
							  objCENFUNLGP:verCamNPR("BA1_DATNAS", dToc(aVlrAux[nVlr][3]))+Space(01)+;
							  objCENFUNLGP:verCamNPR("BA1_DATINC", dToc(aVlrAux[nVlr][4]))+Space(01)+;
							  objCENFUNLGP:verCamNPR("BFQ_DESCRI", aVlrAux[nVlr][05])+Space(01)+;
							  objCENFUNLGP:verCamNPR("BA1_DATINC", dToc(aVlrAux[nVlr][7]))+Space(04)+;
							  Transform(aVlrAux[nVlr][08], "@E 9,999.99")+Space(01)+;
							  Iif(!Empty(aVlrAux[nVlr][09]),aVlrAux[nVlr][09]+' ',Space(08))+Space(02)+;
							  Transform(aVlrAux[nVlr][10], "@E 999.99")+Space(02)+;
							  Transform(aVlrAux[nVlr][11], "@E 9,999.99")+Space(02)+;
							  aVlrAux[nVlr][12]
				Endif
				
				@ nLi,000 pSay cLinha
				nLi++
			Next
			nFor := nAux
        Next
	Next
Endif	

If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(cRel)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPlsUserCpo╨Autor  ЁGeraldo Felix Junior╨ Data Ё  12/12/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Efetua carga dos campos espeficos para impressao no        ╨╠╠
╠╠╨          Ёno relatorio...                                             ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlsUserCpo()
LOCAL cAlias := "BQC"
LOCAL cOrdem := "01"
LOCAL aCampos:= {}

SX3->( dbSeek(cAlias+cOrdem) )

While !SX3->( Eof() ) .and. SX3->X3_ARQUIVO == cAlias
	If Alltrim(SX3->X3_CAMPO) $ GetNewPar("MV_PLSC511",'')
		Aadd(aCampos, {X3TITULO(), Alltrim(SX3->X3_CAMPO)})
	Endif
	SX3->( dbSkip() )
Enddo

Return( aCampos )

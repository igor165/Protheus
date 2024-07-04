#INCLUDE "PLSR510.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")
static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR510 Ё Autor Ё Tulio Cesar            Ё Data Ё 14.05.04 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Relatorio de empresas que terao reajuste...                Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR510()                                                  Ё╠╠╠
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
Function PLSR510(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Default lAuto := .F.

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR510"
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := STR0001 //"Relatorio de Empresas que Terao Reajustes"
PRIVATE cDesc1      := STR0001 //"Relatorio de Empresas que Terao Reajustes"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BHW"
PRIVATE cPerg       := "PLR510"
PRIVATE cRel        := "PLSR510"
PRIVATE nLi         := 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { STR0002, 1,STR0003, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametros do relatorio (SX1)...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cCodOpe
PRIVATE cMesDe
PRIVATE cAnoDe
PRIVATE cMesAte
PRIVATE cAnoAte 
PRIVATE cGrupoDe
PRIVATE cGrupoAte
PRIVATE cContDe
PRIVATE cContAte
PRIVATE cSubDe
PRIVATE cSubAte
PRIVATE LWEB := .F.

lAutoSt := lAuto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

CriaSX1()
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
//Ё Acessa parametros do relatorio...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


Pergunte(cPerg,.F.)

cCodOpe   := mv_par01
cMesDe    := mv_par02
cAnoDe    := mv_par03
cMesAte   := mv_par04
cAnoAte   := mv_par05
cGrupoDe  := mv_par06
cGrupoAte := mv_par07
cContDe   := mv_par08
cContAte  := mv_par09
cSubDe    := mv_par10
cSubAte   := mv_par11
nTipoRel  := mv_par12
nMesObs	  := mv_par13

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	SetDefault(aReturn,cAlias)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	Processa({|| R510Imp() }, cTitulo, STR0004, .T.) //"Proc..."
else
	R510Imp()
endif

Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R510Imp  Ё Autor Ё Eduardo Motta         Ё Data Ё 24.05.01 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Emite relatorio de questionario...                         Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/
Function R510Imp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variaveis da rotina....                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cCabec    := ''
LOCAL cCnpj		:= ''
LOCAL aRetInd
LOCAL nFor        
LOCAL nAnos
LOCAL nMeses    
LOCAL aAuxMesesAnos
LOCAL cSQL 
LOCAL cLinha     := ""
LOCAL aRel       := {}
LOCAL aMesesAnos := {}
LOCAL aMesesSub  := {}                                                              
LOCAL nPos
LOCAL cTipo                
LOCAL aEmps      := {}
LOCAL aConts     := {}
LOCAL aObs	  	 := {}
LOCAL cDesIn
LOCAL cLinPad
LOCAL cMeses
LOCAL nContLin
LOCAL l1Vez  
LOCAL lDescri   
LOCAL lNoReg := .F.
LOCAL cIndReaPad               
LOCAL nIndice
LOCAL nIndPad       
LOCAL cIndice
LOCAL aPlanos
LOCAL nVlrRea := 0
LOCAL nTotUsr := 0
LOCAL nTotOri := 0
LOCAL nTotRea := 0
LOCAL cNivRea := ''
LOCAL nI	  := 0
Local lBGJ
Local lImp
Local dBGJ
Local dInc
Local oPrint	:= nil
Local oRel	
Local cPathDest	:= __RELIMP 
Local nPixLin		:= 40
Local nPixCol		:= 35
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o cabecalho de acordo com o tipo de relatorio...                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTipoRel == 2
	cCabec := STR0005+"                                                                 "+STR0006+"             "+STR0007+"             "+STR0008+"             "+STR0009+"                                                                                                           " //"SubContrato"###"Indice"###"TpCont."###"Perc."###"Mes(es)"
Else
	cCabec := Space(220)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a matriz aMeseAnos com os anos/meses que serao processados...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aMesesAnos := {}
If cAnoAte+cMesAte == cAnoDe+cMesDe
   aadd(aMesesAnos,{cMesAte,cAnoAte})
Else 
   If cAnoAte > cAnoDe
      For nMeses := Val(cMesDe) To 12
          aadd(aMesesAnos,{StrZero(nMeses,2),cAnoDe})
      Next    
      For nMeses := 1 To val(cMesAte)
          aadd(aMesesAnos,{StrZero(nMeses,2),cAnoAte})
      Next    
   Else
      For nMeses := Val(cMesDe) To val(cMesAte)
          aadd(aMesesAnos,{StrZero(nMeses,2),cAnoDe})
      Next    
   Endif   
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define query de acesso ao bando...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := " SELECT R_E_C_N_O_ AS REG, BQC_CODINT, BQC_DESCRI, BQC_CODIGO, BQC_CODEMP, "
cSQL += " BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_CNPJ, BQC_CODCLI, BQC_LOJA FROM "+RetSQLName("BQC")+" WHERE "
cSQL += " BQC_FILIAL = '"+xFilial("BQC")+"' AND "
cSQL += " BQC_CODINT = '"+cCodOpe+"' AND "
cSQL += " BQC_CODEMP >= '"+cGrupoDe+"' AND "
cSQL += " BQC_CODEMP <= '"+cGrupoAte+"' AND "
cSQL += " BQC_NUMCON >= '"+cContDe+"' AND "
cSQL += " BQC_NUMCON <= '"+cContAte+"' AND "
cSQL += " BQC_SUBCON >= '"+cSubDe+"' AND "
cSQL += " BQC_SUBCON <= '"+cSubAte+"' AND "
cSQL += " BQC_CODBLO = '   ' AND "
cSQL += " D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_SUBCON "

PLSQuery(cSQL,"PLS510")

If PLS510->(Eof())
   lNoReg := .T.
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Leitura de cada subcontrato...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPD->(DbSetOrder(2))
While ! PLS510->(Eof())
	
	if !lAutoSt
		IncProc(STR0010+" "+BQC->(BQC_CODINT+"."+BQC_CODEMP+"."+BQC_NUMCON+"."+BQC_VERCON+"."+BQC_SUBCON+"."+BQC_VERSUB)) //"Processando"
		ProcessMessage()
	endif

	BQC->(DbGoTo(PLS510->REG))
	
	BT6->(DbSetOrder(1))
	BT6->(DbSeek(xFilial("BT6")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)))
	cTipo := If(AllTrim(BT6->BT6_MODPAG)=="1","PP ","CO ")
	lDescri := .T.

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega o CGC do sub contrato... caso em branco, pega o cgc do cliente...   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	cCnpj := PLS510->BQC_CNPJ
	If Empty(cCnpj)
		SA1->( dbSetorder(01) )
		If SA1->( dbSeek(xFilial("SA1")+PLS510->BQC_CODCLI+PLS510->BQC_LOJA) )
			cCnpj := SA1->A1_CGC
		Endif
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a matriz de cada subcontrato e respectivos anos/meses reajustes... Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lDescri := .T.
	For nFor := 1 To Len(aMesesAnos)
		aRetInd := PLSSUBREAJ(cCodOpe,Subs(PLS510->BQC_CODEMP,1,4),;
		PLS510->BQC_NUMCON,PLS510->BQC_VERCON,PLS510->BQC_SUBCON,;
		PLS510->BQC_VERSUB,aMesesAnos[nFor,2],aMesesAnos[nFor,1])
		                                                                 
		If BPD->(MsSeek(xFilial("BPD") + PLS510->(BQC_CODINT+BQC_CODEMP) + aMesesAnos[nFor,2]+aMesesAnos[nFor,1]))
			Loop
		EndIf
		
		If aRetInd[1]
			nPos2 := Ascan(aMesesSub,{|x| x[8] == PLS510->BQC_CODINT .And. x[7] == PLS510->BQC_SUBCON .And. x[9] == PLS510->BQC_NUMCON  .And. x[10] == PLS510->BQC_CODEMP })
			If nPos2 == 0
				lDescri := .T.
			Else
				lDescri := .F.
			Endif
			
			nPos := Ascan(aMesesSub,{|x| x[3] == aRetInd[5] .And. x[8] == PLS510->BQC_CODINT .And. x[7] == PLS510->BQC_SUBCON .And. x[9] == PLS510->BQC_NUMCON  .And. x[10] == PLS510->BQC_CODEMP })
			If nPos == 0
				aadd(aMesesSub,{ {{aMesesAnos[nFor,1],aMesesAnos[nFor,2]}},;
				aRetInd[4],;
				aRetInd[5],;
				PLS510->REG,;
				Subs(PLS510->BQC_DESCRI,1,50),;
				cTipo,;
				PLS510->BQC_SUBCON,;
				PLS510->BQC_CODINT,;
				PLS510->BQC_NUMCON,;
				PLS510->BQC_CODEMP,;
				Subs(aRetInd[10],1,10),;
				lDescri,;
				PLS510->BQC_VERCON,;
				PLS510->BQC_VERSUB,;
				cCnpj,;
				aRetInd[11]})
			Else
				aAuxMesesAnos := aMesesSub[nPos,1]
				nPos3 := Ascan(aAuxMesesAnos,{ |x| x[1] + x[2] == aMesesAnos[nFor,1]+aMesesAnos[nFor,2] })
				If nPos3 == 0
					aadd(aMesesSub[nPos,1],{ aMesesAnos[nFor,1],aMesesAnos[nFor,2] } )
				Endif
			Endif
		Endif
	Next
	
	PLS510->(DbSkip())
Enddo

PLS510->(DbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Leitura da matriz com os subcontratos a reajustar...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLinha := STR0011+": "+cCodOpe+" - "+Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT") //"Operadora"
aadd(aRel,{cLinha, .F., {}})  

                      
For nFor := 1 To Len(aMesesSub)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Analisa quebra da empresa...                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := Ascan(aEmps,{|x| x[1] == aMesesSub[nFor,10]})
	If nPos == 0
		
		cLinha := Replicate("-",nLimite)
		aadd(aRel,{cLinha,.F.,{}})
		aadd(aEmps,{aMesesSub[nFor,10],Posicione("BG9",1,xFilial("BG9")+cCodOpe+aMesesSub[nFor,10],"BG9_DESCRI")})
		cLinha := STR0012+": "+aEmps[Len(aEmps),1]+" - "+aEmps[Len(aEmps),2] //"Empresa"
		aadd(aRel,{cLinha,.F.,{}})
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Analisa quebra do contrato...                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := Ascan(aConts,{|x| x[1] == aMesesSub[nFor,10] .And. x[2] == aMesesSub[nFor,9] })
	If nPos == 0
		aadd(aConts,{aMesesSub[nFor,10],aMesesSub[nFor,9]})
		cLinha := ""
		aadd(aRel,{cLinha, .F.,{}})
		cLinha := STR0013+": "+aConts[Len(aConts),2] //"Contrato"
		aadd(aRel,{cLinha, .F.,{}})
		cLinha := ""
		If nTipoRel == 2
			aadd(aRel,{cLinha, .F.,{}})
			cLinha := cCabec
			aadd(aRel,{cLinha, .F.,{}})
			cLinha := ""
			aadd(aRel,{cLinha, .F.,{}})
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё lista o subcontrato atual...                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nTipoRel == 2
		If aMesesSub[nFor,12]
			cLinPad   := aMesesSub[nFor,7]+" - "+aMesesSub[nFor,5]+aMesesSub[nFor,11]+Space(10)+aMesesSub[nFor,6]+Space(10)+;
			TransForm(aMesesSub[nFor,2],"@E 999.99")+"% "
		Else
			cLinPad   := Space(Len(aMesesSub[nFor,7]))+"   "+Space(Len(aMesesSub[nFor,5]))+Space(02)+aMesesSub[nFor,11]+Space(02)+aMesesSub[nFor,6]+Space(03)+;
			TransForm(aMesesSub[nFor,2],"@E 999.99")+"% "
		Endif
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao analitica do reajuste...                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		cLinPad   := aMesesSub[nFor,7]+" - "+aMesesSub[nFor,5]+Space(02)+;
		aMesesSub[nFor,11]+Space(10)+' CNPJ: '+aMesesSub[nFor,15]
	Endif

	cMeses   := ""
	nContLin := 0
	l1Vez    := .T.
	
	For nPos := 1 To Len(aMesesSub[nFor,1])
		cMeses += aMesesSub[nFor,1,nPos,1]+"/"+aMesesSub[nFor,1,nPos,2]+"  "
		nContLin += Len(cMeses)
		If nContLin > 60
			If l1Vez
				cLinha   := cLinPad + Space(11) + cMeses
				l1Vez := .F.
			Else
				cLinha   := Space(Len(cLinPad))+cMeses
			Endif
			aadd(aRel,{cLinha, Iif(nTipoRel == 1, .T., .F.), Iif(nTipoRel == 1, aClone(aMesesSub[nFor]), {})})
			cMeses   := ""
			nContLin := 0
		Endif
	Next
	If !Empty(cMeses)
		If l1Vez
			l1Vez := .F.
			cLinha := cLinPad + Space(11) + cMeses
		Else
			cLinha := Space(Len(cLinPad))+cMeses
		Endif
		aadd(aRel,{cLinha, Iif(nTipoRel == 1, .T., .F.), Iif(nTipoRel == 1, aClone(aMesesSub[nFor]), {})})
	Endif
Next

cLinha := Replicate("-",nLimite)
aadd(aRel,{cLinha, .F., {}})      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Leitura dos familias PF...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BG9_CODIGO, BG9_CODINT, BG9_DESCRI FROM "+RetSQLName("BG9")+" WHERE "
cSQL += "BG9_FILIAL = '"+xFilial("BG9")+"' AND "
cSQL += "BG9_CODINT = '"+cCodOpe+"' AND "
cSQL += "BG9_CODIGO >= '"+cGrupoDe+"' AND "
cSQL += "BG9_CODIGO <= '"+cGrupoAte+"' AND "
cSQL += "BG9_TIPO = '1' AND "
cSQL += "D_E_L_E_T_ = '' "
cSQL += "ORDER BY BG9_CODINT, BG9_CODIGO"

PLSQuery(cSQL,"PLS510")

While ! PLS510->(Eof())

      cLinha := STR0014+": "+PLS510->BG9_DESCRI                                                              //"Grupo Empresa"
      aadd(aRel,{cLinha, .F.,{}})
      cLinha := "" 
      aadd(aRel,{cLinha, .F.,{}})
      
      lImpCab := .F.

      For nFor := 1 To Len(aMesesAnos)
      
          aRetInd := PLSSUBREAJ(cCodOpe,PLS510->BG9_CODIGO,"","","",;
           	                    "",aMesesAnos[nFor,2],aMesesAnos[nFor,1])

          If ! aRetInd[1]
             cIndReaPad := STR0040 //"NAO INFOR."
             nIndPad    := 0
          Else
             cIndReaPad := aRetInd[05]
             nIndPad    := aRetInd[04]
             cNivRea	:= aRetInd[11]
          Endif   

    
          cSQL := "SELECT BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_INDREA, BA3_MODPAG,BA3_DATCIV, BA3_TIPOUS, BA3_DATBAS FROM "+RetSQLName("BA3")+" WHERE "
          cSQL += "BA3_FILIAL = '"+xFilial("BA3")+"' AND "
          cSQL += "BA3_CODINT = '"+PLS510->BG9_CODINT+"' AND "                 
          cSQL += "BA3_CODEMP = '"+PLS510->BG9_CODIGO+"' AND "
          If lWeb
          		cSQL += "BA3_MATRIC = '"+ cMatric+"' AND "
          EndIf 
          cSQL += "BA3_MESREA = '"+aMesesAnos[nFor,1]+"' AND "
          cSQL += "BA3_MOTBLO = '' AND "            
          cSQL += "D_E_L_E_T_ = ''"
    
          PLSQUERY(cSQL,"PLS510FAM")
    
          While ! PLS510FAM->(Eof())
          
                lBGJ:=.F. 
                lImp:=.F.


     			
     			//BGJ_FILIAL + BGJ_CODINT + BGJ_CODIGO + BGJ_ANO + BGJ_MES                                                                                                        
                BGJ->(dBSetOrder(1))
                BGJ->(dBSeek(xFilial("BGJ")+PLS510FAM->(BA3_CODINT+BA3_CODEMP)))//+aMesesAnos[nFor,2]+aMesesAnos[nFor,1]))
                
                If BGJ->(found()) .and. BGJ->BGJ_TIPOGR=="1"// pessoa fisica
                	If Empty(BGJ->BGJ_ANO)
                		lBGJ:=.T.
                	Else
                	    if BGJ->BGJ_ANO = aMesesAnos[nFor,2]
                	    	lBGJ:=.T.
                	    Endif
                    Endif
                Endif
                
                If ! lImpCab
                   If lWeb
                   	cLinha := aMesesAnos[nFor,2]
                   Else
                   	cLinha := aMesesAnos[nFor,1]+" / "+aMesesAnos[nFor,2]
                   EndIf
                    aadd(aRel,{cLinha, .F.,{}})
                   cLinha := ""         

                   cLinha := STR0015+"                 "+STR0016+"                                                                                              "+STR0006+"               "+STR0017+"         "+STR0018 //"Matricula"###"Titular"###"Indice"###"Percentual"###"Tipo Contrato"
                   aadd(aRel,{cLinha, .F.,{}})
                   cLinha := ""
                   aadd(aRel,{cLinha, .F.,{}})
                   lImpCab := .T.
                Endif   

                BA1->(DbSetOrder(2))
                BA1->(DbSeek(xFilial("BA1")+PLS510FAM->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
                
          		If lBGJ
					IF BGJ->BGJ_TIPO =="3"  // usuario + 12 meses 
						dInc:= BA1->BA1_DATINC + 365
                		dBGJ:= PLS510FAM->(BA3_DATCIV)
                	  	If dInc < dBGJ
	                		lImp:=.T.
	                	Endif
 	                ElseIF BGJ->BGJ_TIPO =="2"//familia + 12 meses
	                	dInc:= PLS510FAM->(BA3_DATBAS) + 365
                		dBGJ:= PLS510FAM->(BA3_DATCIV)
                	   	If dInc < dBGJ
	                		lImp:=.T.
	                	Endif
	                Else
	            		lImp:=.T.    
	                Endif
	            Endif
                
                If !lBGJ .OR. lImp
	                If ! Empty(PLS510FAM->BA3_INDREA)
	                   AAD->(DbSetOrder(1))
	                   AAD->(DbSeek(xFilial("AAD")+PLS510FAM->BA3_INDREA))
	                   cIndice := Subs(AAD->AAD_DESCRI,1,10)
	                   nIndice := PLSBUSIND(AAD->AAD_CODIND,aMesesAnos[nFor,2],aMesesAnos[nFor,1])
	                Else
	                   cIndice := cIndReaPad
	                   nIndice := nIndPad
	                Endif   
	             
	                cLinha := TransForm(PLS510FAM->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),"@R !!!!.!!!!.!!!!!!")+Space(02)+;
	                          BA1->BA1_NOMUSR+Space(01)+;                
	                          cIndice+Space(05)+;
	                          TransForm(nIndice,"@E 999.99")+"%"+Space(15)+;
	                          If(AllTrim(PLS510FAM->BA3_MODPAG)=="1","PP ","CO ")
	                aadd(aRel,{cLinha, .F.,{}})
	            Endif
    
          PLS510FAM->(DbSkip())
          Enddo
          PLS510FAM->(DbCloseArea())
      Next
PLS510->(DbSkip())
Enddo      

PLS510->(DbCloseArea())
	     
If lWeb
	nli := 5
Else
	nli := Cabec(cTitulo,cCabec1,cCabec2)
EndIf

For nFor := 1 To Len(aRel)

If nLi > 60 

	If lWeb 
		nLi := 5
	Else  
		nli := Cabec(cTitulo,cCabec1,cCabec2)
	EndIf
Endif     
    @ nLi++, 2 pSay aRel[nFor,1]

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Para impressao dos detalhes quando a impressao for analitica...          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
	If aRel[nFor,2]
		aPlanos := r510ImpDet(aRel[nFor, 3])
		For nI := 1 To Len(aPlanos)
			If nI == 1
				@ nLi++, 10 pSay STR0019+"  "+STR0020+" "+STR0021+"             "+STR0022+"             "+STR0023+"        "+STR0024+"  "+STR0025+"   "+STR0026 //"Plano"###"Versao"###"Descricao do produto"###"Nr. Usr"###"Valor Atual"###"Rea."###"Valor  Reajustado"###"Dt Produto"
				@ nLi++, 10 pSay "---------------------------------------------------------------------------------------------------------------------------------"
			Endif				
				
			cLinha := aPlanos[nI][1]+Space(03)+;
			aPlanos[nI][2]+Space(03)+;
			Substr(Posicione("BI3",1,xFilial("BI3")+aRel[nFor, 3,8]+aPlanos[nI][1],"BI3_DESCRI")+Space(05),1,30)+Space(05)+;
			Transform(aPlanos[nI][3], '@E 99999')+Space(10)+;
			Transform(aPlanos[nI][4], '@E 999,999,999.99')+Space(05)+;
			TransForm(aPlanos[nI][5], '@E 999.99')+'%'+Space(05)+;
			Transform(aPlanos[nI][6], '@E 999,999,999.99')
			If BT6->( FieldPos("BT6_DATINC") ) > 0
				cLinha += Space(05)+dToc(BT6->BT6_DATINC)
			Endif
			
			@ nLi++, 10 pSay cLinha
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula Totais...                                                        Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
			nTotUsr += aPlanos[nI][3]
			nTotOri += aPlanos[nI][4]
			nTotRea += aPlanos[nI][6]

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controla o salto de paginas...                                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    			
			If nLi > 60
				If lWeb 
					nLi := 5
				Else  
					nli := Cabec(cTitulo,cCabec1,cCabec2)
				EndIf
			Endif         
		Next
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime Totais Acumulados...                                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
		nLi++
		@ nLi++, 047 Psay 	STR0027+" --->"+	Transform(nTotUsr, '@E 99999')+Space(10)+; //"Totais"
											Transform(nTotOri, '@E 999,999,999.99')+Space(17)+;
											Transform(nTotRea, '@E 999,999,999.99')

		aObs := r510ImpObs(aRel[nFor, 3], nMesObs)
		                       	
		For nI := 1 To Len(aObs)
			If nI == 1
				@ nLi++, 02 pSay STR0028 //"Observacoes..."
			Endif				
			@ nLi++, 10 pSay aObs[nI][2]
			@ nLi++, 10 pSay aObs[nI][3]
			@ nLi++, 10 pSay aObs[nI][4]
			
			nLi++
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controla o salto de paginas...                                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    			
			If nLi > 60
		       nli := Cabec(cTitulo,cCabec1,cCabec2)
		    Endif  	
			    			
		Next
		
		
	Endif		

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controla o salto de paginas...                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    					
    If nLi > 60
    	If lWeb 
    		nLi := 5
    	Else  
    	 	nli := Cabec(cTitulo,cCabec1,cCabec2)
    	EndIf
    Endif   
Next    

If lWeb .OR. lAutoSt
				
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Instancia os objetos de fonte antes da pintura do relatorio  Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oFont9  	:= TFont():New( "Arial",, 9,,.F.)
	oFont10  	:= TFont():New( "Arial",, 10,,.F.)
	oFont10N 	:= TFont():New( "Arial",, 10,,.T.)
	oFont12  	:= TFont():New( "Arial",, 12,,.F.)
	oFont12N 	:= TFont():New( "Arial",, 12,,.T.)
	oFont14 	:= TFont():New( "Arial",, 14,,.F.)
	oFont14N 	:= TFont():New( "Arial",, 14,,.T.)
	oFont16 	:= TFont():New( "Arial",, 16,,.F.)
	oFont16N 	:= TFont():New( "Arial",, 16,,.T.)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё obj															 Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oRel := FWMSPrinter():New(cRelName,6	  ,.F.,nil,.T.,nil,@oRel,nil,nil,.F.,.F.)	
	oRel:cPathPDF := cPathDest
	oRel:setResolution(72)
	oRel:setPortrait()
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё nEsquerda, nSuperior, nDireita, nInferior 					 Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oRel:setMargin(05,05,05,05)
	
		
	If oRel:nPaperSize  == 9 // PapИl A4
		nLinMax	:= 2350
		nColMax	:= 750
		nLayout := 2
	ElseIf oRel:nPaperSize == 1 // Papel Carta
		nLinMax	:= 790
		nColMax	:= 575
		nLayout := 3
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:= 3705
		nColMax	:= 2400
		nLayout := 1
	EndIf	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa uma pagina					 					 Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
	
	oRel:StartPage()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Insere logo no relatorio					 				 Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	aBMPEsq	:= {"lgesq.bmp"}
	aBMPDir  := {"lgdir.bmp"}
		
	If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMPEsq := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
		aBMPEsq := { "lgesq" + FWGrpCompany() + ".bmp" }
	EndIf
		
	If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMPDir := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
		aBMPDir := { "lgdir" + FWGrpCompany() + ".bmp" }
	EndIf
		
	If !Empty(aBMPEsq[1])
		oRel:SayBitmap(10,10, aBMPEsq[1],130,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
		IIf((nPixLin == 40), nPixLin := 70, nPixLin := nPixLin)
	Endif
	
	If !Empty(aBMPDir[1])
		oRel:SayBitmap(10,450, aBMPDir[1],130,50) 		//-- Tem que estar abaixo do RootPath
		IIf((nPixLin == 40), nPixLin := 70, IIF(nPixLin == 70, nPixLin := nPixLin, nPixLin := nPixLin))
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime cabecalho							 					  Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	
	oRel:Line( nPixLin, nPixCol, nPixLin, nColMax, , "+2")	//linha horizontal
	nPixLin += 10	
	oRel:say(nPixLin,nPixCol,cVersao,oFont9)
	nPixLin += 10	
	oRel:say(nPixLin,nPixCol,FWFilRazSocial(),oFont9)
	nPixLin += 10	
	oRel:say(nPixLin,nPixCol,FWFilialName(),oFont9)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol,'Hora: ' + time() +'  Data: '+ cvaltochar(DDATABASE),oFont9)
	
	
			
	oRel:say(nPixLin,nPixCol + 150,cTitulo,oFont16n)
	nPixLin += 30
	
	oRel:Line( nPixLin, nPixCol, nPixLin, nColMax, , "+2")	//linha horizontal
	nPixLin += 20	
	
	
	
	//oRel:say(nPixLin +5,nPixCol + 402,aRel[1][1],oFont10)
	//nPixLin += 10
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime corpo									 					  Ё  
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
	nPixLin += 25
		
	For nI=1 to len(aRel) 
		oRel:say(nPixLin,nPixCol,aRel[nI][1],oFont10)
		nPixLin += 10
	Next
						
	oRel:EndPage()	
	oRel:Preview()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁFim da rotina
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	
EndIf



If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(cRel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ёr510ImpDet╨Autor  ЁGeraldo Felix Junior╨ Data Ё  01/20/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime os detalhes do relatorio quando a impressao for     ╨╠╠
╠╠╨          Ёanalitica.                                                  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
Esta rotina tem como objetivo pegar todos os produtos do sub contrato
e acular a quantidade de usuarios em cada um deles para apresentar o 
valor total de cada produto. Aplicar o reajuste sobre esse valor e apresentar
o total reajustado.
*/
Static Function r510ImpDet(aSubs)
LOCAL cCodInt := aSubs[08]
LOCAL cCodEmp := aSubs[10]
LOCAL cNumcon := aSubs[09]
LOCAL cVerCon := aSubs[13]
LOCAL cSubCon := aSubs[07]
LOCAL cVerSub := aSubs[14]
LOCAL nIndice := aSubs[02]
LOCAL cMatUsr := ''
LOCAL cCodPro := ''
LOCAL cVersao := ''
LOCAL nVlrRea := 0
LOCAL aPlanos := {}
LOCAL cAno := Alltrim(Str(Year(dDataBase)))
LOCAL cMes := StrZero(Month(dDataBase),2)

LOCAL cNameBA3 := RetSqlName("BA3")
LOCAL aEventos := {	} 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Para melhorar a performace da PLSVLRFAM, passo a ela apenas os eventos que me enterecam para o reajuste.  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aEventos, {'101','','','','','','','','','','','','','','','','','','','','','','','',''})
Aadd(aEventos, {'102','','','','','','','','','','','','','','','','','','','','','','','',''})
Aadd(aEventos, {'103','','','','','','','','','','','','','','','','','','','','','','','',''})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Primeiro: Posiciona no primeiro produto do sub contrato.                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->( dbSetorder(02) )
BT6->( dbSetorder(01) )
If BT6->( dbSeek(xFilial("BT6")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub) )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Segundo.: Processa um por um dos produtos...                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !BT6->( Eof() ) .and. BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB) ==;
						 		 cCodInt+cCodEmp+cNumcon+cVerCon+cSubCon+cVerSub
		cCodPro := BT6->BT6_CODPRO
		cVersao := BT6->BT6_VERSAO

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Terceiro: Pega todas as familia do produto atual do processamento...     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		cSql := "SELECT R_E_C_N_O_ BA3REG FROM "+cNameBA3+" WHERE BA3_FILIAL = '"+xFilial("BA3")+"' "
		cSql += "AND BA3_CODINT = '"+cCodInt+"' "
		cSql += "AND BA3_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BA3_CONEMP = '"+cNumcon+"' "
		cSql += "AND BA3_VERCON = '"+cVercon+"' "
		cSql += "AND BA3_SUBCON = '"+cSubCon+"' "
		cSql += "AND BA3_VERSUB = '"+cVerSub+"' "
		cSql += "AND BA3_CODPLA = '"+cCodPro+"' "
		cSql += "AND BA3_VERSAO = '"+cVersao+"' "
		
		cSql += "AND D_E_L_E_T_ =  ' '"
		PlsQuery(cSql, "TRBA3")
		
		TRBA3->( dbGotop() )
		While !TRBA3->( Eof() )
			BA3->( dbGoto(TRBA3->BA3REG) )
		
			if !lAutoSt
				IncProc(STR0029+" "+BA3->BA3_CODINT+'.'+BA3->BA3_CODEMP+'.'+BA3->BA3_MATRIC) //"Calculando Familia"
				ProcessMessage()
			endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё ** Verifica se a familia tem usuarios ativos...                          Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
			aUsuarios := PLSLOADUSR(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,cAno,cMes)
			If Len(aUsuarios) == 0
			   TRBA3->(DbSkip())
			   Loop
			Endif   
						
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Quarto..: Encontra o valor de cobranca da familia...                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
			aRet := PLSVLRFAM(BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC,cAno,cMes,aEventos,NIL,NIL,NIL,.T.)[1]
			                                     
			If aRet[1]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Quinto..: Tem que olhar para o usuario, pois ele pode ter plano diferente da familia...|
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
				If BA1->( dbSeek(xFilial("BA1")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC) )
					While !BA1->( Eof() ) .and. BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC ==;
											 BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
								   
						cMatUsr := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)				 
						
				    	nPos := Ascan(aRet[2], {|x| x[3] == '101' .and. x[7] == cMatUsr})
						
						If nPos > 0				    	
							If !Empty(BA1->BA1_CODPLA) .and. BA1->(BA1_CODPLA+BA1_VERSAO) <> BA3->(BA3_CODPLA+BA3_VERSAO)
								cCodPla := BA1->BA1_CODPLA
								cVerPla := BA1->BA1_VERSAO
							Else                                                                        
								cCodPla := BA3->BA3_CODPLA
								cVerPla := BA3->BA3_VERSAO
							Endif
							
							nPos2 := Ascan(aPlanos, {|y| y[1] == cCodPla .and. y[2] == cVersao})
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Apura o valor com o reajuste...                                          Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							nVlrRea := Round(aRet[2][nPos][2] + ((aRet[2][nPos][2]*nIndice)/100),2)
							If nPos2 == 0
								Aadd(aPlanos, {cCodPla,;           // Plano
									cVerPla,; 						// Versao do Plano
									1,;								// Quantidade de usuarios
									aRet[2][nPos][2],;				// Valor de cobranca do usuario
									nIndice,;						// Indice Aplicado.
									nVlrRea} )						// Valor ja reajustado.
							Else
								aPlanos[nPos2][3] ++					// Incrementa quantidade de usuarios
								aPlanos[nPos2][4] += aRet[2][nPos][2]	// Incrementa o valor de cobranca do plano.
								aPlanos[nPos2][6] += nVlrRea			// Incrementa o valor de cobranca reajustado.
							Endif
							
						Endif
						BA1->( dbskip() )
					Enddo
				Endif	
			Endif			
			TRBA3->( dbSkip() )
		Enddo			
        TRBA3->( dbCloseArea() )
       	BT6->( dbSkip() )
	Enddo
Endif					

Return(aPlanos)
					

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ёr510ImpObs╨Autor  ЁGeraldo Felix Junior╨ Data Ё  23/01/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime as observacoes dos ultimos reajustes sofridos...    ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function r510ImpObs(aSubs, nMesObs)
LOCAL cCodInt := aSubs[08]
LOCAL cCodEmp := aSubs[10]
LOCAL cNumcon := aSubs[09]
LOCAL cVerCon := aSubs[13]
LOCAL cSubCon := aSubs[07]
LOCAL cVerSub := aSubs[14]
LOCAL nIndice := aSubs[02]
LOCAL cNivRea := aSubs[16]
LOCAL nCnt	  := 0
LOCAL nCount  := 0
LOCAL aObs	  := {}
LOCAL aObsAux := {}

If cNivRea == '3'
	If 	BYA->( Fieldpos("BYA_OBS1") ) == 0 .or.;
		BYA->( Fieldpos("BYA_OBS2") ) == 0 .or.;
		BYA->( Fieldpos("BYA_OBS3") ) == 0
		Return(aObs)
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Subcontrato...                                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := "SELECT BYA_TIPOIN,BYA_TIPO,BYA_PERRRL,BYA_INDRRL,BYA_PROD,BYA_OPC,BYA_TAX,BYA_OBS1,BYA_OBS2, BYA_OBS3 "
	cSql += "FROM "+RetSQLName("BYA")+" WHERE "
	cSQL += "BYA_FILIAL = '"+xFilial("BYA")+"' AND "
	cSQL += "BYA_CODINT = '"+cCodInt+"' AND "
	cSQL += "BYA_CODIGO = '"+cCodEmp+"' AND "
	cSQL += "BYA_NUMCON = '"+cNumcon+"' AND "
	cSQL += "BYA_VERSAO = '"+cVerCon+"' AND "
	cSQL += "BYA_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BYA_VERSUB = '"+cVerSub+"' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"TRB510")        

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tabela no topo...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->( dbGotop() )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega matriz indexando pelo nOrd..                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                          
	nOrd := 0
	TRB510->( dbEval( {|| Aadd(aObsAux, {++nOrd,TRB510->BYA_OBS1, TRB510->BYA_OBS2, TRB510->BYA_OBS3} )} ) )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega os ultimos de acordo com o parametro...                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	nOrd := 0
	For nCnt := 1 To Len(aObsAux) Step -1
		nOrd++
	
		If nOrd <= nMesObs
			Aadd(aObs, aClone(aObsAux[nCnt]))
		Endif
		 
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reordena os registros...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Asort(aObs,,,{|x,y| x[1] > y[1]})	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha a area de trabalho...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->(DbCloseArea())
	
Elseif cNivRea == '2'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Contrato...                                                           	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If 	BH3->( Fieldpos("BH3_OBS1") ) == 0 .or.;
		BH3->( Fieldpos("BH3_OBS2") ) == 0 .or.;
		BH3->( Fieldpos("BH3_OBS3") ) == 0
		Return(aObs)
	Endif
		
	cSQL := "SELECT BH3_TIPOIN,BH3_TIPO,BH3_PERRRL,BH3_INDRRL,BH3_PROD,BH3_OPC,BH3_TAX,BH3_OBS1,BH3_OBS2,BH3_OBS3 "
	cSQL += "FROM "+RetSQLName("BH3")+" WHERE "
	cSQL += "BH3_FILIAL = '"+xFilial("BH3")+"' AND "
	cSQL += "BH3_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BH3_CODIGO = '"+cCodEmp+"' AND "
	cSQL += "BH3_NUMCON = '"+cNumcon+"' AND "
	cSQL += "BH3_VERSAO = '"+cVerCon+"' AND "
	
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"TRB510")
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tabela no topo...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->( dbGotop() )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega matriz indexando pelo nOrd..                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                          
	nOrd := 0
	TRB510->( dbEval( {|| Aadd(aObsAux, {++nOrd,TRB510->BH3_OBS1, TRB510->BH3_OBS2, TRB510->BH3_OBS3} )} ) )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega os ultimos de acordo com o parametro...                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	nOrd := 0
	For nCnt := 1 To Len(aObsAux) Step -1
		nOrd++
	
		If nOrd <= nMesObs
			Aadd(aObs, aClone(aObsAux[nCnt]))
		Endif
		
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reordena os registros...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Asort(aObs,,,{|x,y| x[1] > y[1]})	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha a area de trabalho...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->(DbCloseArea())
			
Elseif cNivRea == '1'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grupo empresa...                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If 	BGJ->( Fieldpos("BGJ_OBS1") ) == 0 .or.;
		BGJ->( Fieldpos("BGJ_OBS2") ) == 0 .or.;
		BGJ->( Fieldpos("BGJ_OBS3") ) == 0
		Return(aObs)
	Endif
	
	cSQL := "SELECT BGJ_TIPOIN,BGJ_TIPO,BGJ_PERRRL,BGJ_INDRRL,BGJ_PROD,BGJ_OPC,BGJ_TAX,BGJ_OBS1,BGJ_OBS2,BGJ_OBS3 "
	cSQL += "FROM "+RetSQLName("BGJ")+" WHERE "
	cSQL += "BGJ_FILIAL = '"+xFilial("BGJ")+"' AND "
	cSQL += "BGJ_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BGJ_CODIGO = '"+cCodEmp+"' AND "
	
	cSQL += "D_E_L_E_T_ = ' '"
	
	PLSQuery(cSQL,"TRB510")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tabela no topo...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->( dbGotop() )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega matriz indexando pelo nOrd..                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                          
	nOrd := 0
	TRB510->( dbEval( {|| Aadd(aObsAux, {++nOrd,TRB510->BGJ_OBS1, TRB510->BGJ_OBS2, TRB510->BGJ_OBS3} )} ) )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega os ultimos de acordo com o parametro...                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	nOrd := 0
	For nCnt := 1 To Len(aObsAux) Step -1
		nOrd++
	
		If nOrd <= nMesObs
			Aadd(aObs, aClone(aObsAux[nCnt]))
		Endif
		
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reordena os registros...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Asort(aObs,,,{|x,y| x[1] > y[1]})	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha a area de trabalho...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB510->(DbCloseArea())
Endif
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorno da funcao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(aObs)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё PLSR510Vld  Ё Autor Ё Tulio Cesar        Ё Data Ё 14.03.05 Ё╠╠
╠╠цдддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Valida mes e ano informado.                                Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/
Function PLSR510Vld(nVld)
LOCAL lRet := .T.

If     nVld == 1 //Mes De  
       If Alltrim(Upper(mv_par02)) == "ZZ" .Or. Empty(mv_par02) .Or. (mv_par02 > mv_par04 .And. ! empty(mv_par04)) .Or. mv_par02 < "01" .Or. mv_par02 > "12"
          if !lAutoSt
			  MsgStop("'"+STR0030+"' "+STR0031) //"Mes De"###"Invalido"
		  endif
          lRet := .F. 
       Endif
ElseIf nVld == 2 //Ano De
       If Alltrim(Upper(mv_par03)) == "ZZZZ" .Or. Empty(mv_par03) .Or. (mv_par02 > mv_par04 .And. ! empty(mv_par04))
          if !lAutoSt
		  	MsgStop("'"+STR0032+"' "+STR0031) //"Ano De"###"Invalido"
          endif
		  lRet := .F. 
       Endif
       
       If ( val(mv_par03) / 1000 ) < 1 .AND. !lAutoSt
          MsgStop(STR0033) //"Ano Invalido"
          lRet := .F.
       Endif   
ElseIf nVld == 3 //Mes Ate
       If Alltrim(Upper(mv_par04)) == "ZZ" .Or. Empty(mv_par04) .Or. (mv_par04 < mv_par02 .And. ! empty(mv_par04)) .Or. mv_par04 < "01" .Or. mv_par04 > "12"
          if !lAutoSt
		  	MsgStop("'"+STR0034+"' "+STR0031) //"Mes Ate"###"Invalido"
          endif
		  lRet := .F. 
       Endif
ElseIf nVld == 4 //Ano Ate
       If Alltrim(Upper(mv_par05)) == "ZZZZ" .Or. Empty(mv_par05) .Or. (mv_par05 < mv_par03 .And. ! empty(mv_par05))
          if !lAutoSt
		  	MsgStop("'"+STR0035+"' "+STR0031) //"Ano Ate"###"Invalido"
          endif
		  lRet := .F. 
       Else
          If ( Val(mv_par05) - Val(mv_par03) ) > 1 .AND. !lAutoSt
             MsgStop(STR0036+" '"+STR0032+"' "+STR0037+" '"+STR0035+"' "+STR0038) //"A diferente entre o"###"Ano De"###"e o"###"Ano Ate"###"nao pode passar de 1 ano."
             lRet := .F. 
          Endif
       Endif
          
       If mv_par02+mv_par03 > mv_par04+mv_par05 .AND. !lAutoSt
          MsgStop(STR0039) //"Mes e Ano De maior que Mes e Ano Ate"
          lRet := .F.
       Endif   

       If ( val(mv_par05) / 1000 ) < 1 .AND. !lAutoSt
          MsgStop(STR0033) //"Ano Invalido"
          lRet := .F.
       Endif   
Endif

Return(lRet)


Static Function CriaSX1()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Iniciliza variaveis                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aRegs	:=	{}
aadd(aRegs,{"PLR510","01","Operadora          ?","","","mv_ch1","C", 4,0,0,"G","","mv_par01","","","","0001","","","","","","","","","","","","","","","","","","","","","B89","","",""})
aadd(aRegs,{"PLR510","02","Mes De             ?","","","mv_ch2","C", 2,0,0,"G","PLSR510VLD(1)","mv_par02","","","","01","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR510","03","Ano De             ?","","","mv_ch3","C", 4,0,0,"G","PLSR510VLD(2)","mv_par03","","","","2005","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR510","04","Mes Ate            ?","","","mv_ch4","C", 2,0,0,"G","PLSR510VLD(3)","mv_par04","","","","12","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR510","05","Ano Ate            ?","","","mv_ch5","C", 4,0,0,"G","PLSR510VLD(4)","mv_par05","","","","2005","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR510","06","Grupo Empresa De   ?","","","mv_ch6","C", 4,0,0,"G","","mv_par06","","","","0002","","","","","","","","","","","","","","","","","","","","","B7A","","",""})
aadd(aRegs,{"PLR510","07","Grupo Empresa Ate  ?","","","mv_ch7","C", 4,0,0,"G","","mv_par07","","","","0002","","","","","","","","","","","","","","","","","","","","","B7A","","",""})
aadd(aRegs,{"PLR510","08","Contrato De        ?","","","mv_ch8","C",12,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","B7B","","",""})
aadd(aRegs,{"PLR510","09","Contrato Ate       ?","","","mv_ch9","C",12,0,0,"G","","mv_par09","","","","ZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","B7B","","",""})
aadd(aRegs,{"PLR510","10","Subcontrato De     ?","","","mv_cha","C", 9,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","B7C","","",""})
aadd(aRegs,{"PLR510","11","Subcontrato Ate    ?","","","mv_chb","C", 9,0,0,"G","","mv_par11","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","B7C","","",""})
aadd(aRegs,{"PLR510","12","Tipo Relatorio     ?","","","mv_chc","N", 1,0,0,"C","","mv_par12","Analitico","","","","","Sintetico","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR510","13","Ultimas Obs.       ?","","","mv_chd","N", 2,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza SX1                                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PlsVldPerg(aRegs)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()



//-------------------------------------------------------------------
/*/{Protheus.doc} R510WEB
Chamada do relatСrio R510INC pelo portal do beneficiario.

@author  Lucas de Azevedo Nonato
@version P11
@since   30.12.2015
/*/
//-------------------------------------------------------------------
User function R510WEB
Local cMsg := ''
PRIVATE nLimite   := 220
PRIVATE cTitulo   := '                  Extrato de Reajuste' 
PRIVATE cCabec1   := "" 
PRIVATE cCabec2   := ""	
Private cCodOpe   := Substr(PARAMIXB[1]:MATRIC,0,4)
Private cMesDe    := Iif( LEN(CVALTOCHAR(Month (PARAMIXB[1]:DTDE))) == 1, '0'+CVALTOCHAR(Month (PARAMIXB[1]:DTDE)),'0'+CVALTOCHAR(Month (PARAMIXB[1]:DTDE)))
Private cAnoDe    := CVALTOCHAR(Year (PARAMIXB[1]:DTDE) )
Private cMesAte   := Iif( LEN(CVALTOCHAR(Month (PARAMIXB[1]:DTATE))) == 1, '0'+CVALTOCHAR(Month (PARAMIXB[1]:DTATE)),'0'+CVALTOCHAR(Month (PARAMIXB[1]:DTATE)))
Private cAnoAte   := CVALTOCHAR(Year (PARAMIXB[1]:DTATE))
Private cGrupoDe  := Substr(PARAMIXB[1]:MATRIC,5,4)
Private cGrupoAte := Substr(PARAMIXB[1]:MATRIC,5,4)
Private cContDe   := '' //Retirado o mv_par08 por conta que vinha uma data, mas dentro da rotina WEB, nЦo tem nenhum mv_par08 ou parametrizaГЦo 
Private cContAte  := 'ZZZ'
Private cSubDe    := ''
Private cSubAte   := 'ZZZ'
Private nTipoRel  := 2
Private nMesObs	 := 0
Private lWeb := .T.
PRIVATE aReturn     := { STR0002, 1,STR0003, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE cRel        := "PLSR510"
PRIVATE cRelName		:= "ExtReaj"+CriaTrab(NIL,.F.) 
Private cMatric			:= Substr(PARAMIXB[1]:MATRIC,9,6)

R510Imp()

Return{cRelName+'.pdf',cMsg}

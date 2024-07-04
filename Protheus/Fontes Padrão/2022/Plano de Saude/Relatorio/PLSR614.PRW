
#INCLUDE "PROTHEUS.CH"
#IFDEF TOP
	#INCLUDE "TOPCONN.CH"
#ENDIF

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSR614 Ё Autor Ё Guilherme Brunoro      Ё Data Ё 14.11.02 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Etiquetas de Usuarios.                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Associa arquivo de definicoes                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#include "PLSMGER.CH"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define nome da funcao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSR614(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL   nTipImp     := 1 //Tipo de impressao 1-Matricial (Padrao) / 2-Laser
LOCAL	nImpBlq		:= 1 //Imprime bloqueado? 1 - NЦo (PadrЦo) / 2 - Sim

Default lAuto := .F.

PRIVATE cNomeProg   := "PLSR614"
PRIVATE nCaracter   := 220
PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := "IMPRESSAO DE ETIQUETAS DE USUARIOS"
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR614" + Space(Len(SX1->X1_GRUPO) - 6)
PRIVATE cRel        := "PLSR614"
PRIVATE nlin        := 00
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Codigo","Nome"}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nOrdSel     := ""
PRIVATE cOpeDe      // Codigo da Operadora de
PRIVATE cGrupoDe    // Codigo do Grupo/Empresa de
PRIVATE cGrupoAte   // Codigo do Grupo/Empresa ate
PRIVATE cContrDe    // Codigo do Contrato de
PRIVATE cContrAte   // Codigo do Contrato ate
PRIVATE cSbConDe    // Codigo do Sub-contrato de
PRIVATE cSbConAte   // Codigo do Sub-contrato ate
PRIVATE nTipPes     // (PF;PJ;Ambos)
PRIVATE cMatAnD	 
PRIVATE cMatAnA  
PRIVATE lImpMaA  

lAutoSt := lAuto

if !lAutoSt .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	cRel     := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
nOrdSel  := aReturn[8]

	aAlias := {"BA1"}
	objCENFUNLGP:setAlias(aAlias)

If !lAutoSt .AND. nLastKey == 27
	Return
Endif

PERGUNTE(cPerg,.F.)

intNumColunas := mv_par01
cMesNas     := mv_par02
cUsuDe      := mv_par03
cUsuAte     := mv_par04
cMunic      := mv_par05
cCepDe      := mv_par06
cCepAte     := mv_par07

cOpeDe     	:= mv_par08
cGrupoDe   	:= mv_par09 
cGrupoAte  	:= mv_par10 
cContrDe   	:= mv_par11 
cContrAte  	:= mv_par12 
cSbConDe   	:= mv_par13
cSbConAte  	:= mv_par14
nTipPes		:= mv_par15
cMatAnD	 	:= mv_par16
cMatAnA  	:= mv_par17
lImpMaA  	:= If(mv_par18==1,.t.,.f.)
nTipImp     := mv_par19
nImpBlq		:= mv_par20

cSQL := " SELECT BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_NOMUSR,BA1_ENDERE,BA1_COMEND, "
cSQL += " BA1_BAIRRO,BA1_TELEFO,BA1_MUNICI,BA1_ESTADO,BA1_CEPUSR,BA1_MATANT,BA1_NR_END "
cSQL += " FROM "+RetSQLName("BA1")+" "
cSQL += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSQL += " BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO >= '"+cUsuDe+"' "
cSQL += " AND BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO <= '"+cUsuAte+"' "
cSQL += Iif(nImpBlq == 2," AND (BA1_DATBLO = ' ' AND BA1_MOTBLO = ' ') ","")
cSql += "AND D_E_L_E_T_ = ' '"

If ! Empty(cMesNas)
	cSQL += " AND SUBSTRING(BA1_DATNAS,5,2) = '"+cMesNas+"'"
EndIf
If ! Empty(cCepDe) .AND. ! Empty(cCepAte)
	cSQL += " AND BA1_CEPUSR >= '"+cCepDe+"'"   +  " AND BA1_CEPUSR <= '"+cCepAte+"' "
EndIf
If ! Empty(cMunic)
	cSQL += " AND BA1_MUNICI LIKE '" + Alltrim(cMunic) + "%' "
Endif

If !Empty(cMatAnA)
	cSQL += " AND BA1_MATANT >= '"+cMatAnD+"' AND BA1_MATANT <= '"+cMatAnA+"' "
Endif

cSQL += " AND BA1_CODINT >= '"+cOpeDe+"' AND         "
cSQL += "BA1_CODEMP >= '"+cGrupoDe+"' AND       " 
cSQL += "BA1_CODEMP <= '"+cGrupoAte+"' "

If nTipPes == 2 // Pessoa Juridica
  cSQL += " AND BA1_CONEMP >= '"+cContrDe+"'    " 
  cSQL += " AND BA1_CONEMP <= '"+cContrAte+"'   " 
  cSQL += " AND BA1_SUBCON >= '"+cSbConDe+"'    " 
  cSQL += " AND BA1_SUBCON <= '"+cSbConAte+"'   " 
  cSQL += " AND BA1_CONEMP <> ''   "   
  cSQL += " AND BA1_SUBCON <> ''   "     
Elseif nTipPes == 1 // Pessoa Fisica
  cSQL += " AND BA1_CONEMP = ''   "   
  cSQL += " AND BA1_SUBCON = ''   "   
Elseif nTipPes == 3 // Ambos
  cSQL += " AND ((BA1_CONEMP >= '"+cContrDe+"' AND BA1_CONEMP <= '"+cContrAte+"') OR BA1_CONEMP = ' ' )"
  cSQL += " AND ((BA1_SUBCON >= '"+cSbConDe+"' AND BA1_SUBCON <= '"+cSbConAte+"') OR BA1_SUBCON = ' ' )" 
EndIf


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se houver filtro executa parse para converter expressoes adv para SQL    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If TranSql(aReturn[7]) > "" 
   cSQL += " AND (" + TranSql(aReturn[7]) + ")"
Endif                                          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё De acordo com a ordem....                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If      nOrdSel == 1
	cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG"
ElseIf  nOrdSel == 2
	cSQL += " ORDER BY BA1_NOMUSR"
Endif
PLSQUERY(cSQL,"ETQ")

dbSelectArea("ETQ")

if !lAutoSt
	SetDefault(aReturn,"BA1")
endif

If !lAutoSt .AND. nLastKey == 27
    ETQ->(DbCloseArea())
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo,nLin,nTipImp) },cTitulo)
else
	RunReport(cCabec1,cCabec2,cTitulo,nLin,nTipImp)
endif

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Fun┤└o    ЁRUNREPORT ╨ Autor Ё Brunoro            ╨ Data Ё  14/11/02   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descri┤└o Ё Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ╨╠╠
╠╠╨          Ё monta a janela com a regua de processamento.               ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Programa principal                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,nTipImp)
Local i,j     
Default nTipImp := 1
//Local nOrdem
dbSelectArea("ETQ")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё SETA A IMPRESSORA PARA A POSICAO zero                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	setprc(0,0)
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ILinha := 0
IErros := 0

DbGoTop()
While !EOF()
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quebra pagina para impressao caso nao seja impressora matricial     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
	If nTipImp == 2 .And. (nLin > nQtdLin)  
       nLin := 0
    EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica o cancelamento pelo usuario...                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAutoSt .AND. lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime o Corpo do Boleto										   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ColIni := 0
	//nLin   += 0
	I := 1
	J := 0
	
    Lin := Array(6,intNumColunas)
	WHILE I <= intNumColunas
		If !lImpMaA
			Lin[1,I]:= Substr(("CODIGO : " +objCENFUNLGP:verCamNPR("BA1_CODINT",ETQ->BA1_CODINT)+"-"+;
								objCENFUNLGP:verCamNPR("BA1_CODEMP",ETQ->BA1_CODEMP)+"-"+;
								objCENFUNLGP:verCamNPR("BA1_MATRIC",ETQ->BA1_MATRIC)+"-"+;
								objCENFUNLGP:verCamNPR("BA1_TIPREG",ETQ->BA1_TIPREG)),1,42)
		Else
			Lin[1,I]:= Substr(("CODIGO : " + objCENFUNLGP:verCamNPR("BA1_MATANT",ETQ->BA1_MATANT)),1,42)
		Endif
		Lin[2,I]:= Substr(objCENFUNLGP:verCamNPR("BA1_NOMUSR",ETQ->BA1_NOMUSR),1,42)
		Lin[3,I]:= Substr(Alltrim(objCENFUNLGP:verCamNPR("BA1_ENDERE",ETQ->BA1_ENDERE))+", ",1,42) + Alltrim(objCENFUNLGP:verCamNPR("BA1_NR_END",ETQ->BA1_NR_END))
		If !Empty(ETQ->BA1_COMEND)
			Lin[4,I]:= Substr("Complemento:" + Alltrim(objCENFUNLGP:verCamNPR("BA1_COMEND",ETQ->BA1_COMEND)),1,42)
			Lin[5,I]:= Substr(AllTrim(objCENFUNLGP:verCamNPR("BA1_BAIRRO",ETQ->BA1_BAIRRO))+" - "+;
							 AllTrim(objCENFUNLGP:verCamNPR("BA1_MUNICI",ETQ->BA1_MUNICI)),1,42)
			Lin[6,I]:= 	Substr(objCENFUNLGP:verCamNPR("BA1_ESTADO",ETQ->BA1_ESTADO)+"  CEP:"+;
						Subst(objCENFUNLGP:verCamNPR("BA1_CEPUSR",ETQ->BA1_CEPUSR),1,5)+"-"+;
						Subst(objCENFUNLGP:verCamNPR("BA1_CEPUSR",ETQ->BA1_CEPUSR),6,3),1,42)
		Else
			Lin[4,I]:= Substr(AllTrim(objCENFUNLGP:verCamNPR("BA1_BAIRRO",ETQ->BA1_BAIRRO))+" - "+;
							 AllTrim(objCENFUNLGP:verCamNPR("BA1_MUNICI",ETQ->BA1_MUNICI)),1,42)
			Lin[5,I]:= 	Substr(objCENFUNLGP:verCamNPR("BA1_ESTADO",ETQ->BA1_ESTADO)+"  CEP:"+;
						Subst(objCENFUNLGP:verCamNPR("BA1_CEPUSR",ETQ->BA1_CEPUSR),1,5)+"-"+;
						Subst(objCENFUNLGP:verCamNPR("BA1_CEPUSR",ETQ->BA1_CEPUSR),6,3),1,42)
		EndIf
		DBSKIP()
		I += 1
		IF EOF()
			I = 3 + 1
		ENDIF
	ENDDO
	I:= 0
	For J := 1 to 6
		FOR I := 1 TO intNumColunas
			ColIni := (I-1) * 73
			@nLin,ColIni PSAY Lin[J,I]
		Next I
		nLin += 1
	Next J
	nLin += 1
	
EndDO

If !lAutoSt .AND. aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(cRel)
Endif

ETQ->(DbCloseArea())

Return

Static Function TranSql(Par1)
Par1 := UPPER(par1)
Par1 := StrTran(Par1,".AND."," AND ")
Par1 := StrTran(Par1,".OR."," OR ")
Par1 := StrTran(Par1,"==","=")
Par1 := StrTran(Par1,"ALLTRIM"," ")
Par1 := StrTran(Par1,'"',"'")
Return Par1

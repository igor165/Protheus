#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lautost := .F.

/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLR097    ºAutor  ³Alex Faria          º Data ³13/06/03     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relacao de Valores de Sub-Contrato X Faixa etaria X Adesao  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ºAlteracoes³ Tulio Cesar em 18-08-2003 -> Ajustes p/ suporte contratos  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSR097(lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lauto := .F.

PRIVATE cString   := "BQC"
PRIVATE cDesc1    := "Listagem de Valores  "
PRIVATE cDesc2    := "Sub-Contrato X Faixa Etaria X Adesao "
PRIVATE cDesc3    := ""
PRIVATE limite    := 132
PRIVATE tamanho   := "M"
PRIVATE aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nomeprog  := "PLR097"
PRIVATE aLinha    := {}
PRIVATE nLastKey  := 0
PRIVATE titulo    := "Listagem de Valores por Sub-Contrato X Faixa Etaria X Adesao"
//PRIVATE Cabec1    := "Operadora         Cod. Contrato"
//PRIVATE cabec2    := "Cod.Sub-Contrato         Desc. Sub-Contrato                         Dt. Sub-Contrato              Versao Sub-Contrato"
//PRIVATE cabec1    := "          Prod  Descricao                                                         Versao  Dep.   Sexo     Faixa                Valor"
PRIVATE cabec1    := "          Prod  Descricao                                                         Versao  Dep.       Faixa    Qtd Usr.    Valor"
PRIVATE cabec2    := ""
PRIVATE cCancel   := "***** CANCELADO PELO OPERADOR *****"
PRIVATE m_pag     := 1  // numero da pagina
PRIVATE cPerg     := "PLR097"   
PRIVATE pag       := 1
PRIVATE li        := 80
PRIVATE wnRel     := "PLR097"
PRIVATE lAbortPrint := .F.                                                    

lautost := lauto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lauto
	wnRel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
endif
	aAlias := {"BQC","BG9","BTN","BI3","BR6","BA1"}
	objCENFUNLGP:setAlias(aAlias)

If !lauto .AND. nLastKey == 27
    Set Filter To
    Return
Endif

if !lauto
	SetDefault(aReturn,cString)
endif

If !lauto .ANd. nLastKey == 27
    Set Filter To
    Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Parametros com Pergunte PLR097                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("PLR097",.F.)

pOperDe    	:= mv_par01
pGrupoDe   	:= mv_par02
pGrupoAte  	:= mv_par03
pContrDe   	:= mv_par04
pContrAte  	:= mv_par05
pSubConDe  	:= mv_par06
pSubConAte 	:= mv_par07
pVersaoDe  	:= mv_par08
pVersaoAte 	:= mv_par09 
pSituac    	:= mv_par10
dDatRef		:= mv_par11

//RptStatus({|| PLR097IMP() })// Substituido pelo assistente de conversao do AP5 IDE em 31/07/00 ==>     RptStatus({|| Execute(Etiqueta) })
if !lauto
	MsAguarde( {|| PLR097IMP(dDatRef)}, "Listagem de Valores por Sub-Contrato","",.T.)
else
	PLR097IMP(dDatRef)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera spool de impressao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !lauto
	Roda(0,"","M")
	Set Filter To
endif

If !lauto .AND. aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)    // Chamada do Spool de Impressao
Endif

if !lauto
	MS_FLUSH()             // Libera fila de relatorios em spool
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PLR097IMP ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do corpo do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                               
Static Function PLR097IMP(dDatRef)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aCount    := 0
LOCAL aTotCon   := 0
LOCAL aTotSub   := 0
LOCAL aQtd      := 0
LOCAL aContrato := ""
LOCAL aSubContr := ""
LOCAL aLinAtu   := 0
LOCAL aIdadeUsr := {}
LOCAL nQtdUsr   := 0 
Local nIndIda	:= 0
Local cMvCOMP := GetMv("MV_COMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Query no Arquivo BQC(CADASTRO SUB-CONTRATO) e BT5(GRUPO EMPRESA X CONTRATOS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !lautost
	MsProcTxt("Processando Arquivo de Sub-Contrato...")
endif

aQuery := " SELECT BQC_CODINT, BQC_CODIGO, BQC_NUMCON, BQC_VERCON, "
aQuery += " BQC_SUBCON, BQC_VERSUB,  BQC_DESCRI, BQC_CODINT, "
aQuery += " SUBSTRING(BQC_DATCON,7,2)+'/'+SUBSTRING(BQC_DATCON,5,2)+'/'+SUBSTRING(BQC_DATCON,1,4) BQC_DATCON "
aQuery += " FROM "+RetSqlName("BQC")
aQuery += " WHERE "
aQuery += " BQC_CODINT = '"+mv_Par01+"' AND "
aQuery += " BQC_CODIGO >= '"+mv_par01+mv_Par02+"' AND "
aQuery += " BQC_CODIGO <= '"+mv_par01+mv_par03+"' AND "
aQuery += " BQC_NUMCON >= '"+mv_Par04+"' AND "
aQuery += " BQC_NUMCON <= '"+mv_par05+"' AND "
aQuery += " BQC_SUBCON >= '"+mv_par06+"' AND "
aQuery += " BQC_SUBCON <= '"+mv_par07+"' AND "
aQuery += " BQC_VERSUB >= '"+mv_par08+"' AND "
aQuery += " BQC_VERSUB <= '"+mv_Par09+"' AND "

If pSituac == 2 //ativos
   aQuery += " BQC_CODBLO = '' AND "   
ElseIf pSituac == 3 //bloqueados
   aQuery += " BQC_CODBLO <> '' AND "   
Endif   

aQuery += " D_E_L_E_T_ = '' "

If ! Empty(aReturn[7])
     aQuery += " AND " + ParSQL(Upper(aReturn[7]))
Endif                            

aQuery += " ORDER BY BQC_CODIGO, BQC_NUMCON, BQC_SUBCON, BQC_VERSUB "

PLSQuery(aQuery,"QRA")

DbSelectArea("QRA")

QRA->(DbGotop())

If !lautost .AND. li >= 58
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
EndIf

@ li,000 Psay "Operadora: "+	objCENFUNLGP:verCamNPR("BQC_CODINT",QRA->BQC_CODINT)+;
			"  Grupo Empresa: "+objCENFUNLGP:verCamNPR("BQC_CODIGO",Subs(QRA->BQC_CODIGO,5,4))+" "+;
								objCENFUNLGP:verCamNPR("BG9_DESCRI",Subs(BG9->BG9_DESCRI,1,71))+;
			"  Contrato: "+		objCENFUNLGP:verCamNPR("BQC_NUMCON",QRA->BQC_NUMCON)
li++

@ li,000 Psay "Sub-Contrato: "
@ li,014 Psay objCENFUNLGP:verCamNPR("BQC_SUBCON",QRA->BQC_SUBCON)
@ li,025 Psay objCENFUNLGP:verCamNPR("BQC_DESCRI",Substr(QRA->BQC_DESCRI,1,27))
@ li,095 Psay "Dt Sub-Contrato: "
@ li,112 Psay objCENFUNLGP:verCamNPR("BQC_DATCON",QRA->BQC_DATCON)
@ li,121 Psay "Versao: "
@ li,129 Psay objCENFUNLGP:verCamNPR("BQC_VERSUB",QRA->BQC_VERSUB)
li+=2
                                  
aContrato := QRA->(BQC_CODIGO+BQC_NUMCON)
aSubContr := QRA->BQC_SUBCON

aTotCon := aTotCon + 1
aTotSub := aTotSub + 1

While ! QRA->(EOF())
	if !lautost
		MsProcTxt("Imprimindo Valores do Sub-Contrato - "+objCENFUNLGP:verCamNPR("BQC_NUMCON",QRA->BQC_NUMCON))
	endif
	li++
	If !lautost .AND. Interrupcao(lAbortPrint)
		@ li,000 pSay "ABORTADO PELO USUARIO"
		Exit
	Endif
	
	If !lautost .ANd. Li >= 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
	Endif
	
	If aContrato <> QRA->(BQC_CODIGO+BQC_NUMCON)
		aLinAtu := li + 6
		
		If !lautost .AND. aLinAtu >= 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
		EndIf
		
		If !lautost .AND. li >= 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
		EndIf

		BG9->( dbSetorder(01) )
		BG9->( dbSeek(xFilial("BG9")+QRA->BQC_CODINT+Subs(QRA->BQC_CODIGO,5,4)) )
		
		@ li,000 Psay "Operadora: "+objCENFUNLGP:verCamNPR("BQC_CODINT",QRA->BQC_CODINT)+;
				"  Grupo Empresa: "+objCENFUNLGP:verCamNPR("BQC_CODIGO",Subs(QRA->BQC_CODIGO,5,4))+" "+;
									objCENFUNLGP:verCamNPR("BG9_DESCRI",Subs(BG9->BG9_DESCRI,1,71))+;
					"  Contrato: " +objCENFUNLGP:verCamNPR("BQC_NUMCON",QRA->BQC_NUMCON)
		li++

		@ li,000 Psay "Sub-Contrato: "
		@ li,014 Psay objCENFUNLGP:verCamNPR("BQC_SUBCON",QRA->BQC_SUBCON)
		@ li,025 Psay objCENFUNLGP:verCamNPR("BQC_DESCRI",Substr(QRA->BQC_DESCRI,1,27))
		@ li,095 Psay "Dt Sub-Contrato: "
		@ li,112 Psay objCENFUNLGP:verCamNPR("BQC_DATCON",QRA->BQC_DATCON)
		@ li,121 Psay "Versao: "
		@ li,129 Psay objCENFUNLGP:verCamNPR("BQC_VERSUB",QRA->BQC_VERSUB)
		li+=2
		
		aContrato := QRA->(BQC_CODIGO+BQC_NUMCON)
		aSubContr := QRA->BQC_SUBCON
		
		aTotCon := aTotCon + 1
		aTotSub := aTotSub + 1
	Endif
	
	If aSubContr <> QRA->BQC_SUBCON
		li++
		@ li,000 Psay "Sub-Contrato: "
		@ li,014 Psay objCENFUNLGP:verCamNPR("BQC_SUBCON",QRA->BQC_SUBCON)
		@ li,025 Psay objCENFUNLGP:verCamNPR("BQC_DESCRI",Substr(QRA->BQC_DESCRI,1,27))
		@ li,095 Psay "Dt Sub-Contrato: "
		@ li,112 Psay objCENFUNLGP:verCamNPR("BQC_DATCON",QRA->BQC_DATCON)
		@ li,121 Psay "Versao: "
		@ li,129 Psay objCENFUNLGP:verCamNPR("BQC_VERSUB",QRA->BQC_VERSUB)
		li+=2
		aTotSub := aTotSub + 1
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query no Arquivo BTN - VALORES DE FAIXA ETARIA                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	xQuery := " SELECT COUNT(*) QTD FROM "+RetSqlName("BTN")
	xQuery += " WHERE "
	xQuery += " BTN_CODIGO = '"+QRA->BQC_CODIGO+"' AND "
	xQuery += " BTN_NUMCON = '"+QRA->BQC_NUMCON+"' AND "
	xQuery += " BTN_SUBCON = '"+QRA->BQC_SUBCON+"' AND "
	xQuery += " BTN_VERSUB = '"+QRA->BQC_VERSUB+"' AND "
	xQuery += " D_E_L_E_T_ = '' "
	
	If ! Empty(aReturn[7])
		xQuery += " AND " + ParSQL(Upper(aReturn[7]))
	Endif
	
	PLSQuery(xQuery,"TRA")
	DbSelectArea("TRA")
	aQtd := TRA->QTD
	TRA->(DbCloseArea())
	
	If aQtd > 0
		bQuery := " SELECT BTN_CODIGO, BTN_NUMCON, BTN_VERCON, BTN_CODPRO, BTN_VERPRO, "
		bQuery += " BTN_SUBCON, BTN_VERSUB, BTN_TIPUSR, BTN_SEXO, BTN_IDAINI, "
		bQuery += " BTN_IDAFIN, BTN_VALFAI, BTN_CODFAI  "
		bQuery += " FROM "+RetSqlName("BTN")
		bQuery += " WHERE "
		bQuery += " BTN_CODIGO = '"+QRA->BQC_CODIGO+"' AND "
		bQuery += " BTN_NUMCON = '"+QRA->BQC_NUMCON+"' AND "
		bQuery += " BTN_SUBCON = '"+QRA->BQC_SUBCON+"' AND "
		bQuery += " BTN_VERSUB = '"+QRA->BQC_VERSUB+"' AND "
		bQuery += " D_E_L_E_T_ = '' "
		
		If ! Empty(aReturn[7])
			bQuery += " AND " + ParSQL(Upper(aReturn[7]))
		Endif
		
		bQuery += " ORDER BY BTN_NUMCON, BTN_VERSUB, BTN_CODPRO, BTN_VERPRO, BTN_TIPUSR, BTN_SEXO, BTN_IDAINI " //AQUI
		
		PlSQuery(bQuery,"QRB")
		
		DbSelectArea("QRB")
		
		aLinAtu := li + 3 //5
		
		If !lautost .AND. aLinAtu >= 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
		Endif

		While !QRB->(EOF())
			
			cCodPro := QRB->BTN_CODPRO
			cVerPro := QRB->BTN_VERPRO
			lTxt	:= .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a quantidade de usuarios por faixa etaria do produto...                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			cSql := "SELECT BA1_DATNAS,BA1_TIPUSU FROM "+RetSqlName("BA1")+" BA1, "+RetSqlName("BA3")+" BA3 WHERE "
				cSql += " BA1_CODINT = BA3_CODINT AND "
				cSql += " BA1_CODEMP = BA3_CODEMP AND "
				cSql += " BA1_MATRIC = BA3_MATRIC AND "
				cSql += " BA1_CODINT = '"+Substr(QRA->BQC_CODIGO,1,4)+"' AND "
				cSql += " BA1_CODEMP = '"+Substr(QRA->BQC_CODIGO,5,4)+"' AND "				
				cSql += " BA1_CONEMP = '"+QRA->BQC_NUMCON+"' AND "
				cSql += " BA1_VERCON = '"+QRA->BQC_VERCON+"' AND "
				cSql += " BA1_SUBCON = '"+QRA->BQC_SUBCON+"' AND "
				cSql += " BA1_VERSUB = '"+QRA->BQC_VERSUB+"' AND "
				cSql += " (BA1_DATBLO = '        ' or BA1_DATBLO > '"+dTos(dDatRef)+"' ) AND "
				cSql += " BA1_DATINC <= '"+dTos(dDatRef)+"' AND "
				cSql += " BA3_CODPLA = '"+cCodPro+"' AND "
				cSql += " BA3_VERSAO = '"+cVerPro+"' AND "
				cSql += " BA1.D_E_L_E_T_ = ' ' AND "
				cSql += " BA3.D_E_L_E_T_ = ' ' ORDER BY BA1_TIPUSU, BA1_DATNAS"
			PlsQuery(cSql, "TRBBA1")
			
			TRBBA1->( dbEval( {|| Aadd(aIdadeUsr, {TRBBA1->BA1_DATNAS,Calc_Idade(dDatRef,TRBBA1->BA1_DATNAS),TRBBA1->BA1_TIPUSU}) }) )
			TRBBA1->( dbClosearea() )
						
			While !QRB->(EOF()) .and. QRB->BTN_CODPRO == cCodPro .and. QRB->BTN_VERPRO == cVerPro
				If !lautost .AND. li >= 58
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
					lTxt := .T.
				EndIf
				               
				If lTxt
					@ li,000 Psay "Fx Etaria"
					@ li,010 Psay objCENFUNLGP:verCamNPR("BTN_CODPRO",QRB->BTN_CODPRO)
					@ li,016 Psay objCENFUNLGP:verCamNPR("BI3_DESCRI",Posicione("BI3",1,xFilial("BI3")+Substr(QRB->BTN_CODIGO,1,4)+QRB->BTN_CODPRO+QRB->BTN_VERPRO,"BI3_DESCRI"))
					@ li,082 Psay objCENFUNLGP:verCamNPR("BTN_VERPRO",Alltrim(QRB->BTN_VERPRO))
					lTxt := .F.
				Endif	

				cTipUsu	:= ""
				aAux 	:= {}
				For nIndIda := 1 To Len(aIdadeUsr)
					If aIdadeUsr[nIndIda][2] >= QRB->BTN_IDAINI .And. aIdadeUsr[nIndIda][2] <= QRB->BTN_IDAFIN
						If cTipUsu <> aIdadeUsr[nIndIda][3]
							cTipUsu	:= 	aIdadeUsr[nIndIda][3]
							aadd(aAux,{cTipUsu,1})
						Else
							aAux[Len(aAux),2]++
						EndIf
					EndIf
					
				Next nIndIda
				nIndIda := 0

				For nIndIda := 1 To Len(aAux)
					@ li,092 Psay objCENFUNLGP:verCamNPR("BA1_TIPUSU",aAux[nIndIda,1])
					@ li,099 Psay objCENFUNLGP:verCamNPR("BTN_IDAINI",Strzero(QRB->BTN_IDAINI,3))
					@ li,104 Psay "-"
					@ li,106 Psay objCENFUNLGP:verCamNPR("BTN_IDAFIN",Strzero(QRB->BTN_IDAFIN,3))													
					@ li,116 Psay Transform(aAux[nIndIda,2], "@ 9999")
					@ li,122 Psay objCENFUNLGP:verCamNPR("BTN_VALFAI",QRB->BTN_VALFAI) Picture "@E 999,999.99"				
					li++
				Next nIndIda
				
				nQtdUsr := 0 
				QRB->(DbSkip())
			Enddo
			aIdadeUsr := {}
			li++
		Enddo
		
		QRB->(DBCloseArea())
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query no Arquivo BR6 - VALORES DE ADESAO                                    ³
	//³Listagem dos Valores de Adesao dos Sub-Contratos                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xQuery := " SELECT COUNT(*) QTD "
	xQuery += " FROM "+RetSqlName("BR6")
	xQuery += " WHERE "
	xQuery += " BR6_CODIGO = '"+QRA->BQC_CODIGO+"' AND "
	xQuery += " BR6_NUMCON = '"+QRA->BQC_NUMCON+"' AND "
	xQuery += " BR6_SUBCON = '"+QRA->BQC_SUBCON+"' AND "
	xQuery += " BR6_VERSUB = '"+QRA->BQC_VERSUB+"' AND "
	xQuery += " D_E_L_E_T_ = '' "
	
	If ! Empty(aReturn[7])
		xQuery += " AND " + ParSQL(Upper(aReturn[7]))
	Endif
	
	PlsQuery(xQuery,"TRB")
	
	DbSelectArea("TRB")
	aQtd := TRB->QTD
	TRB->(DbCloseArea())
	
	If aQtd > 0
		cQuery := " SELECT BR6_CODIGO, BR6_NUMCON,BR6_VERCON, BR6_SUBCON, BR6_VERSUB, BR6_CODFAI, "
		cQuery += " BR6_TIPUSR, BR6_VLRADE, BR6_SEXO, BR6_IDAINI, BR6_IDAFIN, BR6_CODPRO, BR6_VERPRO "
		cQuery += " FROM "+RetSqlName("BR6")
		cQuery += " WHERE "
		cQuery += " BR6_CODIGO = '"+QRA->BQC_CODIGO+"' AND "
		cQuery += " BR6_NUMCON = '"+QRA->BQC_NUMCON+"' AND "
		cQuery += " BR6_SUBCON = '"+QRA->BQC_SUBCON+"' AND "
		cQuery += " BR6_VERSUB = '"+QRA->BQC_VERSUB+"' AND "
		cQuery += " D_E_L_E_T_ = '' "
		
		If ! Empty(aReturn[7])
			cQuery += " AND " + ParSQL(Upper(aReturn[7]))
		Endif
		
		cQuery += " ORDER BY BR6_NUMCON, BR6_VERSUB, BR6_CODPRO, BR6_VERPRO, BR6_TIPUSR, BR6_SEXO, BR6_IDAINI " //AQUI
		
		PLSQuery(cQuery,"QRC")
		
		DbSelectArea("QRC")
		
		aLinAtu := li + 3
		
		If !lautost .AND. aLinAtu >= 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
		Endif
		While ! QRC->(EOF())            
			
			cCodPro := QRC->BR6_CODPRO
			cVerPro := QRC->BR6_VERPRO
			lTxt    := .T.
			While !QRC->( Eof() ) .and. QRC->BR6_CODPRO == cCodPro .and. QRC->BR6_VERPRO == cVerPro
				If !lautost .AND. li >= 58
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
					lTxt := .T.
				EndIf
				If lTxt
					@ li,000 Psay "Tx Adesao"
					@ li,010 Psay objCENFUNLGP:verCamNPR("BR6_CODPRO",QRC->BR6_CODPRO)
					@ li,016 Psay objCENFUNLGP:verCamNPR("BI3_DESCRI",Posicione("BI3",1,xFilial("BI3")+Substr(QRC->BR6_CODIGO,1,4)+QRC->BR6_CODPRO+QRC->BR6_VERPRO,"BI3_DESCRI"))
					@ li,082 Psay objCENFUNLGP:verCamNPR("BR6_VERPRO",QRC->BR6_VERPRO)
					lTxt := .F.
				Endif
				
				@ li,092 Psay objCENFUNLGP:verCamNPR("BR6_TIPUSR",QRC->BR6_TIPUSR)
				@ li,097 Psay IIf (Alltrim(QRC->BR6_SEXO) = ""," ",objCENFUNLGP:verCamNPR("BR6_SEXO",X3Combo("BR6_SEXO",QRC->BR6_SEXO)))
				@ li,106 Psay objCENFUNLGP:verCamNPR("BR6_IDAINI",Strzero(QRC->BR6_IDAINI,3))
				@ li,111 Psay "-"
				@ li,113 Psay objCENFUNLGP:verCamNPR("BR6_IDAFIN",Strzero(QRC->BR6_IDAFIN,3))
				@ li,122 Psay QRC->BR6_VLRADE Picture "@E 999,999.99"
								
				li++
				QRC->(DbSkip())
			Enddo
			li++
		Enddo
		li++
		
		QRC->(DBCloseArea())
	Endif
	QRA->(DbSkip())
Enddo

QRA->(DBCLOSEAREA())

aLinAtu := li + 4

If !lautost .AND. aLinAtu >= 58
   cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))       
Endif   

@ li,039 Psay Replicate("-",48)
li++
@ li,039 Psay "|     Total de Contratos Impressos     ="
@ li,081 Psay aTotCon
@ li,086 Psay "|"
li++
@ li,039 Psay "|     Total de Sub-Contratos Impressos ="
@ li,081 Psay aTotSub
@ li,086 Psay "|"
li++
@ li,039 Psay Replicate("-",48)

Return

Static Function ParSQL(cFilADV)
 
cFilADV := StrTran(cFilADV,".AND."," AND ")
cFilADV := StrTran(cFilADV,".OR."," OR ")
cFilADV := StrTran(cFilADV,"=="," = ")
cFilADV := StrTran(cFilADV,'"',"'")
cFilADV := StrTran(cFilADV,'$'," IN ")
cFilADV := StrTran(cFilADV,"ALLTRIM","  ")
 
Return(cFilADV)

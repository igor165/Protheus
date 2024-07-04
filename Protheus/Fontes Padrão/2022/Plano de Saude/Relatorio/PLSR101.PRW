#include "rwmake.ch"
#include "TOPCONN.CH"
#include "PROTHEUS.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lautoSt := .F.

/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR101   ºAutor  ³Alex Faria          º Data ³19/06/2003   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista Familia/Usuarios por Empresa Conforme Selecao nos     º±±
±±º          ³Parametros                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSR101(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lAuto := .F.

PRIVATE cString   := "BA3"
PRIVATE cDesc1    := "Listagem de Familia/Usuario por Empresa"
PRIVATE cDesc2    := ""
PRIVATE cDesc3    := ""
PRIVATE limite    := 132
PRIVATE tamanho   := "M"
PRIVATE aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nomeprog  := "PLSR101"
PRIVATE aLinha    := {}
PRIVATE nLastKey  := 0
PRIVATE Titulo    := "Listagem de Familia/Usuario por Empresa"
PRIVATE Cabec1    := "Cod. Operadora      Grupo/Empresa                                               Cod. Contrato            Cod. Sub-Contrato"
PRIVATE Cabec2    := "Cod. Familia         Bl Nome Usuario                    Tp. Dep     Sexo       Est.Civil       CPF Usuario     Dt.Incl.   Dt. Nasc."
PRIVATE cCancel   := "***** CANCELADO PELO OPERADOR *****"
PRIVATE m_pag     := 1  // numero da pagina
PRIVATE cPerg     := "PLR101"   
PRIVATE pag       := 1
PRIVATE li        := 80
PRIVATE wnRel     := "PLSR101"
PRIVATE lAbortPrint := .F.
PRIVATE cMatAnD	  
PRIVATE cMatAnA    
PRIVATE lImpMaA    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lautoSt := lAuto

if !lautoSt
	wnRel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
endif
	aAlias := {"BA3","BA1"}
	objCENFUNLGP:setAlias(aAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Parametros com Pergunte PLSR101                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("PLR101",.F.)

dDatBas    := mv_par11
cMatAnD	   := mv_par12
cMatAnA    := mv_par13
lImpMaA    := If(mv_par14==1,.t.,.f.)

If !lautoSt .ANd. nLastKey == 27
    Set Filter To
    Return
Endif

if !lautoSt
	SetDefault(aReturn,cString)
endif

if !lautoSt
	MsAguarde({|| PLSR101IMP() }, "Listagem de Familia/Usuario", "", .T.)
else
	PLSR101IMP()
endif

If !lautoSt .AND. nLastKey == 27
    Set Filter To
    Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera spool de impressao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lautoSt
	Roda(0,"","M")
endif

if !lautoSt
	Set Filter To
endif

If !lautoSt .AND. aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)    // Chamada do Spool de Impressao
Endif

if !lautoSt
	MS_FLUSH()             // Libera fila de relatorios em spool
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PLSR101IMP ³ Autor ³                       ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Prepara Relatorio para Ser Impresso                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                               
Static Function PLSR101IMP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL aTotEmp    := 0
LOCAL aTotUsr    := 0
LOCAL aEmpr      := 0
LOCAL aQtdFam    := 0
LOCAL aQtdUsr    := 0
LOCAL dDatBas    := mv_par11
LOCAL LPAR11VZIO := IIF( EMPTY(mv_par11), .T., .F.)
Local cMvCOMP := GetMv("MV_COMP")

if !lautoSt
	MsProcTxt("Processado Arquivos de Familia ...")
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Query no Arquivo BA3(CADASTRO DE FAMILIA)                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aQuery := " SELECT BA3_CODINT, BA3_CODEMP, BA3_CONEMP, BA3_SUBCON, BA3_MATRIC, BA3_TIPCON, BA3_MOTBLO, BA3_MATANT,"
aQuery += " SUBSTRING(BA3_DATCON,7,2)+'/'+SUBSTRING(BA3_DATCON,5,2)+'/'+SUBSTRING(BA3_DATCON,1,4) BA3_DATCON "
aQuery += " FROM " +RetSqlName("BA3")
aQuery += " WHERE "
aQuery += " BA3_CODINT =  '"+mv_par01+"' AND "

aQuery += " BA3_CODEMP >= '"+mv_par02+"' AND "
aQuery += " BA3_CODEMP <= '"+mv_par03+"' AND "

aQuery += " BA3_MATRIC >= '"+mv_par04+"' AND "
aQuery += " BA3_MATRIC <= '"+mv_par05+"' AND "

aQuery += " BA3_CONEMP >= '"+mv_par06+"' AND "
aQuery += " BA3_CONEMP <= '"+mv_par07+"' AND "

aQuery += " BA3_SUBCON >= '"+mv_par08+"' AND "
aQuery += " BA3_SUBCON <= '"+mv_par09+"' AND "

If !LPAR11VZIO
	aQuery += "	BA3_DATBAS <='"+DTOS(dDatBas)+"' AND "
EndIf                          

If !Empty(cMatAnA)	
	aQuery += " BA3_MATANT >= '"+cMatAnD+"' AND "
	aQuery += " BA3_MATANT <= '"+cMatAnA+"' AND "	
Endif

aQuery += " D_E_L_E_T_ = '' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona Registros de Familia Bloqueados ou Nao Conforme Pergunte                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par10 = 2   // BLOQUEADOS

   aQuery += "AND (BA3_DATBLO <> '   ' AND BA3_DATBLO <='"+DTOS(dDatBas)+"') "

Elseif mv_par10 = 3 //ATIVOS

   aQuery += "AND (BA3_DATBLO = '   ' OR BA3_DATBLO >'"+DTOS(dDatBas)+"') "

Endif     

If ! Empty(aReturn[7])
     aQuery += " AND " + ParSQL(Upper(aReturn[7]))
Endif                            

aQuery += " ORDER BY  BA3_CODINT,BA3_CODEMP,  BA3_CONEMP, BA3_SUBCON, BA3_MATRIC "

PLSQuery(aQuery,"QRA")

DbSelectArea("QRA")

If  li >= 58
    cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
EndIf

aEmpr := Substr(Posicione("BG9",1,xFilial("BG9")+QRA->BA3_CODINT+QRA->BA3_CODEMP,"BG9_DESCRI"),1,28)//+QRA->BA3_TIPCON,"BG9_DESCRI"),1,28)

@ li,000 Psay "Operadora.:"
@ li,012 Psay objCENFUNLGP:verCamNPR("BA3_CODINT",QRA->BA3_CODINT)
@ li,021 Psay "Grupo/Empresa.:"
@ li,038 Psay objCENFUNLGP:verCamNPR("BA3_CODEMP",QRA->BA3_CODEMP)
@ li,045 Psay objCENFUNLGP:verCamNPR("BA3_CODINT",objCENFUNLGP:verCamNPR("BA3_CODEMP",aEmpr))
@ li,081 Psay "Contrato.:"
@ li,092 Psay objCENFUNLGP:verCamNPR("BA3_CONEMP",QRA->BA3_CONEMP)
@ li,106 Psay "Sub-Contrato.:"
@ li,121 Psay objCENFUNLGP:verCamNPR("BA3_SUBCON",QRA->BA3_SUBCON)
li := li + 2

aCdEmpr  := QRA->BA3_CODEMP
aCdCont  := QRA->BA3_CONEMP
aCdSubCo := QRA->BA3_SUBCON

While ! QRA->(EOF())

	if !lautoSt
	    MsProcTXT("Imprimindo Usuarios da Familia.: "+;
								objCENFUNLGP:verCamNPR("BA3_CODINT",QRA->BA3_CODINT)+"."+;
								objCENFUNLGP:verCamNPR("BA3_CODEMP",QRA->BA3_CODEMP)+"."+;
								objCENFUNLGP:verCamNPR("BA3_MATRIC",QRA->BA3_MATRIC))
	endif

    If !lautoSt .AND. Interrupcao(lAbortPrint)
       li++
       @ li,000 pSay "ABORTADO PELO USUARIO"
       Exit
    Endif 

    If !lautoSt .AND. li >= 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)	
	EndIf

	If aCdEmpr <> QRA->BA3_CODEMP
		if !lautoSt
	        MsProcTXT("Processando Nova Empresa.: "+objCENFUNLGP:verCamNPR("BA3_CODEMP",QRA->BA3_CODEMP))
		endif

		@ li,000 Psay Replicate("-",132)
        ++li
		@ li,003 Psay "Total da Empresa.:" 
		@ li,022 Psay objCENFUNLGP:verCamNPR("BA3_CODEMP",aCdEmpr)
        @ li,028 Psay objCENFUNLGP:verCamNPR("BA3_CODINT",objCENFUNLGP:verCamNPR("BA3_CODEMP",aEmpr)) 
        @ li,082 Psay "Qtd. Familias.:"
        @ li,098 Psay aQtdFam
        @ li,108 Psay "Qtd. Usuarios.:"
        @ li,124 Psay aQtdUsr
        ++li
		@ li,000 Psay Replicate("-",132)
		li := li+2
		
        aTotEmp := aTotEmp + 1
		aQtdFam := 0
		aQtdUsr := 0

        @ li,000 Psay "Operadora.:"
        @ li,012 Psay objCENFUNLGP:verCamNPR("BA3_CODINT",QRA->BA3_CODINT)
        @ li,021 Psay "Grupo/Empresa.:"
        @ li,038 Psay objCENFUNLGP:verCamNPR("BA3_CODEMP",QRA->BA3_CODEMP)
        @ li,045 Psay 	objCENFUNLGP:verCamNPR("BA3_CODINT",;
						objCENFUNLGP:verCamNPR("BA3_CODEMP",;
						objCENFUNLGP:verCamNPR("BA3_TIPCON",;
						Substr(Posicione("BG9",1,xFilial("BG9")+QRA->BA3_CODINT+QRA->BA3_CODEMP+QRA->BA3_TIPCON,"BG9_DESCRI"),1,28))))
        @ li,081 Psay "Contrato.:"
        @ li,092 Psay objCENFUNLGP:verCamNPR("BA3_CONEMP",QRA->BA3_CONEMP)
        @ li,106 Psay "Sub-Contrato.:"
        @ li,121 Psay objCENFUNLGP:verCamNPR("BA3_SUBCON",QRA->BA3_SUBCON)
		li := li + 2
		aCdEmpr := QRA->BA3_CODEMP
        aEmpr := Substr(Posicione("BG9",1,xFilial("BG9")+QRA->BA3_CODINT+QRA->BA3_CODEMP,"BG9_DESCRI"),1,28)//+QRA->BA3_TIPCON,"BG9_DESCRI"),1,28)
	Else
	    If aCdCont <> QRA->BA3_CONEMP
           @ li,081 Psay "Contrato.:"
           @ li,092 Psay objCENFUNLGP:verCamNPR("BA3_CONEMP",QRA->BA3_CONEMP)
           @ li,106 Psay "Sub-Contrato.:"
           @ li,121 Psay objCENFUNLGP:verCamNPR("BA3_SUBCON",QRA->BA3_SUBCON)
           li++
           @ li,000 Psay Replicate("-",132)
    	   li := li + 2
    	   aCdCont  := QRA->BA3_CONEMP
    	   aCdSubCo := QRA->BA3_SUBCON
    	ElseIf aCdSubCo <> QRA->BA3_SUBCON  
           @ li,081 Psay "Contrato.:"
           @ li,092 Psay objCENFUNLGP:verCamNPR("BA3_CONEMP",QRA->BA3_CONEMP)
           @ li,106 Psay "Sub-Contrato.:"
           @ li,121 Psay objCENFUNLGP:verCamNPR("BA3_SUBCON",QRA->BA3_SUBCON)
           li++
           @ li,000 Psay Replicate("-",132)
    	   li := li + 2
           aCdCont := QRA->BA3_CONEMP
    	   aCdSubCo := QRA->BA3_SUBCON    	   
    	Endif       	
	Endif    
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Query no Arquivo BA1(CADASTRO DE USUARIOS)                                  ³
//³Pesquisa BA1(Usuarios) De Acordo Com os Registros Selecionados no BA3(Familia)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	bQuery := " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_CONEMP, BA1_SUBCON,"
	bQuery += " BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_TIPUSU, BA1_SEXO, BA1_ESTCIV,"
	bQuery += " BA1_CPFUSR, BA1_DATBLO, BA1_MOTBLO,BA1_NUMCON, BA1_MOTBLO, "
	bQuery += " BA1_DATINC, BA1_DATNAS, BA1_MATANT "
	bQuery += " FROM "+RetSqlName("BA1")
	bQuery += " WHERE"
	bQuery += " BA1_CODINT = '"+QRA->BA3_CODINT+"' AND "
	bQuery += " BA1_CONEMP = '"+QRA->BA3_CONEMP+"' AND "
	bQuery += " BA1_SUBCON = '"+QRA->BA3_SUBCON+"' AND "
	bQuery += " BA1_CODEMP = '"+QRA->BA3_CODEMP+"' AND "
	bQuery += " BA1_MATRIC = '"+QRA->BA3_MATRIC+"' AND "
	
	If !LPAR11VZIO
		bQuery += "	BA1_DATINC <='"+DTOS(dDatBas)+"' AND "
	EndIf
	
	bQuery += " D_E_L_E_T_ = ''"      

    If mv_par10 = 2  //BLOQUEADOS
   
       bQuery += "AND (BA1_DATBLO <> '        ' AND BA1_DATBLO <='"+DTOS(dDatBas)+"') "

    ElseIf mv_par10 = 3  //ATIVOS
   
       bQuery += "AND (BA1_DATBLO = '        ' OR BA1_DATBLO >'"+DTOS(dDatBas)+"') "

    Endif     
	
	bQuery += " ORDER BY BA1_CONEMP, BA1_SUBCON, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "
	
	PLSQuery(bQuery,"QRB")
	
	DbSelectArea("QRB")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Query Esta Vazia ou Nao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If QRB->(BOF()) .AND. QRB->(EOF())
       li++
       If !lImpMaA
	       @ li,000 Psay 	objCENFUNLGP:verCamNPR("BA3_CODINT",QRA->BA3_CODINT)+"."+;
		   					objCENFUNLGP:verCamNPR("BA3_CODEMP",QRA->BA3_CODEMP)+"."+;
							objCENFUNLGP:verCamNPR("BA3_MATRIC",QRA->BA3_MATRIC)
       Else
           @ li,000 Psay objCENFUNLGP:verCamNPR("BA3_MATANT",QRA->BA3_MATANT)
       Endif
       @ li,030 Psay "------  NAO HA USUARIOS CADASTRADOS PARA ESTA FAMILIA. ------"
       li := li + 2
       aQtdFam := aQtdFam + 1
       QRB->(DbcloseArea())
	   QRA->(Dbskip())
	   Loop
	Endif   

    aQtdFam := aQtdFam + 1 

	If !lImpMaA
		@ li,000 Psay 	objCENFUNLGP:verCamNPR("BA1_CODINT",QRB->BA1_CODINT)+"."+;
						objCENFUNLGP:verCamNPR("BA1_CODEMP",QRB->BA1_CODEMP)+"."+;
						objCENFUNLGP:verCamNPR("BA1_MATRIC",QRB->BA1_MATRIC)+"."+;
						objCENFUNLGP:verCamNPR("BA1_TIPREG",QRB->BA1_TIPREG)+"-"+;
						objCENFUNLGP:verCamNPR("BA1_DIGITO",QRB->BA1_DIGITO)
    Else
    	@ li,000 Psay objCENFUNLGP:verCamNPR("BA1_MATANT",QRB->BA1_MATANT)
    Endif   
	@ li,022 Psay objCENFUNLGP:verCamNPR("BA1_MOTBLO",IIf(Alltrim(QRB->BA1_MOTBLO)<>"","*"," "))
	@ li,024 Psay objCENFUNLGP:verCamNPR("BA1_NOMUSR",Substr(QRB->BA1_NOMUSR,1,30))
	@ li,056 Psay objCENFUNLGP:verCamNPR("BA1_TIPUSU",Substr(Posicione("BIH",1,xFilial("BIH")+QRB->BA1_TIPUSU,"BIH_DESCRI"),1,10))
	@ li,068 Psay objCENFUNLGP:verCamNPR("BA1_SEXO",X3Combo("BA1_SEXO",QRB->BA1_SEXO))
	@ li,079 Psay objCENFUNLGP:verCamNPR("BA1_ESTCIV",Substr(Posicione("SX5",1,xFilial("SX5")+"33"+QRB->BA1_ESTCIV,"X5_DESCRI"),1,15))
	if objCENFUNLGP:verCamNPR("BA1_CPFUSR",QRB->BA1_CPFUSR) $ '***********'
		@ li,095 Psay "***.***.***-**"
	Else
		@ li,095 Psay QRB->BA1_CPFUSR Picture X3Picture("BA1_CPFUSR",QRB->BA1_CPFUSR)
	EndIf
	@ li,111 Psay objCENFUNLGP:verCamNPR("BA1_DATINC",QRB->BA1_DATINC)
	@ li,122 Psay objCENFUNLGP:verCamNPR("BA1_DATNAS",QRB->BA1_DATNAS)

	
	li++
	QRB->(DbSkip())
 
    aTotUsr := aTotUsr + 1	
    aQtdUsr := aQtdUsr + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprimi os Usuarios Relacionados de Acordo Com a Familia                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While ! QRB->(EOF()) 
		If  li >= 58
			if !lautoSt
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,cMvCOMP)
        	endif

			If !lImpMaA
        		@ li,000 Psay 	objCENFUNLGP:verCamNPR("BA1_CODINT",QRB->BA1_CODINT)+"."+;
								objCENFUNLGP:verCamNPR("BA1_CODEMP",QRB->BA1_CODEMP)+"."+;
								objCENFUNLGP:verCamNPR("BA1_MATRIC",QRB->BA1_MATRIC)+"."
			Else
        		@ li,000 Psay objCENFUNLGP:verCamNPR("BA1_MATANT",QRB->BA1_MATANT)
			Endif
		EndIf
		@ li,017 Psay 	objCENFUNLGP:verCamNPR("BA1_TIPREG",QRB->BA1_TIPREG)+"-"+;
						objCENFUNLGP:verCamNPR("BA1_DIGITO",QRB->BA1_DIGITO)
        @ li,022 Psay objCENFUNLGP:verCamNPR("BA1_MOTBLO",IIf(Alltrim(QRB->BA1_MOTBLO)<>"","*"," "))
		@ li,024 Psay objCENFUNLGP:verCamNPR("BA1_NOMUSR",Substr(QRB->BA1_NOMUSR,1,30))
		@ li,056 Psay objCENFUNLGP:verCamNPR("BA1_TIPUSU",Substr(Posicione("BIH",1,xFilial("BIH")+QRB->BA1_TIPUSU,"BIH_DESCRI"),1,10))
		@ li,068 Psay objCENFUNLGP:verCamNPR("BA1_SEXO",X3Combo("BA1_SEXO",QRB->BA1_SEXO))
		@ li,079 Psay objCENFUNLGP:verCamNPR("BA1_ESTCIV",Substr(Posicione("SX5",1,xFilial("SX5")+"33"+QRB->BA1_ESTCIV,"X5_DESCRI"),1,15))
		if objCENFUNLGP:verCamNPR("BA1_CPFUSR",QRB->BA1_CPFUSR) $ '***********'
		@ li,095 Psay "***.***.***-**"
		Else
		@ li,095 Psay QRB->BA1_CPFUSR Picture X3Picture("BA1_CPFUSR",QRB->BA1_CPFUSR)
		EndIf
		@ li,111 Psay objCENFUNLGP:verCamNPR("BA1_DATINC",QRB->BA1_DATINC)
		@ li,122 Psay objCENFUNLGP:verCamNPR("BA1_DATNAS",QRB->BA1_DATNAS)  
		li++
		QRB->(DbSkip())
        aTotUsr := aTotUsr + 1	
        aQtdUsr := aQtdUsr + 1
	Enddo
	li++
	QRB->(DbCloseArea())
	QRA->(DbSkip())
//	IncRegua()
Enddo

aTotEmp := aTotEmp + 1

@ li,000 Psay Replicate("-",132)
++li
@ li,003 Psay "Total da Empresa.:" 
@ li,022 Psay objCENFUNLGP:verCamNPR("BA3_CODEMP",aCdEmpr)
@ li,028 Psay objCENFUNLGP:verCamNPR("BA3_CODINT",objCENFUNLGP:verCamNPR("BA3_CODEMP",aEmpr)) 
@ li,082 Psay "Qtd. Familias.:"
@ li,098 Psay aQtdFam
@ li,108 Psay "Qtd. Usuarios.:"
@ li,124 Psay aQtdUsr
++li
@ li,000 Psay Replicate("-",132)
li := li+2                                                  

@ li,049 Psay "--------- TOTAIS DO RELATORIO -----------"
++li
@ li,052 Psay "Numero de Empresas Impressas.:"
@ li,083 Psay aTotEmp
++li
@ li,052 Psay "Numero de Usuarios Impressos.:"
@ li,083 Psay aTotUsr
++li
@ li,049 Psay "-----------------------------------------"

QRA->(DbCloseArea())

Return

Static Function ParSQL(cFilADV)
 
cFilADV := StrTran(cFilADV,".AND."," AND ")
cFilADV := StrTran(cFilADV,".OR."," OR ")
cFilADV := StrTran(cFilADV,"=="," = ")
cFilADV := StrTran(cFilADV,'"',"'")
cFilADV := StrTran(cFilADV,'$'," IN ")
cFilADV := StrTran(cFilADV,"ALLTRIM","  ")
 
Return(cFilADV)

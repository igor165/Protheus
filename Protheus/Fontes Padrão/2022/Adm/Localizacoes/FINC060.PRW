#INCLUDE "FINC060.CH"
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "COLORS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINC060  ³ Autor ³ Leonardo Ruben        ³ Data ³ 27/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±      
±±³Descri‡…o ³ Consulta de deudas con proveedores y de cuentas de clientes³±±
±±³          ³ Reunion de los antiguos rdmakes RCONS10 y RCONS20          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINC060()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - Localizacoes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leonardo      |11.10.99³Melhor|Acerto na apresentacao das informacoes e³±±
±±³              ³        |      |inclusao do evento DblClick (Detalhes)  ³±±
±±³Bruno         |24.04.00³Melhor|Melhoria de performance, solucao para   ³±±
±±³              ³        |      | os diferentes pictures segundo pais.   ³±±
±±³Rubens Pante  |20/04/01³Melhor|Considera tambem as baixas manuais,     ³±±
±±³              ³        |      |juros, multas e descontos.              ³±±
±±³Sergio F.     ³03/07/02|001136|Acerto de layout.                       ³±±
±±³Alf. Medrano  ³06/12/16³SERINN001-125³se quita la creacion de tablas   ³±±
±±³              ³        ³      ³-Temporales y se asigna FWTemporaryTable³±±
±±³              ³        ³      ³en fun RConsCli y RConsPro              ³±±
±±³Alf. Medrano  ³30/12/16³SERINN001-255³Merge 12.1.15 vs Main            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinC060

SetPrvt("MV_PAR01,_SALIAS,CPERG,AREGS,I,J,AHEADERANT,ACOLSANT")
Private cPict,cPict1
Private cLibOrd:=Alltrim(GetNewPar("MV_LIBORD","N"))
Private cCondSEK := '.T.', lAgregSEK := .F.
Private nPosEmis,nPosDesc,nPosDeb,nPosCred,nPosSal,nPosSldT,nPosVecto,nPosCorre

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salvar aHeader e aCols, pois as Consultas tambem sao ativadas ³
//³ nas rotinas de manutencao que utilizam MsGetDados()...			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cProc := FunName(1)

If cProc $ "MATA410.MATA440.MATA455.MATA450.MATA465.MATA466.MATA467"
	If Inclui .or. Altera
		aHeaderAnt := AClone(aHeader)
		aColsAnt := AClone(aCols)
	EndIf
EndIf

mv_par01 := 0

//+---------------------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros                                      ¦
//¦ mv_par01  // Consulta de cuentas de clientes o de deudas con Proveedores  ¦
//+---------------------------------------------------------------------------+
if !Pergunte("FIC060",.T.)
	return
endif

IF mv_par01 == 1
	RConsCli()   // Consulta de cuentas de clientes
ElseIf mv_par01 == 2
	RConsPro()   // Consulta de deudas con Proveedores
EndIf

If aHeaderAnt != NIL .and. aColsAnt != NIL
	aHeader := AClone(aHeaderAnt)
	aCols	  := AClone(aColsAnt)
EndIf

Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RCONS10  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Consulta de deudas con proveedores                         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Financiero                                                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦10.06.99  ¦Melhor¦Consideracion de la resolucion de Windows para los   ¦¦¦
¦¦¦          ¦      ¦ tamanhos de las ventanas.                           ¦¦¦
¦¦¦09.07.99  ¦Melhor¦Mudado tamanio de NUMERO de 12 para 13 .             ¦¦¦
¦¦¦14.07.99  ¦Melhor¦Consideracion de Abatimientos y tratado de todos los ¦¦¦
¦¦¦          ¦      ¦titulos no NDF o Abatimiento como sumadores.         ¦¦¦
¦¦¦29.07.99  ¦Melhor¦Bruno - Consideraçao de parámetro MV_CPNEG.          ¦¦¦
¦¦¦11.08.99  ¦Melhor¦Lucas : Habilitei cPerg para a SetImp().             ¦¦¦
¦¦¦23.08.99  ¦Melhor¦J.Luis: Imprime nombre del Proveedor en el Informe.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function RconsPro()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
Local nZ := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt:=GetArea()

SetPrvt("MV_CPNEG,NSALDOINI,NSALANT,LPERG010,CPROVE,CLOJA")
SetPrvt("CNOMEPRO,CTEL,NDEBITO,NCREDITO,NSALDO,NTOTSALDO")
SetPrvt("NTOTDEB,NTOTCRED,ACAMPOS,CARQTRAB,CINDARQTMP,AHEADER")
SetPrvt("CUSADO,ACOLS,NCNT,NDEBPERI,NCREDPERI,NTOTTIT")
SetPrvt("NZ,NSALDOPERI,NPICTSAL,NPICTTOTS,NPICTSLPER,NHORIZ")
SetPrvt("NLARGOJANE,NLARGOBX,LPEQUENA,OLBX,CCONDICAO,CINDARQSE2")
SetPrvt("CCHAVE,NINDEX,NSIGNO,CPAGANT,_SALIAS,CPERG")
SetPrvt("AREGS,I,J,TAMANHO,CBTXT,CBCONT")
SetPrvt("LIMITE,AORD,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("ARETURN,CNOMEPROG,NLASTKEY,LCONTINUA,NLIN,WNREL")
SetPrvt("CSTRING,CTITULO,CTAMANHO,CCABEC1,CCABEC2,M_PAG")
SetPrvt("NLI,NA,LRET,")

Private nSaldoIni := 0.00
Private nDebito  	:= 0.00
Private nCredito 	:= 0.00
Private nSaldo   	:= 0.00
Private nTotSaldo	:= 0.00
Private nTotDeb  	:= 0.00
Private nTotCred 	:= 0.00
Private nSldChq  	:= 0.00
Private nSalAnt   := 0.00
Private nDecs		:= 0
Private cPict		:=	""
Private cPict1		:=	""
Private aCampos	:= {}
Private aHeader 	:= {}
Private oTmpTable

MV_CPNEG  := GetNewPar("MV_CPNEG","NCP,NDI")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros								 ³
//³ mv_par01			// Fornecedor 										 ³
//³ mv_par02			// Loja     										 ³
//³ mv_par03			// Data De                              	 ³
//³ mv_par04			// Data Ate                             	 ³
//³ mv_par05			// Moeda    										 ³
//³ mv_par06			// Outras Moedas                        	 ³
//³ mv_par07			// Mostra Correcao Monetaria            	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If Pergunte("CORFOR",.T.)
	nDecs		:=	MsDecimais(MV_PAR05)
	cPict		:=	PesqPict("SE2","E2_VALOR",17,MV_PAR05)
	cPict1	:=	PesqPict("SE2","E2_VALOR",17,MV_PAR05)
	SA2->(DbSetorder(1))
	If SA2->(DbSeek(xFilial("SA2")+mv_par01+mv_par02))
		If cPaisLoc<>"CHI"
			cProve	:=	mv_par01
		Else
			cProve   := SA2->A2_CGC
		EndIf
		cLoja    := mv_par02
		cNomePro := SA2->A2_NOME
		cTel     := SA2->A2_TEL
	Else
		MsgStop(OemToAnsi(STR0001))  // "El Proveedor no Existe..."
	EndIf
Else
	Return
Endif

AADD(aCampos,{"EMISSAO" ,"D",08, 0 })
AADD(aCampos,{"PREFIJO" ,"C",03, 0 })
AADD(aCampos,{"SERIE"   ,"C",03, 0 })
AADD(aCampos,{"NUMERO"  ,"C",TamSx3("E2_NUM")[1], 0 }) 
AADD(aCampos,{"TIPO"    ,"C",03, 0 })
AADD(aCampos,{"CUOTA"   ,"C",01, 0 })
AADD(aCampos,{"VENCTO"  ,"C",20, 0 })
AADD(aCampos,{"DEBITO"  ,"N",17, MsDecimais(mv_par05)})
AADD(aCampos,{"CREDITO" ,"N",17, MsDecimais(mv_par05)})
AADD(aCampos,{"CORRECAO","N",17, MsDecimais(mv_par05)})
AADD(aCampos,{"SALDO"   ,"N",17, MsDecimais(mv_par05)})
AADD(aCampos,{"SALTIT"  ,"N",17, MsDecimais(mv_par05)})
AADD(aCampos,{"CREDDEB" ,"C",01, 0 })

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', {"EMISSAO","CREDDEB"})
//Creacion de la tabla
oTmpTable:Create()

Processa({|| GeraTRBP()})

DbSelectArea("TRB")
DbGoTop()

If Bof().And.Eof()
	Help("",1,"NORECS",,OemToAnsi(STR0104)) //"Sin Registros"
	dbSelectArea("TRB")
	DbCloseArea()
	If oTmpTable <> Nil  
		oTmpTable:Delete() 
		oTmpTable := Nil 
	Endif
	Return
Endif

nSaldoIni := nDebito - nCredito
nSalAnt   := nSaldoIni
//nSalAnt := nSaldoIni

While ( !Eof() )
	RecLock("TRB",.F.)
	If TRB->CREDITO > 0
		Replace SALDO With (nSalAnt + TRB->DEBITO  - (TRB->CREDITO + TRB->CORRECAO))
	Else
		Replace SALDO With (nSalAnt + TRB->DEBITO  - TRB->CREDITO )+ TRB->CORRECAO
	EndIf				
	If mv_par07 <> 1
		If TRB->CREDITO > 0
			TRB->CREDITO += TRB->CORRECAO
		Else
			TRB->DEBITO  += TRB->CORRECAO
		EndIf				
	EndIf
	MsUnLock()
	nSalAnt := TRB->SALDO
	DbSelectArea("TRB")
	DbSkip()
End

Sx3->(DbSETORDER(2))

AADD(aHeader, OemToAnsi(STR0003)) // "Emitido"         ,"EMISSAO",""                , 8,0,".T.",cUsado,"D","SEK"})
AADD(aHeader, OemToAnsi(STR0004)) // "Descripcion"     ,"TITULO" ,"@!"              ,28,0,".T.",cUsado,"C","SEK"})
AADD(aHeader, Iif(cPaisLoc<>"CHI",OemToAnsi(STR0005),OemToAnsi(STR0107))) // "Debito"          ,"DEBITO" ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, Iif(cPaisLoc<>"CHI",OemToAnsi(STR0006),OemToAnsi(STR0108))) // "Credito"         ,"CREDITO","@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
IIf(mv_par07 == 1,AADD(aHeader,OemToAnsi(STR0105)),.T.)
AADD(aHeader, OemToAnsi(STR0008)) // "Deuda Acumulada" ,"SALDO"  ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, OemToAnsi(STR0007)) // "Saldo Financiero","SALTIT" ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, OemToAnsi(STR0009)) // "Vencto"          ,"VENCTO" ,"@!"              ,8 ,0,".T.",cUsado,"D","SEK"})

//Carregar a posicao dos campos
nPosEmis		:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0003))})
nPosDesc 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0004))})
nPosDeb  	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(Iif(cPaisLoc<>"CHI",OemToAnsi(STR0005),OemToAnsi(STR0107)))})
nPosCred 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(Iif(cPaisLoc<>"CHI",OemToAnsi(STR0006),OemToAnsi(STR0108)))})
nPosSal  	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0008))})
nPosSldT 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0007))})
nPosVecto	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0009))})
nPosCorre	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0105))})

aCols := Array(TRB->(Reccount()),len(aHeader))

TRB->(DbGoTop())

If cPaisLoc == "CHI"
	nDebPeri := 0
	nCredPeri:= 0
	nTotTit  := 0
	nTotSaldo:= 0
Else
	nDebPeri := 0.00
	nCredPeri:= 0.00
	nTotTit  := 0.00
	nTotSaldo:= 0.00
Endif	

For nZ := 1 To TRB->(Reccount())
	aCols[nZ][nPosEmis ] := Dtoc(TRB->EMISSAO)
	aCols[nZ][nPosDesc ] := If(TRB->CREDDEB == "2","   "+TRB->TIPO,TRB->TIPO)+"  "+TRB->PREFIJO+TRB->NUMERO+" "+TRB->CUOTA
	aCols[nZ][nPosDeb  ] := PADR(TRANSFORM(TRB->DEBITO ,cPict),17)
	aCols[nZ][nPosCred ] := PADR(TRANSFORM(TRB->CREDITO,cPict),17)
	aCols[nZ][nPosSal  ] := PADR(TRANSFORM(TRB->SALDO  ,cPict),17)
	aCols[nZ][nPosSldT ] := PADR(TRANSFORM(TRB->SALTIT ,cPict),17)
	aCols[nZ][nPosVecto] := IF(TRB->VENCTO=="  /  /  ", "",TRB->VENCTO)
	If mv_par07 == 1
		aCols[nZ][nPosCorre]:= PADR(TRANSFORM(TRB->CORRECAO  ,cPict),17)
		If TRB->CREDITO > 0
			nCredPeri    := nCredPeri + TRB->CREDITO + TRB->CORRECAO
			nDebPeri     := nDebPeri  + TRB->DEBITO
		Else
			nDebPeri     := nDebPeri  + TRB->DEBITO + TRB->CORRECAO
			nCredPeri    := nCredPeri + TRB->CREDITO
		EndIf    	
	Else
		If TRB->CREDITO > 0
			nCredPeri    := nCredPeri + TRB->CREDITO
			nDebPeri     := nDebPeri  + TRB->DEBITO
		Else
			nDebPeri     := nDebPeri  + TRB->DEBITO
			nCredPeri    := nCredPeri + TRB->CREDITO
		EndIf    	
	EndIf
	nTotTit := nTotTit  + TRB->SALTIT
	TRB->(DbSkip())
Next

nTotDeb    	:= Round(nDebPeri  + nDebito,nDecs)
nTotCred   	:= Round(nCredPeri + nCredito,nDecs)
nSaldoPeri 	:= Round(nDebPeri   - nCredPeri,nDecs)
nTotSaldo  	:= Round(nSaldoPeri + nSaldoIni,nDecs)
nSldChq		:= Round(nSldChq,nDecs)
nTotTit   	:= Round(nTotTit,nDecs)
nPictSal   	:= Iif(nSaldo     >= 0.00, CLR_BLUE,CLR_HRED)  //"b/w","r+/w"
nPictTots  	:= Iif(nTotSaldo  >= 0.00, CLR_BLUE,CLR_HRED)  //"b/w","r+/w"
nPictSLPer 	:= Iif(nSaldoPeri >= 0.00, CLR_BLUE,CLR_HRED)  //"b/w","r+/w"    

//+--------------------------------------------------------------+
//¦ Define tamanho de ventanas de acuerdo con la resolucion de W.¦
//+--------------------------------------------------------------+
//nHoriz := ObjectMethod(oMainWnd, "nClientWidth")
nHoriz  := oMainWnd:nClientWidth
If Type("nHoriz")=="N".And. nHoriz < 800
	nLargoJane := 620
	nLargoBx   := 305
	lPequena   := .T.
Else
	nLargoJane := 780
	nLargoBx   := 385
	lPequena   := .F.
Endif

@ 012,00 To 422,nLargoJane Dialog oDialog Title OemToAnsi(STR0010) + ;
		IIf(Mv_par06==2,OemToAnsi(STR0101),OemToAnsi(STR0102))+ GetMv("MV_MOEDA"+STR(mv_par05,1)) + " - "+ ;
		STR0016+ "  " + DtoC(MV_PAR03) + " - "  + DtoC(Min(dDataBase,MV_PAR04))  // "Estado de cuenta con el proveedor" ## " Titulos en : " ## " Titulos convertidos a : 

@ 001,08 To 033,nLargoBx
@ 153,08 To 187,nLargoBx
If !lPequena
	@ 10,340 BMPBUTTON Type 6 Action ImprimirP()
Else
	@ 06,267 BMPBUTTON Type 6 Action ImprimirP()
Endif
@ 07,014 SAY cProve + "-" + cLoja + "  " + cNomePro + IIf(Empty(cTel),"",OemToAnsi(STR0012) + cTel) SIZE 300,10 // "              Telefono : "
@ 19,014 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0013),OemToAnsi(STR0109)) + Trans(nDebito,cPict) SIZE 80,20 COLOR CLR_BLUE,CLR_WHITE  // "Debitos Anteriores "  // COLOR "b/w"
@ 19,115 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0014),OemToAnsi(STR0110)) + Trans(nCredito,cPict)   SIZE 80,20 COLOR CLR_HRED,CLR_WHITE  // "Creditos Anteriores "   // COLOR "r+/w"
@ 19,235 SAY OemToAnsi(STR0015) + Trans(nSaldoIni,cPict1) SIZE 80,20 COLOR nPictSal,CLR_WHITE // "Saldo Acumulado "  // COLOR cPictSal
If Len(aCols) == 0
	aCols := Array(1,Len(aHeader))
	Afill( aCols[1], " ") // para nao dar erro no listbox, qdo o aCols contem so NIL's.
Endif
oLbx := RDListBox(2.4, 1, nLargoBx-8 , 117, aCols, aHeader,,,, {||DetDblclk("F")} )
@ 158,014 SAY OemToAnsi(STR0064) SIZE 45,10 // "Saldo Economico:"
@ 167,014 SAY OemToAnsi(STR0016) SIZE 72,10 // "PERIODO --->"
@ 167,055 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0017),OemToAnsi(STR0111)) + Trans(nDebPeri,cPict) SIZE 80,10 COLOR CLR_BLUE,CLR_WHITE  // "Debitos : "  // COLOR "b/w"
@ 167,140 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0018),OemToAnsi(STR0112)) + Trans(nCredPeri,cPict) SIZE 80,10 COLOR CLR_HRED,CLR_WHITE  // "Creditos : " // COLOR "r+/w"
@ 167,230 SAY OemToAnsi(STR0019) + Trans(nSaldoPeri,cPict1) SIZE 80,10 COLOR nPictSLPer,CLR_WHITE  // "Saldo Periodo:"  // COLOR cPictSLPer

@ 177,014 SAY OemToAnsi(STR0020) SIZE 72,10 // "TOTALES --->"
@ 177,055 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0017),OemToAnsi(STR0111)) + Trans(nTotDeb,cPict) SIZE 80,10 COLOR CLR_BLUE,CLR_WHITE  // "Debitos : "  // COLOR "b/w"
@ 177,140 SAY If(cPaisLoc<>"CHI",OemToAnsi(STR0018),OemToAnsi(STR0112)) + Trans(nTotCred,cPict) SIZE 80,10 COLOR CLR_HRED,CLR_WHITE  // "Creditos : "  // COLOR "r+/w"
@ 177,230 SAY OemToAnsi(STR0021) + Trans(nTotSaldo,cPict1) SIZE 80,10 COLOR nPictTotS,CLR_WHITE // "Saldo Total : "  // COLOR cPictTotS

@ 190,014 SAY OemToAnsi(STR0071) + Trans(nSldChq,cPict) SIZE 90,10  // "Saldo de cheques:"

@ 188, 355 BMPBUTTON Type 1 Action Close(oDialog)
Activate Dialog oDialog CENTERED

dbSelectArea("TRB")
DbCloseArea()
If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif
RestArea(aAreaAnt)

RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GERATRB  ³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 20.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion del archivo temporal con la informacion de la   ³±±
±±³          ³ deuda con un proveedor.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION GERATRBP()

Local lGeraTrb    := .T.
Local nVlrCor 		:= 0
Local nVlrMoeTit	:= 0
Local nTaxa			:= 0

ProcRegua(SE2->(RecCount()))

SE2->(DbSetOrder(6))
SE2->(DbSeek(xFilial("SE2")+MV_PAR01+mv_par02))

While  !SE2->(EOF()).AND.xFilial("SE2")==SE2->E2_FILIAL 	.And. SE2->E2_FORNECE == mv_par01 .And. SE2->E2_LOJA == mv_par02

		// Tratamento da correcao monetaria para a Argentina
	If  cPaisLoc=="ARG" .And. mv_par05 <> 1  .And.  SE2->E2_CONVERT=='N'
		SE2->(DbSkip())
		Loop
	Endif
	lGeraTrb := .T.
	

	If .Not. ((SE2->E2_EMISSAO >= mv_par03) .Or. (mv_par06 == 2	.And. SE2->E2_MOEDA <> mv_par05) .Or.	 (cPaisLoc	<>	"CHI" .And.	SE2->E2_TIPO $ MVCHEQUE))
		//Acumula o Total
		//Pega baixas anteriores ao comeco do periodo
		VBaixaMCompra(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
		//Pega baixas posterires so aomeco do periodo
		LeBaixaMCompra(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
		
		nTaxa:=Iif(MV_PAR08==2,Iif(!Empty(SE2->E2_TXMOEDA),SE2->E2_TXMOEDA,RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)),0) 
		If ALLTRIM(SE2->E2_TIPO)$ MV_CPNEG+","+MVPAGANT.Or.SUBSTR(SE2->E2_TIPO,3,1)=="-" //.or. ALLTRIM(SE2->E2_TIPO)=="PA"
			nCredito += Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1,nTaxa),nDecs)
		Else
			nDebito  +=  Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1,nTaxa),nDecs)
		EndIf
		
	Else
		//Acumula o valor no Periodo
		
		If (SE2->E2_EMISSAO < mv_par03 .or.SE2->E2_EMISSAO > mv_par04) .Or.;
			(mv_par06 == 2	.And. SE2->E2_MOEDA <> mv_par05) .Or.;
			(Substr(SE2->E2_TIPO,1,2) == "CH" .And. IIf(cPaisLoc == "CHI",!Empty(SE2->E2_ORDPAGO),.T.))&& Tratamento para baixa manual Chile
			IncProc()
			SE2->(DbSkip())
			Loop
		Endif
		nTaxa:=Iif(MV_PAR08==2,Iif(!Empty(SE2->E2_TXMOEDA),SE2->E2_TXMOEDA,RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)),0) 
		If ALLTRIM(SE2->E2_TIPO)$MV_CPNEG+","+MVPAGANT .Or. SUBSTR(SE2->E2_TIPO,3,1)=="-"
			If !("FINA085" $ Upper( AllTrim( SE2->E2_ORIGEM)))
				RecLock("TRB",.T.)
				TRB->CREDITO :=  Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1,nTaxa),nDecs)
				TRB->CREDDEB := "2"
			Else // o credito da PA gerada por OP sera computado no registro da OP
				lGeraTrb := .F.
			EndIf
		Else
			RecLock("TRB",.T.)
			TRB->DEBITO  := Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1,nTaxa),nDecs)
			TRB->CREDDEB := "1"
		EndIf

		If lGeraTrb
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Correcao monetaria para titulos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE2->E2_MOEDA <> mv_par05
				If ALLTRIM(SE2->E2_TIPO)$MV_CPNEG+","+MVPAGANT .Or. SUBSTR(SE2->E2_TIPO,3,1)=="-"
					TRB->CORRECAO += (SE2->E2_VALOR *(RecMoeda(dDataBase,SE2->E2_MOEDA)/RecMoeda(dDataBase,mv_par05)))- TRB->CREDITO
				Else
					TRB->CORRECAO += (SE2->E2_VALOR *(RecMoeda(dDataBase,SE2->E2_MOEDA)/RecMoeda(dDataBase,mv_par05)))- TRB->DEBITO
				EndIf
			Else
				TRB->CORRECAO := 0
			EndIf
			TRB->SERIE      := " "
			TRB->NUMERO		:= SE2->E2_NUM
			TRB->TIPO		:= SE2->E2_TIPO
			TRB->CUOTA		:= SE2->E2_PARCELA
			TRB->PREFIJO	:= SE2->E2_PREFIXO
			TRB->SALTIT		:= Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par05,dDatabase,nDecs+1),nDecs)
			TRB->EMISSAO	:=  SE2->E2_EMISSAO
			IF SE2->E2_SALDO > 0.00
				IF SE2->E2_VENCTO == dDataBase
					TRB->VENCTO := OemToAnsi(STR0022) // "Vence HOY"
				ElseIf SE2->E2_VENCTO < dDataBase .And.!Empty(SE2->E2_VENCTO )
					TRB->VENCTO := Str(dDataBase-SE2->E2_VENCTO,4) + OemToAnsi(STR0023) // " dias de atraso"
				Else
					TRB->VENCTO := Dtoc(SE2->E2_VENCTO)
				Endif
			Else
				TRB->VENCTO    := OemToAnsi(STR0024) + Dtoc(SE2->E2_BAIXA)  // "Pagado el "
			Endif
			TRB->(MsUnLock())
		EndIf
		LeBaixaMCompra(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
	EndIf
	IncProc()
	SE2->(DbSkip())
EndDo

SEK->(DbSetOrder(3))
If cPaisLoc <> "BRA"
	SEK->(DbSeek(xFilial("SEK")))
	lAgregSEK := .T.
Else
	SEK->(DbSeek(xFilial("SEK")+MV_PAR01))
	cCondSEK := 'SEK->EK_FORNECE == mv_par01 .And. SEK->EK_LOJA == mv_par02'
EndIf

While SEK->EK_DTDIGIT <= mv_par04 .And. !SEK->(EOF()) .And. xFilial("SEK")==SEK->EK_FILIAL .And. &cCondSEK
	
	If SEK->EK_DTDIGIT <  mv_par03 
		//Acumula o valor total
		If VerOrdPag()
			If AllTrim(SEK->EK_TIPODOC) <> "TB".And.AllTrim(SEK->EK_TIPODOC) <> "PA"
				If mv_par05 == 1
					nCredito	+=SEK->EK_VLMOED1
				Else
					nCredito +=Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs)
				Endif
			eNDIF	
		Endif
	Else
		//Acumula o valor no periodo
		If VerOrdPag()

			RecLock("TRB",.T.)
			TRB->SERIE      := " "
			TRB->NUMERO  	:= SEK->EK_ORDPAGO
			TRB->TIPO    	:= "OP"
			TRB->EMISSAO 	:= SEK->EK_DTDIGIT
			TRB->CREDDEB 	:= "2"
			cPagAnt      	:= SEK->EK_ORDPAGO
			nTotPg       	:= 0
			
			While SEK->EK_ORDPAGO == cPagAnt .And. &cCondSEK .And. !SEK->EK_CANCEL
				
				If ! VerOrdPag()
					IncProc()
					SEK->(DbSkip())
					Loop
				EndIf
				If AllTrim(SEK->EK_TIPODOC) <> 'TB'.And.AllTrim(SEK->EK_TIPODOC) <> 'PA'				
					If AllTrim(SEK->EK_TIPO) $ IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
						SE2->(DbSetOrder(1))
						SE2->(DbSeek( xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO ))
						If SE2->(Found()) .And. SE2->E2_SALDO > 0.00
							If mv_par05 == 1
								TRB->SALTIT += SEK->EK_VLMOED1
								nSldChq     += SEK->EK_VLMOED1  // acumula
							Else
								TRB->SALTIT += Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs)
								nSldChq     += Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs)
							Endif
							nVlrCor	:= Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs)
						Endif
					Endif
					nTotPg	+= If(mv_par05=1, SEK->EK_VLMOED1, Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs))
					nVlrCor	:= Round(xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par05,SEK->EK_EMISSAO,nDecs+1),nDecs)
				Endif

				If Val(SEK->EK_MOEDA) <> mv_par05 .And. (SEK->EK_TIPODOC<>"TB" .And. SEK->EK_TIPODOC<>"PA")
					TRB->CORRECAO -= (SEK->EK_VALOR * (RecMoeda(dDataBase,Val(SEK->EK_MOEDA))/RecMoeda(dDataBase,mv_par05)))- nVlrCor
				Endif
				nVlrCor	:=	0

				If cPaisLoc <> "BRA" .and. cLibOrd=="S"
					If Empty(SEK->EK_DTREC)
						TRB->VENCTO := OemToAnsi(STR0103) // "Vence HOY NAO Liberada"// OemToAnsi(STR0022) // "Vence HOY"
					Endif
				Endif
			  	SEK->(DbSkip())
			  	Exit
			Enddo

			TRB->CREDITO 	:= nTotPg
			TRB->SALDO   	:= Round(TRB->CREDITO,nDecs)

			MsUnLock()
		Endif
	EndIf
	IncProc()
	SEK->(DbSkip())
Enddo

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Imprimir  ³ Autor ³ Bruno Sobieski        ³ Data ³ 20.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao da conta corrente do fornecedor.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Imprimir
Static Function ImprimirP()
TRB->(DbGoTop())
If TRB->(EOF()).And.TRB->(BOF())
	Return
Endif
tamanho := "M"
cbtxt   := ""
cbcont  := 1
limite  := 220
aOrd    := {}
titulo  := PADC(OemToAnsi(STR0029),74)  //"Estado de cuenta Corriente"
cDesc1  := PADC(OemToAnsi(STR0030),74) //"Este programa imprimira un resumen de"
cDesc2  := PADC(OemToAnsi(STR0031),74)  //"la cuenta corriente con el proveedor"
cDesc3  := ""
//"Especial","Administracion"
aReturn := { OemToAnsi(STR0032), 1,OemToAnsi(STR0033), 2, 1,1,"",1 }

cNomeprog :="FINC060"
cPerg     := ""
nLastKey  := 0
lContinua := .T.
nLin      := 0
wnrel     := "CORFOR"
cString   := "SE2"

cTitulo  := OemToAnsi(STR0034)+IIf(Mv_par06==2,OemToAnsi(STR0101),OemToAnsi(STR0102))+ GetMv("MV_MOEDA"+STR(mv_par05,1)) // "Informe estado de cuenta con Proveedor" ## " Titulos en : " ## " Titulos convertidos a : "
cTamanho := "M"
cCabec1  := cProve+"-"+cLoja+" "+cNomePro+OemToAnsi(STR0035)+cTel  // " Tel: " // JLO HARTMAN
//cCabec2  := " Emision  Desc.(Tipo/Num/Cuota)              Debito             Credito    Saldo Neto        Saldo Docum Situacion  "
If mv_par07 == 1
	cCabec2  := IIf(cPaisLoc<>"CHI",OemToAnsi(STR0106),OemToAnsi(STR0118))
Else
	cCabec2  := IIf(cPaisLoc<>"CHI",OemToAnsi(STR0036),OemToAnsi(STR0113))
EndIf	
M_PAG    := 1 // <--- la pide la funcion cabec.... ???
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,,,.F.)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> RptStatus({|| Execute(RptDetail)})
RptStatus({|| RptDetail("P")})
Return


// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function RptDetail
Static Function RptDetail(cTipoDet)
Local nMosCorre := 0
Local cStr0038	:= OemToAnsi(STR0038)  // "Acumulados            --------------->"
Local cStrP1, cStrP2, nPosSpc
Local nA := 0
Iif(cTipoDet == "C",nMosCorre := Mv_par08,nMosCorre := Mv_par07)

cPerg:=Iif(cTipoDet == "C","CORCLI","CORFOR")

nLi := 80
SetRegua(Len(aCols))
For nA := 1 To Len(aCols)
	IncRegua()
	If nLi > 58
		If ( nA > 1 )
			@nLi + 2, 010 PSAY OemToAnsi(STR0037)  // "CONTINUA EN LA PROXIMA PAGINA.........................."
		EndIf
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cNomeprog,cTamanho)
		//                              1                        2                        3                     4                        5                        6                     7                        8                        9               10   11    12    13
		// 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		// Emision  Desc.(Tipo/Num/Cuota)              Debito                 Credito    Saldo Neto      Saldo Docum.  Situacion
		nLi := nLi + 1
	Endif
	If nA==1
		If nMosCorre == 1
			If ( (1+Len(cStr0038)) > 33 )
				nPosSpc	:= At(" ",cStr0038)	
				cStrP1	:= SubStr(cStr0038,1        ,nPosSpc      )
				cStrP2	:= SubStr(cStr0038,nPosSpc+6,Len(cStr0038))
				cStr0038:= cStrP1+cStrP2
			Endif
		Endif
		@ nLi,001 PSAY cStr0038
		If nMosCorre == 1
			@ nLi,040 PSAY Trans(nDebito,cPict)
			@ nLi,055 PSAY Trans(nCredito,cPict)
			@ nLi,085 PSAY Trans(nSaldoIni,cPict)
		Else
			@ nLi,040 PSAY Trans(nDebito,cPict)
			@ nLi,060 PSAY Trans(nCredito,cPict)
			@ nLi,078 PSAY Trans(nSaldoIni,cPict)
		EndIf
		nLi := nLi + 1
	Endif
	If nMosCorre == 1
		@ nLi,001 PSAY Pad(aCols[nA][1],10)
		@ nLi,012 PSAY Pad(aCols[nA][2],30)
		@ nLi,042 PSAY aCols[nA][3]   //Picture  TM(aCols[nA][3],16,2) DEBITO
		@ nLi,057 PSAY aCols[nA][4]   //Picture  TM(aCols[nA][4],16,2) CREDITO
		@ nLi,072 PSAY aCols[nA][5]   //Picture  TM(aCols[nA][5],16,2) CORREC
		@ nLi,087 PSAY aCols[nA][6]   //Picture  TM(aCols[nA][6],18,2) SALDO
		@ nLi,102 PSAY aCols[nA][7]                                   //      SALDO DOC
		@ nLi,122 PSAY Alltrim(aCols[nA][8])                            // SITUAC
	Else
		@ nLi,001 PSAY Pad(aCols[nA][1],10)
		@ nLi,012 PSAY Pad(aCols[nA][2],30)
		@ nLi,042 PSAY aCols[nA][3]   //Picture  TM(aCols[nA][3],16,2)     debito
		@ nLi,062 PSAY aCols[nA][4]   //Picture  TM(aCols[nA][4],16,2)           credito
		@ nLi,080 PSAY aCols[nA][5]   //Picture  TM(aCols[nA][5],16,2)           neto
		@ nLi,098 PSAY aCols[nA][6]   //Picture  TM(aCols[nA][6],18,2)             docum
		@ nLi,119 PSAY Alltrim(aCols[nA][7])      // situaca
	EndIf
	nLi := nLi + 1
Next
@ nLi,005 PSAY IIf(cPaisLoc<>"CHI".Or.cTipoDet=="C",OemToAnsi(STR0039),OemToAnsi(STR0114))+ Trans(nDebPeri,cPict)     //"Debitos Periodo : "
@ nLi,045 PSAY IIf(cPaisLoc<>"CHI".Or.cTipoDet=="C",OemToAnsi(STR0040),OemToAnsi(STR0115))+ Trans(nCredPeri,cPict)    //"Creditos Perido : "
@ nLi,085 PSAY OemToAnsi(STR0041)+ Trans(nSaldoPeri,cPict1) //"Deuda Periodo   : "

nLi := nLi + 2

@ nLi + 1,001 PSAY OemToAnsi(STR0042) // " T O T A L E S : "
@ nLi + 2,010 PSAY IIf(cPaisLoc<>"CHI".Or.cTipoDet=="C",OemToAnsi(STR0043),OemToAnsi(STR0116))
@ nLi + 2,023 PSAY Trans(nTotDeb,cPict)   //"Debitos     :    "

@ nLi + 3,010 PSAY IIf(cPaisLoc<>"CHI".Or.cTipoDet=="C",OemToAnsi(STR0044),OemToAnsi(STR0117))
@ nLi + 3,023 PSAY Trans(nTotCred,cPict)  //"Creditos    :    "

@ nLi + 4,010 PSAY OemToAnsi(STR0045) 
@ nLi + 4,023 PSAY+ Trans(nTotSaldo,cPict) // "Saldo Total :  "
If nLi > 32
	nLi := Cabec(cTitulo,cCabec1,cCabec2,cNomeprog,cTamanho)
	nLi += 1
	Roda(cbcont,cbtxt,tamanho)
Else
	Roda(cbcont,cbtxt,tamanho)
EndIF

Set Device To Screen

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RCONS20  ³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 23.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de CUENTAS DE CLIENTES                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Financiero                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  DATA    ³ BOPS ³                  ALTERACAO                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³10.06.99	 ³Melhor³Consideracion de la resolucion de Windows para los   ³±±
±±³        	 ³      ³ tamanhos de las ventanas.                           ³±±
±±³09.07.99	 ³Melhor³Mudado tamanio de NUMERO de 12 para 13 .             ³±±
±±³14.07.99	 ³Melhor³Consideracion de Abatimientos y tratado de todos los ³±±
±±³        	 ³      ³titulos no NCF o Abatimiento como sumadores.         ³±±
±±³29.07.99	 ³Melhor³Bruno : Implementacion del par metro MV_CRNEG.       ³±±
±±³11.08.99	 ³Melhor³Lucas : Habilitei cPerg para a SetImp().             ³±±
±±³23.08.99  ³Melhor³J.Luis: Imprime nombre del Cliente en el Informe.    ³±±
±±³20/04/01  ³Melhor|Considera tambem as baixas manuais, juros, multas e  ³±±
±±³          |      |descontos (Rubens Pante).                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RconsCli()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt:=	GetArea()

Local aColunas:=	{}
Local nPosEmis		:=	0
Local nPosDesc 	:=	0
Local nPosDeb  	:=	0
Local nPosCred 	:=	0
Local nPosSal  	:=	0
Local nPosSldT 	:=	0
Local nPosVecto	:=	0
Local nPosCorre	:=	0
Local nLinNum		:= 1

SetPrvt("MV_CRNEG,NSALANT,ACOLS,LPERG020,CCLIENTE,CLOJA")
SetPrvt("CNOMECLI,CTEL,NDEBITO,NCREDITO,NSALDO,NTOTSALDO")
SetPrvt("NTOTDEB,NTOTCRED,ACAMPOS,CARQTRAB,CINDARQTMP,AHEADER")
SetPrvt("CUSADO,NCNT,NDEBPERI,NCREDPERI,NTOTTIT,NZ")
SetPrvt("NSALDOPERI,NPICTSAL,NPICTTOTS,NPICTSLPER,NHORIZ,NLARGOJANE")
SetPrvt("NLARGOBX,LPEQUENA,OLBX,CCONDICAO,CINDARQSE1,NINDEX")
SetPrvt("NSALDOINI,CRCANT,CSERANT,_SALIAS,CPERG,AREGS,I")
SetPrvt("J,TAMANHO,LIMITE,AORD,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,ARETURN,CNOMEPROG,NLASTKEY,LCONTINUA")
SetPrvt("NLIN,WNREL,CSTRING,CTITULO,CTAMANHO,CCABEC1,CCABEC2")
SetPrvt("CBTXT,CBCONT,M_PAG,NLI,NA,LRET,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros								 ³
//³ mv_par01			// Cliente   										 ³
//³ mv_par02			// Filial     							 			 ³
//³ mv_par03			// Data De                                 ³
//³ mv_par04			// Data Ate                                ³
//³ mv_par05			// Mostrar recibo									 ³
//³ mv_par06			// Moeda    										 ³
//³ mv_par07			// Outras Moedas                        	 ³
//³ mv_par08			// Mostra Correcao Monetaria            	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nZCH 		:= 0
Private nSalAnt   := 0
Private nSaldoIni := 0.00
Private nDebito   := 0.00
Private nCredito  := 0.00
Private nSaldo    := 0.00
Private nTotDeb   := 0.00
Private nTotCred  := 0.00
Private nSldChq   := 0.00
Private nDebPeri  := 0.00
Private nCredPeri := 0.00
Private nTotTit   := 0.00
Private nTotSaldo := 0.00
Private aCols    	:= {}
Private aCampos 	:= {}
Private aColsCH 	:= {}
Private aHeaderCH := {}
Private aHeader 	:= {}
Private MV_CRNEG 	:= GetNewPar("MV_CRNEG","NCC,NDE")
Private lFC060Con := ExistBlock("FC060CON")
Private cPict		:=	""
Private cPict1		:=	""
Private nDecs		:=	""
Private oTmpTable

If Pergunte("CORCLI",.T.)
	SA1->(DbSetorder(1))
	If SA1->(DbSeek(xFilial("SA1")+mv_par01+mv_par02))
		If cPaisLoc == "CHI"
			cCliente := SA1->A1_CGC
			cTel     := SA1->A1_FAX
			cLoja    := SA1->A1_loja
		Else
			cCliente := mv_par01
			cLoja    := mv_par02
			cTel     := SA1->A1_TEL
		EndIf
		cNomeCli := SA1->A1_NOME
	Else
		MsgStop(OemToAnsi(STR0046)) // "El Cliente no Existe..."
		Return
	Endif
Else
	Return
Endif

cPict		:=	PesqPict("SE1","E1_VALOR",17,mv_par06)
cPict1	:=	PesqPict("SE1","E1_VALOR",17,mv_par06)
nDecs		:=	MsDecimais(Mv_PAR06)

AADD(aHeaderCH, OemToAnsi(STR0089) ) // "Cheque"
AADD(aHeaderCH, OemToAnsi(STR0090) ) // "Valor"
AADD(aHeaderCH, OemToAnsi(STR0091) ) // "Moneda"
AADD(aHeaderCH, OemToAnsi(STR0092) ) // "Situacao"
AADD(aHeaderCH, OemToAnsi(STR0093)+MV_MOEDA1) // "Valor en "
AADD(aHeaderCH, OemToAnsi(STR0094) ) // "Fecha recibo"
AADD(aHeaderCH, OemToAnsi(STR0095) ) // "Recibo"

AADD(aCampos,{"EMISSAO"	, "D",	08, 0 })
AADD(aCampos,{"PREFIJO"	, "C",	03, 0 })
AADD(aCampos,{"SERIE"   , "C",	03, 0 })
AADD(aCampos,{"NUMERO" 	, "C", TamSx3("E2_NUM")[1], 0}) 
AADD(aCampos,{"TIPO"   	, "C",	03, 0 })
AADD(aCampos,{"CUOTA"  	, "C",	01, 0 })
AADD(aCampos,{"VENCTO" 	, "C", 	22, 0 })
AADD(aCampos,{"DEBITO" 	, "N", 	17, nDecs })
AADD(aCampos,{"CREDITO"	, "N", 	17, nDecs })
AADD(aCampos,{"CORRECAO", "N", 	17, nDecs })
AADD(aCampos,{"SALDO"   , "N", 	17, nDecs })
AADD(aCampos,{"SALTIT"  , "N",	17, nDecs })
AADD(aCampos,{"CREDDEB" , "C",01, 0 })

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', {"EMISSAO","CREDDEB"})
//Creacion de la tabla
oTmpTable:Create()    

Processa({|| GeraTRBC()})

//Criar aHeader
AADD(aHeader, OemToAnsi(STR0003)) // "Emitido"         ,"EMISSAO" ,""                , 8,0,".T.",cUsado,"D","SEK"})
AADD(aHeader, OemToAnsi(STR0004)) // "Descripcion"     ,"TITULO"  ,"@!"              ,28,0,".T.",cUsado,"C","SEK"})
AADD(aHeader, OemToAnsi(STR0005)) // "Debito"          ,"DEBITO"  ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, OemToAnsi(STR0006)) // "Credito"         ,"CREDITO" ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
IIf(mv_par08 == 1,AADD(aHeader,OemToAnsi(STR0105)),.T.)// Correcao Monetaria
AADD(aHeader, OemToAnsi(STR0008)) // "Deuda Economica" ,"SALDO"   ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, OemToAnsi(STR0007)) // "Saldo Financiero","SALTIT"  ,"@R 99,999,999.99",14,2,".T.",cUsado,"N","SEK"})
AADD(aHeader, OemToAnsi(STR0009)) // "Vencto"          ,"VENCTO"  ,"@!"              ,8 ,0,".T.",cUsado,"D","SEK"})

//Carregar a posicao dos campos
nPosEmis		:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0003))})
nPosDesc 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0004))})
nPosDeb  	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0005))})
nPosCred 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0006))})
nPosSal  	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0008))})
nPosSldT 	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0007))})
nPosVecto	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0009))})
nPosCorre	:=	Ascan(aHeader,{ |x| Alltrim(x)== Alltrim(OemToAnsi(STR0105))})

nSaldoIni := nDebito - nCredito
nSalAnt   := nSaldoIni

DbSelectArea("TRB")
DbSetOrder(1)
DbGoTop()

//For nZ := 1 To TRB->(RecCount())
While !TRB->(EOF())
	RecLock("TRB",.F.)
	If TRB->CREDITO > 0
		Replace SALDO With (nSalAnt + TRB->DEBITO  - (TRB->CREDITO + TRB->CORRECAO))
	Else
		Replace SALDO With (nSalAnt + TRB->DEBITO  - TRB->CREDITO )+ TRB->CORRECAO
	EndIf				
	If mv_par08 <> 1
		If TRB->CREDITO > 0
			TRB->CREDITO += TRB->CORRECAO
		Else
			TRB->DEBITO  += TRB->CORRECAO
		EndIf				
	EndIf
	MsUnLock()
	nSalAnt := TRB->SALDO
	If TRB->CREDITO + TRB->DEBITO <> 0.00
		Aadd(aCols,Array(len(aHeader)))
		aCols[nLinNum][nPosEmis ] := Dtoc(TRB->EMISSAO)
		aCols[nLinNum][nPosDesc ] := If(TRB->CREDDEB=='2',"   "+TRB->TIPO,TRB->TIPO)+"  "+TRB->PREFIJO+IIf(TRB->TIPO="RC",TRB->SERIE,"")+TRB->NUMERO+" "+TRB->CUOTA
		aCols[nLinNum][nPosDeb  ] := PADR(Transform(TRB->DEBITO ,cPict),17)
		aCols[nLinNum][nPosCred ] := PADR(Transform(TRB->CREDITO,cPict),17)
		aCols[nLinNum][nPosSal  ] := PADR(Transform(TRB->SALDO  ,cPict),17)
		aCols[nLinNum][nPosSldT ] := PADR(Transform(TRB->SALTIT ,cPict),17)
		aCOls[nLinNum][nPosVecto] := IIf(TRB->VENCTO=="  /  /  ","",TRB->VENCTO)
		If mv_par08 == 1
			aCols[nLinNum][nPosCorre]:= PADR(TRANSFORM(TRB->CORRECAO  ,cPict),17)
		EndIF
		nLinNum++
	Endif
	TRB->(DbSkip())
Enddo
//Next

nTotDeb    := Round(nDebPeri   + nDebito,nDecs)
nTotCred   := Round(nCredPeri  + nCredito,nDecs)
nSaldoPeri := Round(nDebPeri   - nCredPeri,nDecs)
nTotSaldo  := Round(nSaldoPeri + nSaldoIni,nDecs)

nPictSal   := Iif(nSaldo     >= 0.00, CLR_BLUE, CLR_HRED) // "b/w","r+/w"
nPictTots  := Iif(nTotSaldo  >= 0.00, CLR_BLUE, CLR_HRED) // "b/w","r+/w"
nPictSLPer := Iif(nSaldoPeri >= 0.00, CLR_BLUE, CLR_HRED) // "b/w","r+/w"

//+--------------------------------------------------------------+
//¦ Define tamanho de ventanas de acuerdo con la resolucion de W.¦
//+--------------------------------------------------------------+
nHoriz  := oMainWnd:nClientWidth
If Type("nHoriz")=="N".And.nHoriz < 800
	nLargoJane := 620
	nLargoBx   := 305
	lPequena   := .T.
Else
	nLargoJane := 780
	nLargoBx   := 385
	lPequena   := .F.
Endif

@  12,0  To 430,nLargoJane Dialog oDialog Title OemToAnsi(STR0047)+ IIf(Mv_par07==2,OemToAnsi(STR0101),OemToAnsi(STR0102))+ GetMv("MV_MOEDA"+STR(mv_par06,1));
			+ " - " + STR0016 + " " + DtoC(MV_PAR03) + " - " + DtoC(Min(dDataBase,MV_PAR04))  //"Estado de Cuenta Corriente de Cliente"  ## " Titulos en : " ## " Titulos convertidos a : "
@ 001,08 To 033,nLargoBx
@ 153,08 To 187,nLargoBx
If !lPequena
	@ 08,355 BMPBUTTON Type 6 Action ImprimirC()
	If lFC060Con
		@ 08, 310 BUTTON OemToAnsi(STR0084) SIZE 40,11 ACTION ExecBlock("FC060CON",.F.,.F.)  // "Consulta"
	EndIf
Else
	@ 06,267 BMPBUTTON Type 6 Action ImprimirC()
	If lFC060Con
		@ 06, 200 BUTTON OemToAnsi(STR0084) SIZE 40,11 ACTION ExecBlock("FC060CON",.F.,.F.)  // "Consulta"
	EndIf
Endif
@ 07,014 SAY cCliente + "-" + cLoja + "  " + cNomeCli + IIf(Empty(cTel),"",OemToAnsi(STR0012) + cTel) SIZE 300,10 // "              Telefono : "
@ 19,014 SAY OemToAnsi(STR0013) + Trans(nDebito,cPict)  SIZE 80,20 COLOR CLR_BLUE,CLR_WHITE   // "Debitos Anteriores "  // COLOR "b/w"
@ 19,120 SAY OemToAnsi(STR0014) + Trans(nCredito,cPict)  SIZE 80,20 COLOR CLR_HRED,CLR_WHITE  // "Creditos Anteriores "  // COLOR "r+/w"
@ 19,230 SAY OemToAnsi(STR0015) + Trans(nSaldoIni,cPict1)  SIZE 80,20 COLOR nPictSal,CLR_WHITE // "Saldo Acumulado   // COLOR cPictSal
If Len(aCols) == 0
	aCols := Array(1,Len(aHeader))
	Afill( aCols[1], " ") // para nao dar erro no listbox, qdo o aCols contem so NIL's.
Endif
oLbx := RDListBox(2.4, 1, nLargoBx-8, 117, aCols, aHeader,,,, {||DetDblclk("C")} )
@ 158,014 SAY OemToAnsi(STR0064) SIZE 45,10 // "Saldo Economico:"
@ 167,014 SAY OemToAnsi(STR0016) SIZE 72,10 // "PERIODO --->"
@ 167,055 SAY OemToAnsi(STR0017) + Trans(nDebPeri,cPict) SIZE 80,10 COLOR CLR_BLUE,CLR_WHITE    // "Debitos : "  // COLOR "b/w"
@ 167,140 SAY OemToAnsi(STR0018) + Trans(nCredPeri,cPict) SIZE 80,10 COLOR CLR_HRED,CLR_WHITE   // "Creditos : "  // COLOR "r+/w"
@ 167,230 SAY OemToAnsi(STR0019) + Trans(nSaldoPeri,cPict1) SIZE 80,10 COLOR nPictSLPer,CLR_WHITE // "Saldo Periodo:"  // COLOR cPictSLPer

@ 177,014 SAY OemToAnsi(STR0020) SIZE 72,10 // "TOTALES --->"
@ 177,055 SAY OemToAnsi(STR0017) + Trans(nTotDeb,cPict) SIZE 80,10 COLOR CLR_BLUE,CLR_WHITE  // "Debitos : "  // COLOR "b/w"
@ 177,140 SAY OemToAnsi(STR0018) + Trans(nTotCred,cPict) SIZE 80,10 COLOR CLR_HRED,CLR_WHITE  // "Creditos : "  // COLOR "r+/w"
@ 177,230 SAY OemToAnsi(STR0021) + Trans(nTotSaldo,cPict1) SIZE 80,10 COLOR nPictTotS,CLR_WHITE // "Saldo Total : "  // COLOR cPictTotS

@ 192,014 SAY OemToAnsi(STR0071) + Trans(nSldChq,cPict) SIZE 90,10   // "Saldo de cheques: "

If !lPequena
	@ 190, 120 BUTTON OemToAnsi(STR0085) SIZE 40,11 ACTION Cheques()   //"Cheques"
	@ 188, 356 BMPBUTTON Type 1 Action Close(oDialog)
Else
	@ 190, 100 BUTTON OemToAnsi(STR0085) SIZE 40,11 ACTION Cheques()   //"Cheques"
	@ 188, 263 BMPBUTTON Type 1 Action Close(oDialog)
EndIf

Activate Dialog oDialog CENTERED

dbSelectArea("TRB")
DbCloseArea()
If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif
RestArea(aAreaAnt)

RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GERATRB  ³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 20.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion del archivo temporal con la informacion de la   ³±±
±±³          ³ deuda con un Cliente.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraTrbc()
Local cSimb			:=	Alltrim(GetMV("MV_SIMB1"))
Local nVlrCorre 	:= 0
Local nVlrMoePe 	:= 0
Local	nTotPerTb	:= 0
Local lGeraTrb		:= .T.
Local aSaldos		:= {0,0,0}
Local aRecibos		:=	{}
Local aAreaSEL		:=	{}
Local lVersao		:= .F.
Private aTamREC := TamSX3( "E1_RECIBO")
Private nSaldoTit	:= 0 
Private lContab		:= .T.

If cPaisLoc $ "ARG"
	DbSelectArea("SEL")
	lVersao := .T.
EndIf

ProcRegua(SE1->(RecCount()))

SE1->(DbSetOrder(2))
SE1->(DbSeek(xFilial("SE1")+mv_par01+mv_par02))

Do while !SE1->(EOF()) .And. xFilial("SE1")== SE1->E1_FILIAL .And. SE1->E1_CLIENTE == mv_par01 .and. IIf(!Empty(mv_par02),SE1->E1_LOJA == mv_par02,.T.)
	
	If  cPaisLoc=="ARG" .And. mv_par06 <> 1  .And.  SE1->E1_CONVERT=='N'
		SE1->(DbSkip())
		Loop
	Endif
	lGeraTrb := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o titulo deve ser processado pela consulta.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cPaisLoc == "CHI" .Or. !(SE1->E1_TIPO $ iiF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE))) .And.;
		(mv_par06 == SE1->E1_MOEDA .Or. mv_par07 == 1 )
		IncProc()
		
		If ( "FINA087" $ Upper(AllTrim(SE1->E1_ORIGEM)) )
			If ( Alltrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT ) //.And. ( !(Alltrim(SE1->E1_TIPO)$ "JR/MT/IS/DC/LJ/CP/BA/VL") )
				lContab := .F.
			Else
				lContab := .T.
			Endif
		Else
			lContab := .T.
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula o saldo do periodo anterior.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_EMISSAO < mv_par03
		
			AtuTotSld("SE1")
			VerBaixas(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o saldo do intervalo pedido.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf SE1->E1_EMISSAO <= Min(dDataBase,mv_par04)
	
			aSaldos := AtuTotSld("SE1")
			VerBaixas(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mostra os titulos sem saldo?                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par05 == 2
				nSaldoTit   := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par06,Min(dDataBase,mv_par04),Min(dDataBase,mv_par04),SE1->E1_LOJA,xFilial("SE1"),Iif(MV_PAR09==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
				
				If nSaldoTit <= 0
					SE1->(DbSkip())
					Loop
				Endif
			Endif

			If !lContab
				SE1->(DbSkip())
				Loop
			Endif

			If ( Alltrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT .Or. Substr(SE1->E1_TIPO,3,1)=="-" ) .And.;
			   ( "FINA087" $ Upper(AllTrim(SE1->E1_ORIGEM)) )
				
				RecLock("TRB",.T.)
				lGeraTrb		:= .T.
				TRB->CREDITO	:= IIf(mv_par05==1,aSaldos[1],nSaldoTit)
				TRB->CREDDEB	:= "2"
			Else
				RecLock("TRB",.T.)
				lGeraTrb		:= .T.
				If ( Alltrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT )
					TRB->CREDITO	:= IIf(mv_par05==1,aSaldos[1],nSaldoTit)
					TRB->CREDDEB	:= "2"
				Else
					TRB->DEBITO		:= IIf(mv_par05==1,aSaldos[2],nSaldoTit)
					TRB->CREDDEB	:= "1"
				Endif
			Endif
		
			If lGeraTrb
				TRB->NUMERO  := SE1->E1_NUM
				TRB->TIPO    := SE1->E1_TIPO
				TRB->CUOTA   := SE1->E1_PARCELA
				TRB->PREFIJO := SE1->E1_PREFIXO
				TRB->SALTIT  := Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par06,dDataBase,nDecs+1,Iif(MV_PAR09==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),nDecs)
				TRB->EMISSAO := SE1->E1_EMISSAO
				If SE1->E1_SALDO > 0.00
					If SE1->E1_VENCTO == dDataBase
						TRB->VENCTO := OemToAnsi(STR0022)  // "Vence HOY"
					ElseIf SE1->E1_VENCTO < dDataBase.And.!Empty(SE2->E2_VENCTO )
						TRB->VENCTO := Str(dDataBase-SE1->E1_VENCTO,4) + OemToAnsi(STR0023)  // " dias de atraso"
					Else
						TRB->VENCTO := Dtoc(SE1->E1_VENCTO)
					Endif
				Else
					TRB->VENCTO := OemToAnsi(STR0048) + Dtoc(SE1->E1_BAIXA) // "Cobrado el "
				Endif
				//Correcao monetaria para os titulos
				If SE1->E1_MOEDA <> mv_par06
					TRB->CORRECAO += aSaldos[3]
				Else
					TRB->CORRECAO := 0
				EndIf
				MsUnLock()
			EndIf
		EndIf
	EndIf
	
	SE1->(DbSkip())
	
Enddo

SEL->(DbSetOrder(3))
SEL->(DbSeek(xFilial("SEL")+mv_par01+mv_par02))

While SEL->EL_DTDIGIT <= Min(dDataBase,mv_par04) .and. !SEL->(EOF()) .And. SEL->EL_CLIENTE == mv_par01 .and. IIf(!Empty(mv_par02), SEL->EL_LOJA == mv_par02,.T.);
	.AND. Iif(lVersao,SEL->EL_VERSAO == F841VERSA(SEL->EL_RECIBO,SEL->EL_SERIE),.T.)
	
	If  SEL->EL_DTDIGIT < mv_par03 .And. !SEL->EL_CANCEL .And. (mv_par07 == 1 .Or. mv_par06 == Val(SEL->EL_MOEDA))

		If AllTrim(SEL->EL_TIPODOC) $ "TB" .Or. AllTrim(SEL->EL_TIPODOC) $ MV_CRNEG+","+MVRECANT
			
			AtuTotSld("SEL")
			
		ElseIf AllTrim(SEL->EL_TIPODOC) $ iiF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE) // Monta array de cheques
			nSaldoTit := SaldoTit(SEL->EL_PREFIXO,SEL->EL_NUMERO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_NATUREZ,"R",SEL->EL_CLIENTE,mv_par06,Min(dDataBase,mv_par04),Min(dDataBase,mv_par04),SEL->EL_LOJA,xFilial("SEL"))
			If nSaldotit   >  0
				nSldChq   += nSaldoTit  // acumulador do saldo em cheques
				AddCheques()
			Endif
		EndIf
		
		SEL->(DbSkip())
	Else
		cSerAnt    := SEL->EL_SERIE		
		cRcAnt     := SEL->EL_RECIBO
		dDtAnt     := SEL->EL_DTDIGIT
		nSaldoTit  := 0
		nTotRa     := 0
		nTotTb     := 0
		nSldT      := 0
		nVlrCorre  := 0
		nVlTitAtu  := 0
		nVlTitCri  := 0
		nTotPerTb  := 0
		aAreaSEL		:=	SEL->(GetArea())
		If Ascan(aRecibos,{|x| x==cSerAnt+cRcAnt}) == 0
			AAdd(aRecibos,cSerAnt+cRcAnt)
			SEL->(DbSetOrder(8))
			SEL->(DbSeek(xFilial()+cSerAnt+cRcAnt))
		   While SEL->EL_RECIBO==cRcAnt.and.SEL->EL_SERIE==cSerAnt.and.SEL->EL_CLIENTE==mv_par01.and.SEL->EL_LOJA==MV_PAR02 .AND. Iif(lVersao,SEL->EL_VERSAO == F841VERSA(SEL->EL_RECIBO,SEL->EL_SERIE),.T.)
				If mv_par07 == 2 .And. mv_par06 <> Val(SEL->EL_MOEDA)
					SEL->(DbSkip())
					Loop
				Endif
				
				If !SEL->EL_CANCEL
					
					SE1->(DbSetOrder(2))
					SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
	
					Do Case				
					Case Alltrim(SEL->EL_TIPODOC)== "TB" .And. !(ALLTRIM(SEL->EL_TIPO)$ MVCHEQUES)
						nSaldoTit := SEL->EL_VALOR *((SEL->EL_VLMOED1/SEL->EL_VALOR)/RecMoeda(SEL->EL_DTDIGIT,mv_par06))
						If mv_par05 == 1
							If !(AllTrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT) .And. Substr(SE1->E1_TIPO,3,1)<>"-"
								nTotTb += nSaldoTit
							Else
								nTotTb -= nSaldoTit
							EndIf
						Else
							If !(AllTrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT) .And. Substr(SE1->E1_TIPO,3,1)<>"-"
								nTotPerTb += nSaldoTit
							Else
								nTotPerTb -= nSaldoTit
							EndIf
						EndIf						
					Case Alltrim(SEL->EL_TIPODOC)=="RA" 
						If mv_par05 == 1
							nTotRa 	 += SEL->EL_VALOR *((SEL->EL_VLMOED1/SEL->EL_VALOR)/RecMoeda(SEL->EL_DTDIGIT,mv_par06))
	  					Else
							nSaldoTit := SaldoTit(SEL->EL_PREFIXO,SEL->EL_NUMERO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_NATUREZ,"R",SEL->EL_CLIENTE,mv_par06,Min(dDataBase,mv_par04),Min(dDataBase,mv_par04),SEL->EL_LOJA,xFilial("SE5"))
							nTotRa 	 += nSaldoTit
							nTotPerTb += SEL->EL_VALOR *((SEL->EL_VLMOED1/SEL->EL_VALOR)/RecMoeda(SEL->EL_DTDIGIT,mv_par06))
	  					EndIf					
					Case SE1->(Found()) .And. ALLTRIM(SEL->EL_TIPODOC)$ MVCHEQUES .And. SE1->E1_SALDO > 0.00
						nSaldoTit := SaldoTit(SEL->EL_PREFIXO,SEL->EL_NUMERO,SEL->EL_PARCELA,SEL->EL_TIPO,SEL->EL_NATUREZ,"R",SEL->EL_CLIENTE,mv_par06,Min(dDataBase,mv_par04),Min(dDataBase,mv_par04),SEL->EL_LOJA,xFilial("SE5"))
						nSldT   := nSldT   + nSaldoTit
						nSldChq := nSldChq + nSaldoTit // acumula saldo de cheques
						If nSaldotit   >  0            // Monta Array de cheques para futura consulta
							AddCheques()
						Endif
					EndCase
				Endif
	
				If ALLTRIM(SEL->EL_TIPODOC) == "TB" .Or. ALLTRIM(SEL->EL_TIPODOC)== "RA"  
					nVlTitAtu := Round(xMoeda(SEL->EL_VALOR,Max(Val(SEL->EL_MOEDA),1),mv_par06,Min(dDataBase,mv_par04),nDecs+1),nDecs)
					nVlTitCri := SEL->EL_VALOR *((SEL->EL_VLMOED1/SEL->EL_VALOR)/RecMoeda(SEL->EL_DTDIGIT,mv_par06))
					nVlrCorre += nVlTitAtu - nVlTitCri
				EndIf
				SEL->(DbSkip())
			Enddo
			
			If mv_par05 == 2
			If nTotRA <> 0
				RecLock("TRB",.T.)
				TRB->NUMERO 	:= cRcAnt
				TRB->TIPO   	:= "RC"
				TRB->EMISSAO	:= dDtAnt
				TRB->CREDITO	:= Round(nTotRa,nDecs)
				TRB->SALTIT 	:= Round(nTotRa,nDecs)
				TRB->CORRECAO 	:= nVlrCorre 
				TRB->CREDDEB    := "2"
				MsUnLock()
			Endif	
			AtuTotSld("SE2",nTotPerTb+nVlrCorre)					
			Else
				RecLock("TRB",.T.)
				TRB->SERIE 		:= cSerAnt
				TRB->NUMERO 	:= cRcAnt
				TRB->TIPO   	:= "RC"
				TRB->EMISSAO	:= dDtAnt
				TRB->CREDITO	:= Round(nTotTb+nTotRa,nDecs)
				TRB->SALTIT 	:= Round(nSldT,nDecs)
				TRB->CORRECAO 	:= nVlrCorre 
				TRB->CREDDEB   := "2"
				MsUnLock()
				nSaldo  			:= nSaldo - TRB->CREDITO
			AtuTotSld('SE2',TRB->CREDITO+nVlrCorre)			
			EndIf
		Endif
		RestArea(aAreaSEL)
		DbSkip()
	EndIf
Enddo

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DetDblclk()³ Autor ³ Leonardo Ruben      ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Detalhes (double click no ListBox da deuda do cli/for)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DetDblClk( cCliFor)
Local cTipo
Local cPrefNum
Local cCuota
Local aHeaderRC := {}
Local aColsRC   := {}
Local nZ        := 0
Local nVlrTot   := 0
Local nMoedaBco := 1
Local nPosIni   := 0

If (Subs( AllTrim(aCols[oLbx:nAt][2]), 1, 2) = "RC" .and. cCliFor = "C") .or.;
		(Subs( AllTrim(aCols[oLbx:nAt][2]), 1, 2) = "OP" .and. cCliFor = "F")
	If( cCliFor = "C", DetRecCli(), DetRecFor() )
Else
	//Identifica posicao inicial para considerar o numero do titulo dentro do aCols
	nPosIni := Iif( Subs(aCols[oLbx:nAt][2],1,3)="   ",9,6)
	//Generase un aColsRC para informar las bajas (SE5)
	cTipo    := Subs( aCols[oLbx:nAt][2] , nPosIni-5, 3 )
	cPrefNum := Subs( aCols[oLbx:nAt][2] , nPosIni, TamSx3("E5_NUMERO")[1]+3 )
	cCuota   := Right( aCols[oLbx:nAt][2] , 1)
	
	aHeaderRC := {}
	aColsRC   := {}
	nZ        := 0
	nVlrTot   := 0
	
	AADD(aHeaderRC, OemToAnsi(STR0061)) // "Fecha"
	AADD(aHeaderRC, OemToAnsi(STR0068)) // "Valor"
	AADD(aHeaderRC, OemToAnsi(STR0069)) // "Moneda"
	AADD(aHeaderRC, OemToAnsi(STR0062)) // "Historico"
	AADD(aHeaderRC, OemToAnsi(STR0059)+MV_MOEDA1) // "Valor en "
	
	DbSelectArea("SE5")
	DbSetOrder(7)
	DbSeek( xFilial("SE5")+ cPrefNum+cCuota+cTipo+MV_PAR01+MV_PAR02)
	If !Found()
		Return
	EndIf
	While !SE5->(EOF()) .AND. ;
			E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO == cPrefNum+cCuota+cTipo .AND.;
			E5_CLIFOR+E5_LOJA == MV_PAR01+MV_PAR02
		If (cCliFor == "C" .and. E5_RECPAG <> "R") .or.;
				(cCliFor == "F" .and. E5_RECPAG <> "P").Or. (E5_TIPODOC $ MVPAGANT+","+MVRECANT)
			SE5->(DbSkip())
			Loop
		EndIf
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
		nMoedaBco := Max(SA6->A6_MOEDA,1)
		
		If cCliFor=="C"
			SE1->(DbSetOrder(1))
		   	SE1->(MsSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
		Else
			SE2->(DbSetOrder(1))
			SE2->(MsSeek(xFilial("SE2")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))
		EndIf
		Aadd(aColsRC,Array(Len(aHeaderRC)))
		nVlrMd1 := SE5->E5_VALOR
		nVlrTot := nVlrTot + xMoeda(SE5->E5_VALOR,1,If(cCliFor=="C",SE1->E1_MOEDA,SE2->E2_MOEDA),SE5->E5_DATA )
		nZ      += 1
		aColsRC[nZ][1] := DtoC( SE5->E5_DATA)
		aColsRC[nZ][2] := TRANSform( xMoeda(SE5->E5_VALOR,1,If(cCliFor=="C",SE1->E1_MOEDA,SE2->E2_MOEDA),SE5->E5_DATA ),cPict)
		aColsRC[nZ][3] := SE5->E5_MOEDA
		aColsRC[nZ][4] := Alltrim( SE5->E5_HISTOR)
		aColsRC[nZ][5] := TRANSform( SE5->E5_VALOR,cPict)
		SE5->(DbSkip())
	Enddo
	
	@ 114,153 To 295,606 Dialog oDialogRC Title OemToAnsi( STR0067)+" "+AllTrim(aCols[oLbx:nAt][2])  // "Detalles baja "
	
	If Len(aColsRC) == 0
		aColsRC := Array(1,Len(aHeaderRC))
		Afill( aColsRC[1], " ") // para nao dar erro no listbox, qdo o aColsRC contem so NIL's.
	Endif
	oLbxRC := RDListBox(0.5, 0.5, 220, 70, aColsRC, aHeaderRC )
	
	If  Val(aCols[oLbx:nAt][6]) <> 0
		@ 82,010 SAY OemToAnsi(STR0070)  + Trans(aCols[oLbx:nAt][6],cPict) SIZE 80,10 // "Saldo: "
	Else
		//Bru
		@ 82,010 SAY OemToAnsi(STR0078)  SIZE 80,10 //"Saldado "
	Endif
	
	
	Activate Dialog oDialogRC CENTERED
	
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DetRecCli()³ Autor ³ Leonardo Ruben      ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Detalhes (double click no ListBox da deuda do cliente)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DetRecCli()

//Generase un aColsRC para informar los cheques del recibo
Local aHeaderRC := {}
Local aColsRC   := {}
Local nZ        := 0
Local nVlrFin   := 0
Local nVlrAcr   := 0
Local cRcAnt
Local cSerAnt
Local cStr

AADD(aHeaderRC, OemToAnsi(STR0058)) // "Cheque"
AADD(aHeaderRC, OemToAnsi(STR0068)) // "Valor"
AADD(aHeaderRC, OemToAnsi(STR0069)) // "Moneda"
AADD(aHeaderRC, OemToAnsi(STR0060)) // "Situacao"
AADD(aHeaderRC, OemToAnsi(STR0059)+MV_MOEDA1) // "Valor en "

DbSelectArea("SEL")
DbSetOrder(8)                                   
cSerAnt := Subs( AllTrim(aCols[oLbx:nAt][2]), 9,Len(TRB->SERIE))
cRcAnt  := Subs( AllTrim(aCols[oLbx:nAt][2]),12,Len(TRB->NUMERO))
DbSeek( xFilial("SEL")+cSerAnt+cRcAnt)
While SEL->EL_RECIBO==cRcAnt.and.SEL->EL_SERIE==cSerAnt.and.SEL->EL_CLIENTE==mv_par01.and.SEL->EL_LOJA==MV_PAR02
	If ALLTRIM(SEL->EL_TIPODOC)$ ALLTRIM(MVCHEQUES)
		SE1->(DbSetOrder(1))
		SE1->(DbSeek( xFilial("SE1")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO ))
		If SE1->(Found()) .And. SE1->E1_SALDO > 0.00
			Aadd(aColsRC,Array(len(aHeaderRC)))
			nVlrFin += SEL->EL_VLMOED1
			nZ      := nZ + 1
			aColsRC[nZ][1] := AllTrim(SEL->EL_TIPODOC)+"  "+SEL->EL_PREFIXO+SEL->EL_NUMERO
			aColsRC[nZ][2] := TRANSform(SEL->EL_VALOR,cPict)
			aColsRC[nZ][3] := SEL->EL_MOEDA
			//SITCOB
			aColsRC[nZ][4] := AllTrim( FN022SITCB( SE1->E1_SITUACA )[9] )
			If FN022SITCB( SE1->E1_SITUACA )[1]		// CARTERA
				aColsRC[nZ][4] := aColsRC[nZ][4] + " ("+OemToAnsi(STR0065)+DTOC(SEL->EL_DTVCTO)+")"  //"dep. en "
			ElseIf FN022SITCB( SE1->E1_SITUACA )[2] // COBRANZA SIMPLE
				aColsRC[nZ][4] := aColsRC[nZ][4] + " ("+OemToAnsi(STR0066)+DTOC(SE1->E1_DTACRED)+")" //"clearing "
			EndIf
			aColsRC[nZ][5] := TRANSform( SEL->EL_VLMOED1,cPict)
		Else
			If SE1->(Found())
				If AllTrim( SE1->E1_ORDPAGO) <> "" // cheque usado en una OP
					cStr  := OemToAnsi(STR0077) +AllTrim( SE1->E1_ORDPAGO)
				ElseIf SE1->E1_STATUS <> "R"
					cStr  := OemToAnsi(STR0079)+Dtoc(SE1->E1_BAIXA) //"Acreditado el "
				Else
					cStr  := OemToAnsi(STR0080)+Dtoc(SE1->E1_BAIXA) //"Rechazado el "
				Endif
			Else
				cStr  := OemToAnsi(STR0081)//"Desconocida"
			Endif
			Aadd(aColsRC,Array(len(aHeaderRC)))
			nZ      := nZ + 1
			aColsRC[nZ][1] := AllTrim(SEL->EL_TIPO)+"  "+SEL->EL_PREFIXO+SEL->EL_NUMERO
			aColsRC[nZ][2] := TRANSform(SEL->EL_VALOR,cPict)
			aColsRC[nZ][3] := SEL->EL_MOEDA
			aColsRC[nZ][4] := cStr
			aColsRC[nZ][5] := TRANSform( SEL->EL_VLMOED1,cPict)
			nVlrAcr += SEL->EL_VLMOED1
		EndIf
	ElseIf (ALLTRIM(SEL->EL_TIPO) $ "TF,EF") .or. ;
			(ALLTRIM(SEL->EL_TIPO) $ MV_CRNEG+","+MVRECANT .And. ALLTRIM(SEL->EL_TIPODOC)="TB")
		Aadd(aColsRC,Array(len(aHeaderRC)))
		nZ      := nZ + 1
		aColsRC[nZ][1] := AllTrim(SEL->EL_TIPO)+"  "+SEL->EL_PREFIXO+SEL->EL_NUMERO
		aColsRC[nZ][2] := TRANSform(SEL->EL_VALOR,cPict)
		aColsRC[nZ][3] := SEL->EL_MOEDA
		aColsRC[nZ][4] := OemToAnsi(STR0079)+Dtoc(SEL->EL_DTDIGIT) //"Acreditado el
		aColsRC[nZ][5] := TRANSform( SEL->EL_VLMOED1,cPict)
		nVlrAcr += SEL->EL_VLMOED1
	EndIf
	SEL->(DbSkip())
Enddo

@ 114,153 To 295,606 Dialog oDialogRC Title OemToAnsi( STR0063)+" "+AllTrim(aCols[oLbx:nAt][2])  // "Detalles"

If Len(aColsRC) == 0
	aColsRC := Array(1,Len(aHeaderRC))
	Afill( aColsRC[1], " ") // para nao dar erro no listbox, qdo o aColsRC contem so NIL's.
Endif
oLbxRC := RDListBox(0.5, 0.5, 220, 70, aColsRC, aHeaderRC )

@ 82,010 SAY OemToAnsi(STR0072) + Trans(nVlrFin,cPict) SIZE 80,10 // "Deuda Financiera: "
@ 82,110 SAY OemToAnsi(STR0073) + Trans(nVlrAcr,cPict) SIZE 80,10 // "Acreditado: "

Activate Dialog oDialogRC CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DetRecFor()³ Autor ³ Leonardo Ruben      ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Detalhes (double click no ListBox da deuda do fornecedor)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DetRecFor()

//Generase un aColsRC para informar los cheques de la orden de pago
Local aHeaderRC := {}
Local aColsRC   := {}
Local nZ        := 0
Local nVlrVen   := 0
Local nVlraVe   := 0
Local nVlrDeb   := 0
Local nVlrAcr   := 0
Local cStr
Local cPagAnt

AADD(aHeaderRC, OemToAnsi(STR0058)) // "Cheque"
AADD(aHeaderRC, OemToAnsi(STR0068)) // "Valor"
AADD(aHeaderRC, OemToAnsi(STR0069)) // "Moneda"
AADD(aHeaderRC, OemToAnsi(STR0060)) // "Situacao"
AADD(aHeaderRC, OemToAnsi(STR0059)+MV_MOEDA1) // "Valor en "

DbSelectArea("SEK")
DbSetOrder(1)
cPagAnt := Subs( AllTrim(aCols[oLbx:nAt][2]), 9)
DbSeek( xFilial("SEK")+cPagAnt)
While SEK->EK_ORDPAGO == cPagAnt .And. &cCondSEK
	
	//Verifica se agregou por Fornecedor
	If If(lAgregSEK .and. !Empty(SEK->EK_FORNEPG), ;
			SEK->EK_FORNEPG == mv_par01 .And. SEK->EK_LOJAPG == mv_par02, ;
			SEK->EK_FORNECE == mv_par01 .And. SEK->EK_LOJA   == mv_par02  ) .And. ;
			( AllTrim(SEK->EK_TIPO) $ MVCHEQUES + ",TF,EF"  .OR. ;
			( AllTrim(SEK->EK_TIPO) $ MV_CPNEG + "," + MVPAGANT .And. ;
			Alltrim(SEK->EK_TIPODOC)=="TB") )   
		
		SE2->(DbSetOrder(1))
		SE2->(DbSeek( xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO ))
		Aadd(aColsRC,Array(len(aHeaderRC)))
		nZ++
		aColsRC[nZ,1] := AllTrim(SEK->EK_TIPO)+"  "+SEK->EK_PREFIXO+SEK->EK_NUM
		aColsRC[nZ,2] := TRANSform(SEK->EK_VALOR,cPict)
		aColsRC[nZ,3] := SEK->EK_MOEDA
		aColsRC[nZ,5] := TRANSform( SEK->EK_VLMOED1,cPict)
		IF SE2->(Found()) .And. SE2->E2_SALDO > 0.00
			If SE2->E2_VENCTO >= dDataBase
				nVlraVe += SEK->EK_VLMOED1
				cStr    := OemToAnsi(STR0005)+Dtoc(SE2->E2_BAIXA) //"Debito"
			Else
				nVlrVen += SEK->EK_VLMOED1
				cStr    := OemToAnsi(STR0082)+Dtoc(SE2->E2_VENCTO) //"Sin Debitar "
			EndIf
			aColsRC[nZ,4] := cStr
		ELSEIF SE2->(Found())
			nVlrAcr := nVlrAcr + SEK->EK_VLMOED1
			aColsRC[nZ,4] := OemToAnsi(STR0083)+Dtoc(SE2->E2_BAIXA) //"Debitado el "
		Else
			nVlrDeb += SEK->EK_VLMOED1
			aColsRC[nZ,4] := OemToAnsi(STR0079)+Dtoc(SEK->EK_DTDIGIT) //"Acreditado el
		Endif
	Endif
	
	SEK->(DbSkip())
Enddo

@ 114,153 To 302,606 Dialog oDialogRC Title OemToAnsi( STR0063)+" "+AllTrim(aCols[oLbx:nAt][2])  // "Detalles"

If Len(aColsRC) == 0
	aColsRC := Array(1,Len(aHeaderRC))
	Afill( aColsRC[1], " ") // para nao dar erro no listbox, qdo o aColsRC contem so NIL's.
Endif
oLbxRC := RDListBox(0.5, 0.5, 220, 70, aColsRC, aHeaderRC )

@ 80,010 SAY OemToAnsi(STR0074) + Trans(nVlrVen,cPict) SIZE 80,10 // "Vencido: "
@ 87,010 SAY OemToAnsi(STR0075) + Trans(nVlraVe,cPict) SIZE 80,10 // "A vencer: "
@ 80,110 SAY OemToAnsi(STR0076) + Trans(nVlrDeb,cPict) SIZE 80,10 // "Debitado: "

Activate Dialog oDialogRC CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Imprimir  ³ Autor ³ Bruno Sobieski        ³ Data ³ 20.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao da conta corrente do fornecedor.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Imprimir
Static Function ImprimirC()
TRB->(DbGoTop())
If TRB->(EOF()).And.TRB->(BOF())
	Return
Endif
tamanho := "M"
limite  := 220
aOrd    := {}
titulo  := PADC(OemToAnsi(STR0050),74)  // "Resumen de cuenta corriente"
cDesc1  := PADC(OemToAnsi(STR0051),74)  // "Resumen de cuenta corriente del cliente"
cDesc2  := cCliente+"-"+cLoja+" "+cNomeCli+OemToAnsi(STR0052)+cTel  // " Tel: "
cDesc3  := ""
//"Especial","Administracion"
aReturn := { OemToAnsi(STR0032), 1,OemToAnsi(STR0033), 2, 1,1,"",1 }

cNomeprog := "FINC060"
cPerg     := ""
nLastKey  := 0
lContinua := .T.
nLin      := 0
wnrel     := "CORCLI"
cString   := "SE1"

cTitulo  := OemToAnsi(STR0053)+IIf(Mv_par07==2,OemToAnsi(STR0101),OemToAnsi(STR0102))+ GetMv("MV_MOEDA"+STR(mv_par06,1))   // "Informe estado de cuenta del Cliente"  ## " Titulos en : " ## " Titulos convertidos a : "
cTamanho := "M"
cCabec1  := cCliente+"-"+cLoja+" "+cNomeCli+OemToAnsi(STR0052)+cTel  // " Tel: "
If mv_par08 == 1
	cCabec2 := OemToAnsi(STR0106)
Else	
	cCabec2 := OemToAnsi(STR0054)
EndIf	
cbtxt   := ""
cbcont  := 1
M_PAG   := 1 // <--- la pide la funcion cabec.... ???
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,,,.F.)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> RptStatus({|| Execute(RptDetail)})
RptStatus({|| RptDetail("C")})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cheques   ³ Autor ³ Leonardo Ruben        ³ Data ³ 16.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Listado de cheques                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cheques()
lRet	:=	.T.

@ 114,153 To 295,606 Dialog oDialogCH Title OemToAnsi(STR0096)  //"Listado de cheques"

If Len(aColsCH) == 0
	aColsCH := Array(1,Len(aHeaderCH))
	Afill( aColsCH[1], " ") // para nao dar erro no listbox, qdo o aColsCH contem so NIL's.
Endif
oLbxCH := RDListBox(0.5, 0.5, 220, 70, aColsCH, aHeaderCH )

Activate Dialog oDialogCH CENTERED

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AddCheques³ Autor ³ Leonardo Ruben        ³ Data ³ 16.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array de cheques para futura consulta                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddCheques()

SE1->(DbSetOrder(1))
SE1->(DbSeek( xFilial("SE1")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO ))

Aadd(aColsCH,Array(len(aHeaderCH)))
nZCH++
aColsCH[nZCH][1] := AllTrim(SEL->EL_TIPO)+"  "+SEL->EL_PREFIXO+SEL->EL_NUMERO
aColsCH[nZCH][2] := TRANSform(SEL->EL_VALOR,cPict)
aColsCH[nZCH][3] := SEL->EL_MOEDA
//Verifica a situacao do cheque
If SE1->(Found())
	aColsCH[nZCH][4] := AllTrim( FN022SITCB( SE1->E1_SITUACA )[9] )
	If FN022SITCB( SE1->E1_SITUACA )[1]		// CARTERA
		aColsCH[nZCH][4] := aColsCH[nZCH][4] + " ("+OemToAnsi(STR0065)+DTOC(SEL->EL_DTVCTO)+")"  //"dep. en "
	ElseIf FN022SITCB( SE1->E1_SITUACA )[2] // COBRANZA SIMPLE
		aColsCH[nZCH][4] := aColsCH[nZCH][4] + If( !Empty(SE1->E1_DTACRED)," ("+OemToAnsi(STR0066)+DTOC(SE1->E1_DTACRED)+")","") //"clearing "
	EndIf
Else
	aColsCH[nZCH][4] := ""
EndIf
aColsCH[nZCH][5] := Transform(nSaldoTit, cPict)
aCOlsCH[nZCH][6] := DtoC( SEL->EL_DTDIGIT)
aCOlsCH[nZCH][7] := SEL->EL_SERIE+"-"+SEL->EL_RECIBO

Return .T.

// Calculo do valor da baixa manual de um titulo
Function VBaixaMCompra(cChave)
SE5->(DbSetOrder(7))
SE5->(DbSeek(xFilial("SE5") + cChave))
While cChave = SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) ;
		.AND. ! SE5->(EOF())
	If SE5->E5_DATA < mv_par03
		If (SE5->E5_TIPODOC $ "VL/JR/LJ/MT/IS/CP" .Or. (SE5->E5_TIPODOC=="BA" .And. Empty(SE5->E5_ORDREC))) .And. SE5->E5_SITUACA != "C" // Baixa manual, Juros, Multa
			If SE5->E5_TIPO $ MV_CPNEG+","+MVPAGANT 
				If mv_par05 = 1
					nDebito	+= SE5->E5_VALOR
				Else
					nDebito	+= Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
		 	Else
				If mv_par05 = 1
					nCredito += SE5->E5_VALOR
				Else
					nCredito += Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
		 	Endif
		ElseIf SE5->E5_TIPODOC = "ES" // Estorno de baixa
			If SE5->E5_TIPO $ MV_CPNEG+","+MVPAGANT 
				If mv_par05 = 1
					nDebito  -= SE5->E5_VALOR
				Else
					nDebito  -= Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
			Else
				If mv_par05 = 1
					nCredito -= SE5->E5_VALOR
				Else
					nCredito -= Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
			Endif
		ElseIf SE5->E5_TIPODOC = "DC" .And. SE5->E5_SITUACA != "C"// Desconto
			If SE5->E5_TIPO $ MV_CPNEG+","+MVPAGANT 
				If mv_par05 = 1
					nCredito += SE5->E5_VALOR
				Else
					nCredito += Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
			Else
				If mv_par05 = 1
					nDebito  += SE5->E5_VALOR
				Else
					nDebito  += Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
				EndIf
			
			Endif
		EndIf
	Endif
	SE5->(DbSkip())
EndDo
Return Nil

// Grava as baixas manuais que houverem do titulo corrente no arquivo de trabalho
Function LeBaixaMCompra(cChave)

Local cSeq, nReg
SE5->(DbSetOrder(7))
SE5->(DbSeek(xFilial("SE5") + cChave))
While cChave = SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) .And. ! SE5->(EOF())
	cSeq := SE5->E5_SEQ
	nReg := SE5->(Recno())
	If SE5->E5_DATA >= mv_par03 .And. SE5->E5_DATA <= Min(mv_par04,dDataBase)
		If SE5->E5_TIPODOC = "VL" // Baixa manual
			SE5->(DbSkip())
			If ! (cChave+cSeq = SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) ;
					.And. SE5->E5_TIPODOC = "ES") // Nao faz nada se Houver Estorno da baixa
				SE5->(DbGoto(nReg))
				RecLock("TRB",.T.)
				If SE5->E5_TIPO $ MV_CPNEG+","+MVPAGANT 
					If mv_par05 = 1
						TRB->DEBITO  := SE5->E5_VALOR
					Else
						TRB->DEBITO  := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
					EndIf
					TRB->SALDO 		:= nSaldo - TRB->DEBITO 
					TRB->CREDDEB   := "1"
					If Val(SE5->E5_MOEDA) <> mv_par05
						TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->DEBITO
					Endif
				Else
					If mv_par05 = 1
						TRB->Credito := SE5->E5_VALOR
					Else
						TRB->Credito := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
					EndIf
					TRB->Saldo 		:= nSaldo - TRB->Credito
					TRB->CREDDEB   := "2"
					If Val(SE5->E5_MOEDA) <> mv_par05
						TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->Credito
					Endif
	
				Endif
				TRB->NUMERO		:= SE5->E5_NUMERO
				TRB->TIPO		:= SE5->E5_TIPODOC
				TRB->CUOTA		:= SE5->E5_PARCELA
				TRB->PREFIJO	:= SE5->E5_PREFIXO
				TRB->SALTIT		:= 0 //Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par05,dDatabase,nDecs+1),nDecs)
				TRB->EMISSAO	:= SE5->E5_DATA
				TRB->(MsUnLock())
				nSaldo			:= TRB->Saldo
				//Tratamento para correcao monetaria em multi-moedas
			EndIf
		ElseIf SE5->E5_TIPODOC $ "JR/MT/DC/IS" .And. SE5->E5_SITUACA != "C" // Juros, Multa, Desconto
			RecLock("TRB",.T.)
			If SE5->E5_TIPODOC = "DC"
				TRB->CREDDEB 	:= "2"
				If mv_par05 = 1
					TRB->Credito := SE5->E5_VALOR
				Else
					TRB->Credito := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
				EndIf
				TRB->Saldo     := nSaldo - TRB->Credito
				//Tratamento para correcao monetaria em multi-moedas
				If Val(SE5->E5_MOEDA) <> mv_par05
					TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->Credito
				Endif
			Else
				TRB->CREDDEB := "1"
				If mv_par05 = 1
					TRB->Debito  := SE5->E5_VALOR
				Else
					TRB->Debito  := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
				EndIf
				TRB->Saldo     := nSaldo + TRB->Debito
				//Tratamento para correcao monetaria em multi-moedas
				If Val(SE5->E5_MOEDA) <> mv_par05
					TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->Debito
				Endif
			EndIf
			TRB->NUMERO		:= SE5->E5_NUMERO
			TRB->TIPO		:= SE5->E5_TIPODOC
			TRB->CUOTA		:= SE5->E5_PARCELA
			TRB->PREFIJO	:= SE5->E5_PREFIXO
			TRB->SALTIT		:= 0 //Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par05,dDatabase,nDecs+1),nDecs)
			TRB->EMISSAO	:= SE5->E5_DATA
			TRB->(MsUnLock())
			nSaldo			:= TRB->Saldo
		ElseIf SE5->E5_TIPODOC $ "DC/LJ/CP/BA" .And. Empty(SE5->E5_ORDREC).And. SE5->E5_SITUACA != "C"// Desconto
			RecLock("TRB",.T.)
			If SE5->E5_TIPO $ MV_CPNEG+","+MVPAGANT 
				TRB->CREDDEB := "1"
				If mv_par05 = 1
					TRB->DEBITO  := SE5->E5_VALOR
				Else
					TRB->DEBITO  := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
				EndIf
				TRB->SALDO     := nSaldo + TRB->DEBITO
				//Tratamento para correcao monetaria em multi-moedas
				If Val(SE5->E5_MOEDA) <> mv_par05
					TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->Debito
				Endif
			Else
				TRB->CREDDEB 	:= "2"
				If mv_par05 = 1
					TRB->CREDITO := SE5->E5_VALOR
				Else
					TRB->CREDITO  := Round(xMoeda(SE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par05,SE5->E5_DATA,nDecs+1),nDecs)
				EndIf
				TRB->SALDO     := nSaldo - TRB->CREDITO
				//Tratamento para correcao monetaria em multi-moedas
				If Val(SE5->E5_MOEDA) <> mv_par05
					TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(dDataBase,Val(SE5->E5_MOEDA))/RecMoeda(dDataBase,mv_par05)))- TRB->Credito
				Endif
			EndIf
			TRB->NUMERO		:= SE5->E5_NUMERO
			TRB->TIPO		:= SE5->E5_TIPODOC
			TRB->CUOTA		:= SE5->E5_PARCELA
			TRB->PREFIJO	:= SE5->E5_PREFIXO
			TRB->SALTIT		:= 0 //Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par05,dDatabase,nDecs+1),nDecs)
			TRB->EMISSAO	:= SE5->E5_DATA
			TRB->(MsUnLock())
			nSaldo			:= TRB->Saldo
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de baixa por dacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (MV_CPNEG+","+MVPAGANT $ ALLTRIM(SE2->E2_TIPO) .Or. !SUBSTR(SE2->E2_TIPO,3,1)=="-") .And.;
			(SE5->E5_MOTBX == "DAC" .And. SE5->E5_SITUACA <> "C" .And. SE5->E5_TIPODOC <> "CM") 
			RecLock("TRB",.T.)
			nVlrMoeTit 		:= Round(xMoeda(SE5->E5_VALOR,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,nDecs+1),nDecs)
			TRB->CREDITO 	:= Round(xMoeda(nVlrMoeTit,SE2->E2_MOEDA,mv_par05,SE2->E2_EMISSAO,nDecs+1),nDecs)
			TRB->NUMERO		:= SE5->E5_NUMERO
			TRB->TIPO 		:= "DAC"
			TRB->CUOTA		:= SE5->E5_PARCELA
			TRB->PREFIJO	:= SE5->E5_PREFIXO
			TRB->VENCTO 	:= Dtoc(SE5->E5_DATA)
			TRB->VENCTO		:= OemToAnsi(STR0024) + Dtoc(SE5->E5_DATA)  // "Pagado el "
			TRB->EMISSAO	:= SE5->E5_DATA
			TRB->CREDDEB 	:= "2"
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Correcao monetaria para titulos de dacao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE2->E2_MOEDA <> mv_par05
				TRB->CORRECAO += (nVlrMoeTit *(RecMoeda(dDataBase,SE2->E2_MOEDA)/RecMoeda(dDataBase,mv_par05)))- TRB->CREDITO
			Else
				TRB->CORRECAO := 0
			EndIf
			TRB->(MsUnLock())
		EndIf
	Endif
	SE5->(DbSkip())
EndDo

Return Nil
/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ Í»±±
±±ºProgram   ³AtuTotSld ºAuthor ³Alexandre Silva     º Date ³  05-30-03    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºDesc.     ³Atualiza os totais dos saldos baseado nos parametros forneci-º±±
±±º          ³dos.                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Í¹±±
±±ºParametro ³ cSldOri - Origem do saldo a ser atualizado SE1,SE2,SEL,SE5  º±±
±±º          ³ etc.                                                        º±±
±±º          ³ nVlrSomar, quando for processamentos do EL, informar o valorº±±
±±º          ³ a acrescentar ao saldo do perido.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºUse       ³ FINC060                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuTotSld(cSldOri,nVlrSomar)

Local nCreTitAtu := 0
Local nDebTitAtu := 0
Local nCorTitAtu := 0
Local nValorTit  := 0
Local aValores	  
Local nTaxa		 := 0
Do Case
Case  cSldOri == "SE1" .And. lContab
    nTaxa:=Iif(MV_PAR09==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)
	If ( Alltrim(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT .Or. Substr(SE1->E1_TIPO,3,1)=="-" ) .And.;
		!("FINA087" $ Upper( AllTrim( SE1->E1_ORIGEM)))
		nCreTitAtu := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR06,SE1->E1_EMISSAO,nDecs+1,nTaxa),nDecs)
		
	Else
		nDebTitAtu	:= Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR06,SE1->E1_EMISSAO,nDecs+1,nTaxa),nDecs)
	Endif
	
	//Correcao monetaria para os titulos
	If SE1->E1_MOEDA <> mv_par06
		If ALLTRIM(SE1->E1_TIPO)$MV_CRNEG+","+MVRECANT .Or. SUBSTR(SE1->E1_TIPO,3,1)=="-"
			nCorTitAtu  += (SE1->E1_VALOR *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- nCreTitAtu
		Else                              
			nCorTitAtu  += (SE1->E1_VALOR *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- nDebTitAtu
		EndIf
	EndIf

	//Atualiza o Periodo Anterior ou o Periodo Pedido.
	If SE1->E1_EMISSAO < mv_par03
		If nCreTitAtu > 0
			nCredito     +=  nCreTitAtu + nCorTitAtu
			nDebito      +=  nDebTitAtu
		Else
			nDebito      +=  nDebTitAtu + nCorTitAtu
			nCredito     +=  nCreTitAtu
		EndIf
	Else
		If nCreTitAtu > 0
			nCredPeri    +=  nCreTitAtu + nCorTitAtu
			nDebPeri     +=  nDebTitAtu
		Else
			nDebPeri     +=  nDebTitAtu + nCorTitAtu
			nCredPeri    +=  nCreTitAtu
		EndIf
	EndIf

Case cSldOri == "SEL"

		If mv_par06 == 1
			nValorTit := SEL->EL_VLMOED1
		Else
			nValorTit := xMoeda(SEL->EL_VALOR,Max(VAL(SEL->EL_MOEDA),1),MV_PAR06,SEL->EL_DTDIGIT,NDecs+1)
		EndIf			

		If AllTrim(SEL->EL_TIPODOC) $ "TB"
			SE1->(DbSetOrder(1))
			SE1->(DbSeek(xFilial("SE1")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO+SEL->EL_CLIENTE+SEL->EL_LOJA))
			If ALLTRIM(SE1->E1_TIPO)$ MV_CRNEG+","+MVRECANT .Or. SUBSTR(SE1->E1_TIPO,3,1)=="-"
				nDebTitAtu := nValorTit
				nCorTitAtu := (SEL->EL_VALOR *(RecMoeda(Min(dDataBase,mv_par04),Val(SEL->EL_MOEDA))/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- nDebTitAtu
			Else
				nCreTitAtu := nValorTit
				nCorTitAtu := (SEL->EL_VALOR *(RecMoeda(Min(dDataBase,mv_par04),Val(SEL->EL_MOEDA))/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- nCreTitAtu
			EndIf    
		ElseIf AllTrim(SEL->EL_TIPODOC) $ MV_CRNEG+","+MVRECANT
			nCreTitAtu :=  nValorTit
			nCorTitAtu := (SEL->EL_VALOR *(RecMoeda(Min(dDataBase,mv_par04),Val(SEL->EL_MOEDA))/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- nCreTitAtu
		EndIf

		If nCreTitAtu > 0
			nCredito     +=  nCreTitAtu + nCorTitAtu
			nDebito      +=  nDebTitAtu
		Else
			nDebito      +=  nDebTitAtu + nCorTitAtu
			nCredito     +=  nCreTitAtu
		EndIf

Case cSldOri == "SE2"
	nCredPeri := nCredPeri + nVlrSomar
EndCase

aValores := {nCreTitAtu,nDebTitAtu,nCorTitAtu}

Return aValores

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³VerOrdPag ºAuthor ³Alexandre Silva     º Date ³  03-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a ordem de pago atual e valida para a somatoria º±±
±±º          ³dos titulos.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC060                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VerOrdPag()

Local lRet := .T.

If mv_par06 == 2	.And. Max(Val(SEK->EK_MOEDA),1) <> mv_par05
	lRet := .F.
Endif

//Verifica se agregou por Fornecedor
If lAgregSEK .and. !Empty(SEK->EK_FORNEPG)
	If	!(SEK->EK_FORNEPG == mv_par01 .And. SEK->EK_LOJAPG == mv_par02)
		lRet := .F.
	EndIf
Else
	If !(SEK->EK_FORNECE == mv_par01 .And. SEK->EK_LOJA == mv_par02)
		lRet := .F.
	EndIf
EndIf

If SEK->EK_CANCEL 
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³VerBaixas ºAuthor ³Alexandre Silva     º Date ³  13-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifico as baixas que existem no SE5 a partir de um lanca- º±±
±±º          ³mento no SE1.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VerBaixas(cChave)

SE5->(dbSetorder(7))
SE5->(DbSeek((xFilial("SE5")+cChave)))

While cChave = SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) .And. ! SE5->(EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste a data de validacao para a baixa.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If SE5->E5_DATA <= Min(dDataBase,mv_par04)
		cSeq := SE5->E5_SEQ
		nReg := SE5->(Recno())
		Do Case
		Case SE5->E5_TIPODOC $ "JR/MT/IS" .And. SE5->E5_SITUACA != "C" //Juros, Multa
			CalDebSE5()
		Case SE5->E5_TIPODOC $ "VL" .And. Empty(SE5->E5_ORDREC) .And. SE5->E5_SITUACA != "C" .Or.; // Baixa manual
		     cPaisLoc == "CHI" .And. AllTrim(SE5->E5_TIPO)$IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE) .And. SE5->E5_TIPODOC == "VL"
			// Nao faz nada se Houver Estorno da baixa
			SE5->(DbSkip())
			If ! (cChave+cSeq == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) ;
					.And. SE5->E5_TIPODOC = "ES") 
				SE5->(DbGoto(nReg))
				If SE5->E5_TIPO $ MV_CRNEG+","+MVRECANT 
					CalDebSE5()
				Else
					CalCredSE5()
				Endif
			EndIf
			SE5->(DbGoto(nReg))			
		Case SE5->E5_TIPODOC $ "DC/LJ/CP/BA" .And. Empty(SE5->E5_ORDREC).And. SE5->E5_SITUACA != "C"// Desconto
			If !( SE5->E5_MOTBX $ "CMP" .And. !Empty(SE5->E5_DOCUMENT) )
				If SE5->E5_TIPO $ MV_CRNEG+","+MVRECANT 
					CalDebSE5()
				Else
					CalCredSE5()
				Endif
			Endif
		EndCase
	EndIf
	
	SE5->(DbSkip())	
	
EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³CalCredSE5ºAuthor ³Alexandre Silva     º Date ³  06-13-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula (soma ou subtrai) um credito ao arquivo temporario, º±±
±±º          ³ ou atualiza o valor do saldo anterior com um credito.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ lAdd = Indica se e uma operacao de soma ou subtracao       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalCredSE5(lAdd)

iiF(lAdd == Nil ,.T.,lAdd)

If SE5->E5_DATA < MV_PAR03//Calcula o periodo Anterior
	//Atualiza o saldo no Periodo Anterior
	If mv_par06 = 1
		nCredito += SE5->E5_VALOR
	Else
  		nCredito += SE5->E5_VLMOED2 *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06))
	EndIf
Else//Calcula o periodo pedido
	If  mv_par05 == 2 //Mostra so os baixados?
		If mv_par06 = 1
			nCredPeri += SE5->E5_VALOR
		Else
			nCredPeri += Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
		EndIf
	Else
		RecLock("TRB",.T.)
		If mv_par06 = 1
			TRB->CREDITO := SE5->E5_VALOR
		Else
			TRB->CREDITO := Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
		EndIf
		TRB->CREDDEB   := "2"
		TRB->SALDO 		:= nSaldo - TRB->CREDITO
		TRB->NUMERO		:= SE5->E5_NUMERO
		TRB->TIPO		:= SE5->E5_TIPODOC
		TRB->CUOTA		:= SE5->E5_PARCELA
		TRB->PREFIJO	:= SE5->E5_PREFIXO
		TRB->SALTIT    := 0 
		TRB->EMISSAO	:= SE5->E5_DATA
		//Tratamento para correcao monetaria em multi-moedas
		If Val(SE5->E5_MOEDA) <> mv_par06
			TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06)))- TRB->CREDITO
		Endif
		TRB->(MsUnLock())
		nSaldo:= TRB->SALDO
		
		//Atualiza o saldo no Periodo Pedido
		If TRB->CREDITO > 0
			nCredPeri += TRB->CREDITO + TRB->CORRECAO
		EndIf
	EndIf
EndIf	
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³CalDebSE5 ºAuthor ³Alexandre Silva     º Date ³  06-13-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula (soma ou subtrai) um debito  ao arquivo temporario, º±±
±±º          ³ ou atualiza o valor do saldo anterior com um debito .      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ lAdd = Indica se e uma operacao de soma ou subtracao       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalDebSE5(lAdd)

lAdd	:=	IiF(lAdd == Nil,.T.,lAdd)

If SE5->E5_DATA < MV_PAR03//Calcula o periodo Anterior
	If lAdd
		If mv_par06 = 1
			nDebito  += SE5->E5_VALOR
		Else
			nDebito  += Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE1->E1_EMISSAO,nDecs+1),nDecs)
		EndIf
	Else
		If mv_par06 = 1
			nDebito  -= SE5->E5_VALOR
		Else
			nDebito  -= Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE1->E1_EMISSAO,nDecs+1),nDecs)
		EndIf
	EndIf		
Else//Calcula o periodo pedido
	If  mv_par05 == 2 //Mostra so os baixados?
		If SE5->E5_TIPODOC = "DC"
			If mv_par06 = 1
				nCredPeri += SE5->E5_VALOR
			Else
				nCredPeri += Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
			EndIf
		Else
			If mv_par06 = 1
				nDebPeri += SE5->E5_VALOR
			Else
				nDebPeri += Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
			EndIf
		EndIf			
	Else
		RecLock("TRB",.T.)
		If SE5->E5_TIPODOC = "DC"
			If mv_par06 = 1
				TRB->CREDITO	:= SE5->E5_VALOR
			Else
				TRB->CREDITO	:= Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
			EndIf
			TRB->CREDDEB := "2"
			TRB->SALDO     	:= nSaldo - TRB->CREDITO
			//Tratamento para correcao monetaria em multi-moedas
			If Val(SE5->E5_MOEDA) <> mv_par06
				TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06))) - TRB->CREDITO
			Endif
		Else
			TRB->CREDDEB := "1"
			If mv_par06 = 1
				TRB->DEBITO		:= SE5->E5_VALOR
			Else
				TRB->DEBITO  	:= Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par06,SE5->E5_DATA,nDecs+1),nDecs)
			EndIf
			TRB->SALDO     	:= nSaldo + TRB->DEBITO
			//Tratamento para correcao monetaria em multi-moedas
			If Val(SE5->E5_MOEDA) <> mv_par06
				TRB->CORRECAO := (SE5->E5_VLMOED2 *(RecMoeda(Min(dDataBase,mv_par04),SE1->E1_MOEDA)/RecMoeda(Min(dDataBase,mv_par04),mv_par06))) - TRB->DEBITO
			Endif
		EndIf
		TRB->NUMERO		:= SE5->E5_NUMERO
		TRB->TIPO		:= SE5->E5_TIPODOC
		TRB->CUOTA		:= SE5->E5_PARCELA
		TRB->PREFIJO	:= SE5->E5_PREFIXO
		TRB->SALTIT		:= 0 
		TRB->EMISSAO	:= SE5->E5_DATA
		TRB->(MsUnLock())		
		nSaldo			:= TRB->SALDO
	
		//Atualiza o saldo no Periodo Pedido
		If TRB->CREDITO > 0
			nCredPeri += TRB->CREDITO + TRB->CORRECAO
		Else
			nDebPeri  += TRB->DEBITO + TRB->CORRECAO
		EndIf
		
	EndIf
EndIf
	
Return .T.


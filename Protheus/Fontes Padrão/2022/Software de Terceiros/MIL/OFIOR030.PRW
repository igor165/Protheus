#INCLUDE "ofior030.ch"
#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR030 ³ Autor ³ Andr‚                 ³ Data ³ 17/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Emissao da Nota Fiscal de Balcao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ofior030(aAutom)

Local cDesc1	  :=STR0001 //"Impressao da Nota Fiscal"
Local cDesc2 	  :=""
Local cDesc3 	  :=""
Local cAlias	  :="SF2"
Local aRegistros := {}
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Private nLin := 1
Private aPag := 1
Private nIte := 1
Private aReturn := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
/*
[1] Reservado para Formulario
[2] Reservado para nro de Vias
[3] Destinatario
[4] Formato => 1-Comprimido 2-Normal
[5] Midia   => 1-Disco 2-Impressora
[6] Porta ou Arquivo 1-LPT1... 4-COM1...
[7] Expressao do Filtro
[8] Ordem a ser selecionada
[9]..[10]..[n] Campos a Processar (se houver)
*/
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0004 //"Nota Fiscal de Saida"
Private ctamanho:= "P"          // P/M/G
Private cNomProg:= "OFIOR030"
Private cNomeRel:= "NFSAIDA"
Private nLastKey:= 0

if aAutom == Nil
   PERGUNTE("OFR030")
Else
   mv_par01 := aAutom[1] //Nro da Nota
   mv_par02 := aAutom[2] //Serie
Endif

lServer  := .t.
//aImp     := RetImpWin(lServer ) // .T. QUANDO FOR NO SERVER E .F. QDO FOR NO CLIENT -- Retorna o nome das impressoras instaladas
cDrive   := "Epson.drv"
cNomeImp := "LPT2"

cNomeRel:=SetPrint(cAlias,cNomeRel,nil ,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho,nil    ,nil    ,nil    ,cDrive,.T.  ,lServer,cNomeImp)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cAlias)

RptStatus({|lEnd| ImprimeNF(@lEnd,cNomeRel,cAlias)},cTitulo)

Set Filter To

Return


//////////////////////////////////////
Function ImprimeNF(lEnd,wNRel,cAlias)

Local oPr
Local nX
Local aDriver := LeDriver()
Local lVez
Local nValor1
Local i		  := 0

Private cCompac := aDriver[1]
Private cNormal := aDriver[2]

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

DbSelectArea("SM0")
DbGotop()

cNomeEmp := SM0->M0_NOMECOM
cEndeEmp := SM0->M0_ENDCOB
cNomeCid := SM0->M0_CIDCOB
cEstaEmp := SM0->M0_ESTCOB
cCep_Emp := SM0->M0_CEPCOB
cFoneEmp := SM0->M0_TEL
cFax_Emp := SM0->M0_FAX
cCNPJEmp := SM0->M0_CGC
cInscEmp := SM0->M0_INSC

DbSelectArea("SF2")
DbSeek(xFilial("SF2")+mv_par01+mv_par02)

Private aCab := {}

aadd(aCab,SF2->F2_DOC  )                                   //1
aadd(aCab,SF2->F2_SERIE)                                   //2
aadd(aCab,SF2->F2_CLIENTE)                                 //3
aadd(aCab,SF2->F2_LOJA)                                    //4
aadd(aCab,SF2->F2_EMISSAO)                                 //5
aadd(aCab,Transform(SF2->F2_BASEICM,"@E 999,999,999.99")) //6
aadd(aCab,Transform(SF2->F2_VALICM ,"@E 999,999,999.99")) //7
aadd(aCab,Transform(SF2->F2_FRETE  ,"@E 999,999,999.99")) //8
aadd(aCab,Transform(SF2->F2_SEGURO ,"@E 999,999,999.99")) //9
aadd(aCab,SF2->F2_VALBRUT)                                 //10
aadd(aCab,SF2->F2_DESCONT)                                 //11

DbSelectArea("SA3")
FG_VALIDA(Nil,"SA31SF2->F2_VEND1*",Nil)
aadd(aCab,SF2->F2_VEND1+ " - "+SA3->A3_NOME)              //12

DbSelectArea("SM4")
FG_VALIDA(Nil,"SM41SF2->F2_COND*",Nil)
aadd(aCab,SF2->F2_COND+" - "+SM4->M4_DESCR)               //13

DbSelectArea("SA1")
FG_VALIDA(Nil,"SA11SF2->F2_CLIENTE+SF2->F2_LOJA*",Nil)
aadd(aCab,SA1->A1_NOME)                                   //14
aadd(aCab,SA1->A1_END)                                    //15
aadd(aCab,SA1->A1_BAIRRO)                                 //16
aadd(aCab,SA1->A1_CEP)                                    //17
If lA1_IBGE
	FG_Seek("VAM","SA1->A1_IBGE",1,.f.) // CIDADE
	aadd(aCab,VAM->VAM_DESCID)                              //18
	aadd(aCab,SA1->A1_TEL)                                  //19
	aadd(aCab,VAM->VAM_ESTADO)                              //20
Else
	aadd(aCab,SA1->A1_MUN)                                  //18
	aadd(aCab,SA1->A1_TEL)                                  //19
	aadd(aCab,SA1->A1_EST)                                  //20
EndIf
aadd(aCab,SA1->A1_CGC)                                    //21
aadd(aCab,SA1->A1_INSCR)                                  //22

DbSelectArea("SF2")
aadd(aCab,SF2->F2_PLIQUI)                                 //23

DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)

Private aIte := {}
Private aSrv := {}
Private nTotalSrv := 0
Do While !SD2->(EOF())
   fg_valida(Nil,"SB11SD2->D2_COD*",Nil)
   DbSelectArea("SF4")
   DbSeek(xFilial("SF4")+SD2->D2_TES)
   if SF4->F4_ISS == "N"
      aadd(aIte,{SD2->D2_ITEM,SB1->B1_GRUPO+"-"+SB1->B1_CODITE,SB1->B1_DESC,SD2->D2_UM,SD2->D2_QUANT,Transform(SD2->D2_PRCVEN,"@E 999,999,999.99"),Transform(SD2->D2_TOTAL,"@E 999,999,999.99"),Transform(SD2->D2_PICM,"@E 999.99" ),SD2->D2_TES})
      aadd(aSrv,alltrim(SB1->B1_DESC))
   Else
      aadd(aSrv,alltrim(SB1->B1_DESC))
      nTotalSrv := nTotalSrv+SD2->D2_TOTAL
   Endif
   DbSelectArea("SD2")
   DbSkip()
Enddo

// Impressao da Nota Fiscal

//@ 001,001 PSAY &cCompac + " "

FS_CABEC()

nLin++

@ nLin, 020 pSay STR0005 //"Descontos........................  R$ "
@ nLin, 067 pSay aCab[11]

nLin := 35 

lVez := .f.

nCol := 1
For i:=1 to Len(aSrv)
    nCol := nCol + Len(aSrv[i])+2
    if nCol >= 50
       nCol := 1
       nLin++
    Endif   
    @ nLin, nCol pSay aSrv[i]+if(i=Len(aSrv),"",", ")
    if nLin =36
       if !lVez
          @ nLin, 120 pSay Transform(nTotalSrv,"@E 999,999,999.99")
          lVez := .t.
       Endif   
    Endif   
Next
if !lVez
   @ nLin, 100 pSay Transform(nTotalSrv,"@E 999,999,999.99")
   lVez := .t.
Endif   

nLin := 42 
@ nLin, 000 pSay &cNormal+aCab[6]
@ nLin, 020 pSay aCab[7]
//(aCab[10]-aCab[11])
@ nLin, 070 pSay Transform((aCab[10]-aCab[11]),"@E 999,999,999.99")
nLin+=2
@ nLin, 069 pSay Transform((aCab[10]-aCab[11]),"@E 999,999,999.99")
nLin+=4
@ nLin, 001 pSay &cCompac+" "
@ nLin, 060 pSay "2"
nLin+=4
@ nLin, 047 pSay STR0008
@ nLin, 060 pSay aCab[23]
nLin+=2
@ nLin, 002 pSay STR0006 //"Vendedor:"
@ nLin, 025 pSay aCab[12]
nLin++
@ nLin, 002 pSay STR0007 //"Cond. Pagamento:"
@ nLin, 025 pSay aCab[13]

Set Printer to
Set Device  to Screen

Return


///////////////////
Function FS_CABEC()

   @ nLin, 000 pSay &cNormal+" "
   @ nLin, 050 pSay "X"
   @ nLin, 062 pSay aCab[1]  +" / "+ StrZero(aPag,2)+&cCompac
   
   nLin+=2

   @ nLin, 002 pSay cEndeEmp
   @ nLin, 035 pSay cNomeCid
   @ nLin, 055 pSay cEstaEmp

   nLin++

   @ nLin, 002 pSay cFoneEmp
   @ nLin, 035 pSay cFax_Emp
   @ nLin, 055 pSay cCep_Emp
   @ nLin, 090 pSay cCNPJEmp

   nLin+=2

   @ nLin, 002 pSay STR0009
   @ nLin, 038 pSay "512"
   @ nLin, 090 pSay cInscEmp

   nLin+=3

   @ nLin, 002 pSay &cNormal+" "+aCab[14]
   @ nLin, 065 pSay aCab[21]
   @ nLin, 070 pSay aCab[5]

   nLin+=2

   @ nLin, 002 pSay aCab[15]
   @ nLin, 062 pSay aCab[16]
   @ nLin, 070 pSay aCab[17]
 
   nLin+=2

   @ nLin, 002 pSay aCab[18]
   @ nLin, 034 pSay aCab[19]
   @ nLin, 048 pSay aCab[20]
   @ nLin, 065 pSay aCab[22]+&cCompac

   nLin+=6

   FS_DETALHE()

Return


/////////////////////
Function FS_DETALHE()
Local i := 0

   For i:=nIte to Len(aIte)
       @ nLin, 001 pSay aIte[i,2]
       @ nLin, 025 pSay aIte[i,3]
       @ nLin, 075 pSay aIte[i,9]
       @ nLin, 080 pSay aIte[i,4]
       @ nLin, 088 pSay aIte[i,5]
       @ nLin, 098 pSay aIte[i,6]
       @ nLin, 120 pSay aIte[i,7]
       @ nLin, 135 pSay aIte[i,8]
       nLin++
       if nLin > 40
          nIte := i
          nLin := 3
          aPag++
          FS_CABEC()
       Endif
   Next

Return


/////////////////////////////
Function FS_VALNF1()

DbSelectArea("SF2")
DbSetOrder(1)
if !FG_VALIDA(Nil,"SF2T1mv_par01*",Nil)
   Return .f.
Endif

Return .t.


/////////////////////////////
Function FS_VALNF2()

DbSelectArea("SF2")
DbSetOrder(1)
if !FG_VALIDA(Nil,"SF2T1mv_par01+mv_par02*",Nil)
   Return .t.
Else
   FG_VALIDA(Nil,"SA1T1SF2->F2_CLIENTE+SF2->F2_LOJA*","mv_par03 := sa1->a1_nome")
   mv_par04 := sf2->f2_emissao
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LeDriver ³ Autor ³ Tecnologia            ³ Data ³ 17/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Emissao da Nota Fiscal de Balcao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LEDriver()
Local aSettings := {}
Local cStr, cLine, i

if !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
Endif
Return aSettings

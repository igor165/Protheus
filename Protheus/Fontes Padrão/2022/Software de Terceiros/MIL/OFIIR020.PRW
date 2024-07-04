#INCLUDE "ofiir020.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIIR020 บ Autor ณ Rogerio Vaz Melonioบ Data ณ  15/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao de Relatorio EDI - Valores em aberto               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo de Oficina                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function OFIIR020()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cInd
Local cDesc1       := STR0001		//Este programa tem como objetivo imprimir relatorio 
Local cDesc2       := STR0002		//de acordo com os parametros informados pelo usuario.
Local cDesc3       := STR0003		//Veiculos a Pagar (unidades em aberto)
Local cPict        := ""
Local titulo       := STR0004		//Veiculos a Pagar (unidades em aberto)
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "OFIIR020" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { STR0012, 1, STR0013, 1, 2, 1, "", 1}  //Zebrado #"Administracao"
Private nLastKey     := 0
Private cPerg       := "OFI020"
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "OFIIR020" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "VH6"

MsgRun(STR0005,STR0006,{||OFIIR0202()})     //Aguarde... Ordenando registros lidos # Organizando registros

//ValidPerg()

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| OFIIR0201(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0201บ Autor ณ AP6 IDE            บ Data ณ  15/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de impressao do Relatorio de EDI.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0201(Cabec1,Cabec2,Titulo,nLin)
SetRegua(Len(aConteudo))
_nSubQC  := 0					// SubTotal Saldo em QC's
_nSubQCD := 0					// SubTotal Saldo QC's c/desconto
_nTotQC  := 0					// Total Saldo em QC's
_nTotQCD := 0					// Total Saldo QC's c/desconto
_nSubR   := 0					// SubTotal Saldo em R$
_nSubRD  := 0					// SubTotal Saldo em R$ c/desconto
_nTotR   := 0					// Total Saldo em R$
_nTotRD  := 0					// Total Saldo em R$ c/desconto

_nSubQC  := 0
_nSubQCD := 0
_nSubR   := 0
_nSubRD  := 0

Cabec1 := STR0007   //"Lancto. Data     NF/Serie   Dt. Vcto       Saldo em QC's    Sld. QCS c/desc.          Saldo em R$   Sld. em R$ c/desc.    Chassi Marca         Modelo               Md/Fb"
/*/
Lancto. Data     NF/Serie   Dt. Vcto       Saldo em QC's    Sld. QCS c/desc.          Saldo em R$   Sld. em R$ c/desc.    Chassi Marca         Modelo               Md/Fb
        99/99/99 999999/999 99/99/99   999.999.999,99999   999.999.999,99999   999,999,999,999.99   999,999,999,999.99   XXXXXXX XXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XX/XX
0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
/*/

SetRegua(Len(aConteudo))
_nLinha := 1
_cQuebra := Substr(aConteudo[_nLinha,2],4,4)
While _nLinha <= Len(aConteudo)

   If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
      @ nLin,000 PSAY STR0008+_cQuebra //"Tipo de Lancamento "
      nLin++
   Endif

   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   While Substr(aConteudo[_nLinha,2],4,4) == _cQuebra
      _cTipoLcto := Substr(aConteudo[_nLinha,2],4,4)
      If Substr(aConteudo[_nLinha,2],018,006) == "000000"
         _dDataLcto := Ctod("")
      Else   
         _dDataLcto := Ctod(Transform(Substr(aConteudo[_nLinha,2],018,006),"@R 99/99/99"))
      Endif   
      If Substr(aConteudo[_nLinha,2],024,006) == "000000"
         _dDataVcto := Ctod("")
      Else   
         _dDataVcto := Ctod(Transform(Substr(aConteudo[_nLinha,2],024,006),"@R 99/99/99"))
      Endif   
      
      If (!Empty(_dDataLcto) .And. (_dDataLcto < mv_par01 .Or. _dDataLcto > mv_par02)) ;
         .Or. (!Empty(_dDataVcto) .And. (_dDataVcto < mv_par03 .Or. _dDataVcto > mv_par04)) ;
         .Or. _cTipoLcto < mv_par05 .Or. _cTipoLcto > mv_par06
         IncRegua()
         _nLinha++
         If _nLinha > Len(aConteudo)
            Exit
         Endif   
         Loop
      Endif

      _cNota     := Transform(Substr(aConteudo[_nLinha,2],008,009),"@R 999.999/999")
      _nSldQc    := Val(Substr(aConteudo[_nLinha,2],045,015))/100000
      _nSldQcD   := Val(Substr(aConteudo[_nLinha,2],150,015))/100000
      _nSldR     := Val(Substr(aConteudo[_nLinha,2],030,015))/100
      _nSldRD    := Val(Substr(aConteudo[_nLinha,2],135,015))/100

      _nSubQC  += _nSldQc
      _nSubQCD += _nSldQcD
      _nTotQC  += _nSldQc
      _nTotQCD += _nSldQcD
      _nSubR   += _nSldR
      _nSubRD  += _nSldRD
      _nTotR   += _nSldR
      _nTotRD  += _nSldRD

      _cChassi   := Substr(aConteudo[_nLinha,2],085,007)
      _cMarca    := Substr(aConteudo[_nLinha,2],092,013)
      _cModelo   := Substr(aConteudo[_nLinha,2],105,020)
      _cAno      := Transform(Substr(aConteudo[_nLinha,2],125,4),"@R 99/99")

      If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
         Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin := 9
         @ nLin,000 PSAY STR0008+_cQuebra      //"Tipo de Lancamento "
         nLin++;nLin++
      Endif

      @ nLin,008 PSAY _dDataLcto
      @ nLin,017 PSAY _cNota    
      @ nLin,028 PSAY _dDataVcto
      @ nLin,039 PSAY _nSldQc     Picture "@E 999,999,999.99999"
      @ nLin,059 PSAY _nSldQcD    Picture "@E 999,999,999.99999"
      @ nLin,079 PSAY _nSldR      Picture "@E 999,999,999,999.99"
      @ nLin,100 PSAY _nSldRD     Picture "@E 999,999,999,999.99"
      @ nLin,121 PSAY _cChassi
      @ nLin,129 PSAY _cMarca
      @ nLin,143 PSAY _cModelo
      @ nLin,164 PSAY _cAno

      IncRegua()
      _nLinha++
      nLin++

      If _nLinha > Len(aConteudo)
         Exit
      Endif   
   Enddo

   @ nLin,039 PSAY "-----------------"
   @ nLin,059 PSAY "-----------------"
   @ nLin,079 PSAY "------------------"
   @ nLin,100 PSAY "------------------"
   nLin++
   @ nLin,000 PSAY STR0010+_cQuebra   //Sub Total tipo de Lancamento 
   @ nLin,039 PSAY Transform(_nSubQC ,"@E 999,999,999.99999")
   @ nLin,059 PSAY Transform(_nSubQCD,"@E 999,999,999.99999")
   @ nLin,079 PSAY Transform(_nSubR  ,"@E 999,999,999,999.99")
   @ nLin,100 PSAY Transform(_nSubRD ,"@E 999,999,999,999.99")
   _nSubQC  := 0
   _nSubQCD := 0
   _nSubR   := 0
   _nSubRD  := 0

   nLin++
   @ nLin,000 PSAY Repl("-",limite)
   nLin++;nLin++

   If _nLinha > Len(aConteudo)
      Exit
   Endif   
   _cQuebra := Substr(aConteudo[_nLinha,2],4,4)

   If nLin <= 54
      @ nLin,000 PSAY STR0008+_cQuebra   //Tipo de Lancamento 
      nLin++
   Endif   
   
Enddo

// Imprime o total Geral
nLin++
@ nLin,000 PSAY Repl("-",limite)
nLin++
@ nLin,000 PSAY STR0011+" "       //Total Geral: 

@ nLin,039 PSAY Transform(_nTotQC ,"@E 999,999,999.99999")
@ nLin,059 PSAY Transform(_nTotQCD,"@E 999,999,999.99999")
@ nLin,079 PSAY Transform(_nTotR  ,"@E 999,999,999,999.99")
@ nLin,100 PSAY Transform(_nTotRD ,"@E 999,999,999,999.99")

nLin++
@ nLin,000 PSAY Repl("-",limite)

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0202บ Autor ณ AP6 IDE            บ Data ณ  12/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina para ordenar registros lidos  do arquivo de EDI.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0202()
Asort(aConteudo,,,{|x,y| Substr(x[2],4,4)+Substr(x[2],14,3)+Substr(x[2],8,6)<Substr(y[2],4,4)+Substr(y[2],14,3)+Substr(y[2],8,6)})
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPergบ Autor ณ Rogerio Vaz Melonioบ Data ณ  15/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescricao ณ Relatorio de veiculos a pagar (unidades em aberto)         ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

/*
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j       
cPerg := PADR(cPerg,10)
dbSelectArea("SX1")
dbSetOrder(1)
// Grupo/Ordem/Pergunta/Pergunta Espanhol/Pergunta Ingles/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSpa1/DefEng1/Cnt01/Var02/Def02/DefSpa2/DefEng2/Cnt02/Var03/Def03/DefSpa3/DefEng3/Cnt03/Var04/Def04/DefSpa4/DefEng4/Cnt04/Var05/Def05/DefSpa5/DefEng5/Cnt05/F3/GRPSX6
aAdd(aRegs,{cPerg,"01","Da Emissao         ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Emissao        ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"03","Do Vencimento      ?","","","mv_ch3","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Vencimento     ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Do Tipo Lancamento ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Ate Tipo Lancamento?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

*/

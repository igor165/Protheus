#INCLUDE "ofiir050.ch"                    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIIR050 บ Autor ณ Rogerio Vaz Melonioบ Data ณ  24/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao de Relatorio EDI - Situacao de credito             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo de Oficina                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function OFIIR050()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cInd
Local cDesc1       := STR0001 //Este programa tem como objetivo imprimir relatorio
Local cDesc2       := STR0002 //de acordo com os parametros informados pelo usuario.
Local cDesc3       := STR0003 //Situacao de Credito
Local cPict        := ""
Local titulo       := STR0004 //Situacao de Credito
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "OFIIR050" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { STR0005, 1, STR0006, 1, 2, 1, "", 1}   //Zebrado # Administracao
Private nLastKey     := 0
Private cPerg       := nil
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "OFIIR050" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "VH6"
Private _cData

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| OFIIR0501(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0501บ Autor ณ AP6 IDE            บ Data ณ  24/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao EDI Situacao de Crerdito                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0501(Cabec1,Cabec2,Titulo,nLin)
// titulo += COLOCAR AQUI O CAMPO COM O NOME DA MONTADORA

/*/
0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Procedencia do Veiculo:  X - NACIONAL
FLOOR PLAN                                PLANO DE CAPITALIZACAO                     PLANO IPI
-------------------------------------     --------------------------------------     -----------------------------------------------
Status Revenda : 0 - Nao Participante     Status Revenda : 0 - Nao Participante      Status Revenda : 0 - Nao Participante
                 1 - Ativo                1 - Ativo                                  1 - Ativo
                 2 - Suspenso             2 - Suspenso                               2 - Suspenso
                 3 - Excluido             3 - Excluido                               3 - Excluido
Data Suspensao : 99/99/99                 Data Suspensao : 99/99/99                  Data           : 99/99/99
Limite Aprov.  : 999,999,999,999.99       Limite Dispon. : 999,999,999,999.99        Limite Dispon. : 999,999,999,999.99
Limite Utiliz. : 999,999,999,999.99
Limite Dispon. : 999,999,999,999.99      
------------------------------------------------------------------------------------------------------------------------------------
0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
/*/

SetRegua(Len(aconteudo))
_nLinha := 1
While _nLinha <= Len(aConteudo)

   If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
  
   If lAbortPrint
      @nLin,00 PSAY STR0007 //*** CANCELADO PELO OPERADOR ***
      Exit
   Endif
   
   _cProced   := Substr(aConteudo[_nLinha,2],078,001)
   _cStatFlo  := Substr(aConteudo[_nLinha,2],004,001)
   _cStatCap  := Substr(aConteudo[_nLinha,2],005,001)
   _cStatIpi  := Substr(aConteudo[_nLinha,2],079,001)
   _cDataFlo  := Transform(Substr(aConteudo[_nLinha,2],006,006),"@R 99/99/99")
   _cDataCap  := Transform(Substr(aConteudo[_nLinha,2],012,006),"@R 99/99/99")
   _cDataIpi  := Transform(Substr(aConteudo[_nLinha,2],080,006),"@R 99/99/99")
   _nLimApro  := Val(Substr(aConteudo[_nLinha,2],018,015))/100
   _nLimUti   := Val(Substr(aConteudo[_nLinha,2],033,015))/100
   _nLimDFlo  := Val(Substr(aConteudo[_nLinha,2],048,015))/100
   _nLimDCap  := Val(Substr(aConteudo[_nLinha,2],063,015))/100
   _nLimDIpi  := Val(Substr(aConteudo[_nLinha,2],086,015))/100

   If _cProced == "N"
      _cProced += STR0008 // - NACIONAL
   ElseIf _cProced == "I"
      _cProced += STR0009 // - IMPORTADO
   Else
      _cProced += STR0010 // - OUTROS
   Endif

   If _cStatFlo == "0"
      _cStatFlo += STR0011 // - Nao Participante
   ElseIf _cStatFlo == "1"
      _cStatFlo += STR0012 // - Ativo
   ElseIf _cStatFlo == "2"
      _cStatFlo += STR0013// - Suspenso
   ElseIf _cStatFlo == "3"
      _cStatFlo += STR0014 // - Excluido
   Else
      _cStatFlo += STR0010 // - Outros
   Endif                        

   If _cStatCap == "0"
      _cStatCap += STR0011 // - Nao Participante
         ElseIf _cStatCap == "1"
      _cStatCap += STR0012 // - Ativo
   ElseIf _cStatCap == "2"
      _cStatCap += STR0013 // - Suspenso
   ElseIf _cStatCap == "3"
      _cStatCap += STR0014 // - Excluido
   Endif

   If _cStatIpi == "0"
      _cStatIpi += STR0011		 // - Nao Participante
   ElseIf _cStatIpi == "1"
      _cStatIpi += STR0012		// - Ativo
   ElseIf _cStatIpi == "2"
      _cStatIpi += STR0013		// - Suspenso
   ElseIf _cStatIpi == "3"
      _cStatIpi += STR0014 // - Excluido
   Endif

   @ nLin,000 PSAY STR0015 +" "+  _cProced    //Procedencia do Veiculo: 
   nLin++
   @ nLin,000 PSAY STR0016 //"FLOOR PLAN                                PLANO DE CAPITALIZACAO                     PLANO IPI"
   nLin++
   @ nLin,000 PSAY "-------------------------------------     --------------------------------------     -----------------------------------------------"

   nLin++
   @ nLin,000 PSAY STR0017 +" "+ _cStatFlo 		//Status Revenda 
   @ nLin,042 PSAY STR0017 +" "+ _cStatCap		//Status Revenda 
   @ nLin,085 PSAY STR0017 +" "+ _cStatIpi		//Status Revenda 

   nLin++
   @ nLin,000 PSAY STR0018 +" "+ _cDataFlo   //Data Suspensao  
   @ nLin,042 PSAY STR0018 +" "+ _cDataCap   //Data Suspensao 
   @ nLin,085 PSAY STR0019 +" "+ _cDataIpi   //Data 

   nLin++
   @ nLin,000 PSAY STR0020 +" "+ Transform(_nLimApro,"@E 999,999,999,999.99")   //Limite Aprov.
   @ nLin,042 PSAY STR0021 +" "+ Transform(_nLimDCap,"@E 999,999,999,999.99")   //Limite Dispon
   @ nLin,085 PSAY STR0021 +" "+ Transform(_nLimDIpi,"@E 999,999,999,999.99")   //Limite Dispon.

   nLin++
   @ nLin,000 PSAY STR0022 +" "+ Transform(_nLimUti ,"@E 999,999,999,999.99")    //Limite Utiliz.

   nLin++
   @ nLin,000 PSAY STR0021 +" "+ Transform(_nLimDFlo,"@E 999,999,999,999.99")   //Limite Dispon.

   nLin++
   @ nLin,000 PSAY Repl("-",limite)
   
   IncRegua()
   _nLinha++
   If _nLinha > Len(aConteudo)
      Exit
   Endif   
   
Enddo

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
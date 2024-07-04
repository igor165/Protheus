// ษออออออออหออออออออป
// บ Versao บ 03     บ
// ศออออออออสออออออออผ
#INCLUDE "OFIGR060.ch"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIGR060  บ Autor ณ Ricardo Farinelli  บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Debito e Credito de Garantia                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function OFIGR060()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aOrd           := {}
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir os debitos e"
Local cDesc2         := STR0002 //"creditos de garantia solicitadas a Montadora              "
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local cString        := "VGA"
Local cIndice        := ""
Local cChave         := ""
Local cCondicao      := ""
Local nIndice 		   := 0
Local cMontadora     := ""

Private cTitulo      := STR0003 //"Debitos/Creditos Garantia             "
Private wnrel        := "OFIGR060"
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private Cabec1       := STR0004 //" [Nro.OS] [Dt.Abe] [Ch.I] [Chassi do Veiculo------] [CR] [GR] [Dt.Ret] [Situacao--------------------------------------------------]"
Private Cabec2       := STR0005 //"         [Dt.Tra] [Total Pcs--] [Total Srvs] [Dt.Cre] [Valor Cred] [Lcto] [Dt.Deb] [Valor Cred] [Lcto] [Est]"
Private nTipo        := 18
Private aReturn      := {STR0006, 1,STR0007, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "OGR060"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01

ValidPerg()

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

cMontadora := MV_PAR07 // Traz o codigo de montadora padrao
cIndice    := CriaTrab(nil,.F.)

cCondicao += "VGA_CODMAR=='"+cMontadora+"'"

If !Empty(MV_PAR01)
  cCondicao += ".and. DTOS(VGA_DATTRA)>='"+DTOS(MV_PAR01-365)+"'"
Endif
  
If !Empty(MV_PAR02)
  cCondicao += ".and. Str(Year(VGA_DATTRA),4)+Str(Month(VGA_DATTRA),2) <= '"+Str(Year(MV_PAR02),4)+Str(Month(MV_PAR02),2)+"'"
Endif

If MV_PAR03==1
  cCondicao += ".and. VGA_ESPGAR=='S'"
Elseif MV_PAR03==2
  cCondicao +=".and. VGA_ESPGAR=='R'"
Endif  

If MV_PAR04==1
  cCondicao += ".and. VGA_TRANSM=='S'"
Elseif MV_PAR04 == 2
  cCondicao += ".and. VGA_TRANSM=='N'"
Endif  

If !Empty(MV_PAR05)
  cCondicao += ".and. VGA_NUMOSV>=MV_PAR05"
Endif  
  
If !Empty(MV_PAR06)
  cCondicao += ".and. VGA_NUMOSV<=MV_PAR06"
Endif  

//cChave := "VGA_FILIAL+DTOS(VGA_DATTRA)+VGA_NUMOSV"
cChave := "VGA_FILIAL+VGA_NUMOSV+DTOS(VGA_DATTRA)"

IndRegua("VGA",cIndice,cChave,,cCondicao,STR0008) //"Aguarde Selecionando Registro para Impressao"

DbSelectArea("VGA")
nIndice := RetIndex("VGA")
#IFNDEF TOP
   dbSetIndex(cIndice+ordBagExt())
#ENDIF
dbSetOrder(nIndice+1)

RptStatus({|lEnd| OFIG060IMP(@lEnd,wnrel,cString)},cTitulo)

DbSelectArea("VGA")
RetIndex()

#IFNDEF TOP
   If File(cIndice+OrdBagExt())
      fErase(cIndice+OrdBagExt())
   Endif
#ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณOFIG060IMPบ Autor ณ Ricardo Farinelli  บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para a impressao do relatorio              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function OFIG060IMP(lEnd,wnrel,cString)

Local nTotSrv := 0
Local nTotPec := 0
Local nTotDeb := 0
Local nTotCre := 0
Local aResumo := {}

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMV_PAR01 = Data Inicial - Data de inicio ou branco para desde o comeco                                ณ
//ณMV_PAR02 = Data Final - Data final para o escopo do relatorio                                         ณ
//ณMV_PAR03 = 1 - Garantias Solicitadas, 2 - Cupons de Revisao ou 3 - Ambos                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

DbselectArea("VGA")

SetRegua(RecCount())

cTitulo +=STR0009+dToc(MV_PAR01) //" de "
cTitulo +=STR0010+dToc(MV_PAR02) //" a "
cTitulo +=STR0011+Iif(MV_PAR03==1,STR0012,Iif(MV_PAR03==2,STR0013,STR0014)) //" Tipo: "###"Solicitadas "###"Cupons Rev. "###"Ambas "
cTitulo +=STR0015+Iif(MV_PAR03==1,"S",Iif(MV_PAR03==2,"N",STR0016)) //"Tr: "###"Todas"

DbSeek(xFilial("VGA"))
Do While VGA->VGA_FILIAL == xFilial("VGA") .and. !VGA->(Eof())

  If ( ( Empty(MV_PAR01) .Or. DTOS(VGA_DATTRA) >= DTOS(MV_PAR01) ) .And. ( Empty(MV_PAR02) .Or. DTOS(VGA_DATTRA) <= DTOS(MV_PAR02) ) )

	  If lAbortPrint .or. lEnd
	    @nLin,00 PSAY STR0017 //"*** CANCELADO PELO OPERADOR ***"
	    Exit
	  Endif
	
	  If nLin > 58
	    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	    nLin := 9
	  Endif
	
	  VV1->(DbSetOrder(1))
	  VV1->(Dbseek(xFilial("VV1")+VGA->VGA_CHAINT))
	  VO5->(DbSetOrder(1))
	  VO5->(Dbseek(xFilial("VO5")+VGA->VGA_CHAINT))
	  VO1->(DbSetOrder(1))
	  VO1->(Dbseek(xFilial("VO1")+VGA->VGA_NUMOSV))
	  
	  @ nLin,001 PSAY VGA->VGA_NUMOSV
	  @ nLin,010 PSAY VGA->VGA_ABEGAR
	  @ nLin,019 PSAY VGA->VGA_CHAINT
	  @ nLin,026 PSAY VV1->VV1_CHASSI
	  @ nLin,053 PSAY VGA->VGA_CODREV
	  @ nLin,058 PSAY VGA->VGA_GRUREV
	  @ nLin,062 PSAY VGA->VGA_DATRET
	  @ nLin,071 PSAY VGA->VGA_SITUAC+" "+VGA->VGA_DESSIT
	  nLin++
	  If nLin > 58
	    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	    nLin := 9
	  Endif
	  @ nLin,010 PSAY VGA->VGA_DATTRA
	  @ nLin,019 PSAY Transform(VGA->VGA_VALPEC,"@E 9,999,999.99")
	  @ nLin,032 PSAY Transform(VGA->VGA_VALTPO,"@E 9,999,999.99")
	  @ nLin,045 PSAY VGA->VGA_DATCRE
	  @ nlin,054 PSAY Transform(VGA->VGA_VALCRE,"@E 9,999,999.99")
	  @ nLin,067 PSAY VGA->VGA_LANCRE                 
	  @ nLin,074 PSAY VGA->VGA_DATDEB
	  @ nLin,083 PSAY Transform(VGA->VGA_VALDEB,"@E 9,999,999.99")
	  @ nLin,096 PSAY VGA->VGA_LANDEB
	  @ nLin,104 PSAY VGA->VGA_CODEST
	  @ nLin,110 PSAY VGA->VGA_DNRESP
	  @ nLin,118 PSAY VGA->VGA_DNEXEC
	  nLin+=2  
	  If nLin > 58
	    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	    nLin := 9
	  Endif
	  nTotPec += VGA->VGA_VALPEC
	  nTotSrv += VGA->VGA_VALTPO
	  nTotDeb += VGA->VGA_VALDEB
	  nTotCre += VGA->VGA_VALCRE
  
  EndIf  
  
  && Totaliza resumido
  FS_LEVRES(@aResumo,MV_PAR01)
  		
  IncRegua()
  VGA->(Dbskip())
  
Enddo
@ nLin,001 PSAY PADC(STR0018+Transform(nTotPec,"@E 9999,999.99")+STR0019+Transform(nTotSrv,"@E 9999,999.99")+STR0020+Transform(nTotCre,"@E 9999,999.99")+STR0021+Transform(nTotDeb,"@E 9999,999.99"),132) //"Valor Pecas.: "###" Valor Servicos.: "###" Valor Creditado: "###" Total Debitado: "

&& Imprime revisoes realizadas em outra concessionaria
/*
If MV_PAR03==2 .Or. MV_PAR03==3

	nTotDeb := 0
	nTotCre := 0

	nLin := 80
	DbSelectArea("VI1")
	DbSetOrder(1)
	DbSeek( xFilial("VI1") + cMontadora + "FGD" )
	Do While !VI1->(Eof()) .And. VI1->VI1_FILIAL + VI1->VI1_CODMAR + VI1->VI1_TIPREG == xFilial("VI1") + cMontadora + "FGD"
	
	  If ( ( Empty(MV_PAR01) .Or. DTOS(VI1_DATREV) >= DTOS(MV_PAR01) ) .And. ( Empty(MV_PAR02) .Or. DTOS(VI1_DATREV) <= DTOS(MV_PAR02) ) )
	
		  If lAbortPrint .or. lEnd
		    @nLin,00 PSAY STR0017 //"*** CANCELADO PELO OPERADOR ***"
		    Exit
		  Endif
		
		  If nLin > 58
		    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		    nLin := 9                                       
  		    @nLin++,00 PSAY "Revisoes executadas em outras concessinarias."
		  Endif
		
		  VV1->(DbSetOrder(2))
		  VV1->(Dbseek(xFilial("VV1")+VI1->VI1_CHASSI))
		  VO5->(DbSetOrder(1))
		  VO5->(Dbseek(xFilial("VO5")+VV1->VV1_CHAINT))
		  
		  @ nLin,001 PSAY VI1->VI1_NUMOSV
		  @ nLin,010 PSAY VI1->VI1_DATREV
		  @ nLin,019 PSAY VV1->VV1_CHAINT
		  @ nLin,026 PSAY VI1->VI1_CHASSI
		  @ nLin,053 PSAY VI1->VI1_CODREV
//		  @ nLin,058 PSAY VI1->VI1_GRUREV
		  @ nLin,062 PSAY VI1->VI1_DATRET
		  @ nLin,071 PSAY VI1->VI1_CODREG+" "+VI1->VI1_MENSAG
		  nLin++
		  If nLin > 58
		    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		    nLin := 9
		  Endif
		  @ nLin,010 PSAY VI1->VI1_DATREV
//		  @ nLin,019 PSAY Transform(VI1->VI1_VALPEC,"@E 9,999,999.99")
//		  @ nLin,032 PSAY Transform(VI1->VI1_VALTPO,"@E 9,999,999.99")
		  If StrZero(Val(VI1->VI1_CODREG),2) # "06"        //CREDITO
			  @ nLin,045 PSAY VI1->VI1_DATREV
			  @ nlin,054 PSAY Transform(VI1->VI1_VALPGT,"@E 9,999,999.99")
			  @ nLin,067 PSAY VI1->VI1_LANCTO                 
			  nTotCre += VI1->VI1_VALPGT
		  Else                                             //DEBITO
			  @ nLin,074 PSAY VI1->VI1_DATREV
			  @ nLin,083 PSAY Transform(VI1->VI1_VALPGT,"@E 9,999,999.99")
			  @ nLin,096 PSAY VI1->VI1_LANCTO
			  nTotDeb += VI1->VI1_VALPGT
		  EndIf

		  @ nLin,104 PSAY VI1->VI1_CODEST
		  @ nLin,110 PSAY VI1->VI1_DNRESP
		  @ nLin,118 PSAY VI1->VI1_DNEXEC
		  nLin+=2  
		  If nLin > 58
		    Cabec(cTitulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		    nLin := 9
		  Endif
	  
	  EndIf  
	  
	  IncRegua()
	  VI1->(Dbskip())
	  
	Enddo

	@ nLin,001 PSAY PADC(STR0020+Transform(nTotCre,"@E 9999,999.99")+STR0021+Transform(nTotDeb,"@E 9999,999.99"),132) //""###" Valor Creditado: "###" Total Debitado: "

EndIf
*/

&& Imprime resumido                           
FS_IMPRES(aResumo,MV_PAR01)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

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
ฑฑบFuno    ณVALIDPERG บ Autor ณ Ricardo Farinelli  บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

Aadd(aRegs,{cPerg,"07",STR0022,"","","mv_ch7","C",TamSX3("VE1_CODMAR")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""})

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

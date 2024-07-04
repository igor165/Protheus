#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVR002()
Folha de Vistoria de Motoristas
Adaptação da função TDCVR001
@author Andre Melo
@since 01/04/2003
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVR002()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

SetPrvt("_CAREA,_NREC,_CIND,TITULO,CABEC1,CABEC2")
SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,WNREL")
SetPrvt("CPERG,NOMEPROG,NLASTKEY,CSTRING,ARETURN,LI")
SetPrvt("LCONTINUA,M_PAG,CARACTER,NLIN,DESCR,_TABELA")
SetPrvt("AVETMAT,_CONT,_TOT,CONTROL,I,_SALIAS")
SetPrvt("AREGS,J,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis Parametros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Tamanho   := "M"
Limite    := 220
cDesc1    := PadC("Este programa tem como objetivo imprimir a folha com as   ",74)
cDesc2    := PadC("informacoes dos itens vistoriados do motorista...         ",74)
cDesc3    := PadC("Template DCL - Veiculos                                   ",74)
wnrel     := "CVR002"
cPerg     := "CVR002"
nomeprog  := "DCLVR002"
nLastkey  :=  0
cString   := "DHB"
aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
li        :=  66
lContinua := .T.
m_pag     := 1
Caracter  := 18
Titulo    := PadC("INSPECAO DE MOTORISTA",74)
Cabec1    := ""
Cabec2    := ""

_cPerg:="CVR002"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(_cPerg,.F.)
wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho)
//                                                                  8   9  10  11    12
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ ImpressÆo do dados.              ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()},Titulo)// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	RptStatus({|| Execute(RptDetail)},Titulo)
Return

Static Function RptDetail()
Local I:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DOS DADOS             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("DHB")
DBSETORDER(1)
IF DBSEEK(XFILIAL("DHB")+MV_PAR01)
	nlin:=Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,Limite)
	nlin:=nLin+1
	@nlin,00 PSAY "DATA EMISSAO..:"+DTOC(DATE())
	@nlin,90 PSAY "EMITENTE......:"+SUBSTR(CUSUARIO,7,15)
	nlin:= nlin+2
	@nlin,00 PSAY "NOME:"+DHB->DHB_NOMMOT
	@nlin,46 PSAY "CPF...........:"+DHB->DHB_CPFMOT
	@nlin,90 PSAY "DATA DE NASC..:"+DTOC(DHB->DHB_DTNASC)
	nlin:= nlin+2
	@nlin,00 PSAY "CATEGORIA CNH.:"+DHB->DHB_CATEGO
	@nlin,46 PSAY "NUMERO CNH....:"+DHB->DHB_NUMCNH
	nlin:= nlin+1
	@nlin,00 PSAY "VALIDADE EXAME:"+DTOC(DHB->DHB_DTVALE)
	@nlin,46 PSAY "VALIDADE MOPE.:"+DTOC(DHB->DHB_VENCTO)
	nlin:= nlin+1
	@nlin,00 PSAY "ULTIMA REVISAO:"+DTOC(DHB->DHB_DTREV)
	@nlin,46 PSAY "PROX. VISTORIA:"+DTOC(DHB->DHB_DTVIST)
	nlin:= nlin+2
	@nlin,0 PSAY REPLIC("-",216)
	nlin:=nlin+1
	@nlin,0 PSAY "ITENS EM DESACORDO "
	nlin:=nlin+1
	@nlin,0 PSAY "IT.   DESCRICAO                             |   IT.  DESCRICAO                           |   IT.  DESCRICAO                           "
	nlin:=nlin+1
	@nlin,00 PSAY REPLIC("-",216)
	nlin:=nlin+1
	
	// Armazena Itens em Desacordo Marcados
	Descr := alltrim(DHB->DHB_ITEMDE)
	
	// IMPRESSAO DOS ITENS DA TABELA
	aVetmat:={}
	
	_TABELA:="IE"
	DBSELECTAREA("SX5")
	DBSETORDER(1)
	IF 	SX5->(DBSEEK(XFILIAL("SX5")+_TABELA))
		
		_cont:=0
		_tot:=0
		
		WHILE _TABELA == SX5->X5_TABELA
			Control := alltrim(SX5->X5_CHAVE) + "/"
			IF LEN(ALLTRIM(SX5->X5_DESCRI))>27
				nTan:=27
				WHILE nTan > 0
					IF SUBSTR(SX5->X5_DESCRI,nTan,1)==" "
						EXIT
					ENDIF
					nTan:=nTan - 1
				ENDDO
				_Texto1:=Substr(sx5->x5_Descri,1,nTan)
				_Texto2:=Substr(sx5->x5_Descri,nTan+1,27)
				IF Control $ Descr
					AADD(aVetmat,{SX5->X5_CHAVE+"-",_Texto1,"          "})
					AADD(aVetmat,{"       ",_Texto2,"-->(X)    "})
					_CONT:=_CONT + 2
				ELSE
					IF MV_PAR02 == 1
						AADD(aVetmat,{SX5->X5_CHAVE+"-",_Texto1,"          "})
						AADD(aVetmat,{"       ",_Texto2,"-->( )    "})
						_CONT:=_CONT + 2
					ENDIF
				ENDIF
			ELSE
				IF Control $ Descr
					AADD(aVetmat,{SX5->X5_CHAVE+"-",SUBSTR(SX5->X5_DESCRI,1,27),"-->(X)    "})
					_CONT:=_CONT+1
				ELSE
					IF MV_PAR02==1
						AADD(aVetmat,{SX5->X5_CHAVE+"-",SUBSTR(SX5->X5_DESCRI,1,27),"-->( )    "})
						_CONT:=_CONT+1
					ENDIF
				ENDIF
			ENDIF
			DBSKIP()
		ENDDO
		
		
		IF LEN(aVetMat)>0
			WHILE _CONT/3 - INT(_CONT/3)<>0
				_CONT:=_CONT+1
				AADD(aVetmat,{"N","N","N"})
			ENDDO
			_TOT:=_CONT/3
			
			FOR I:=1 TO _TOT
				
				IF aVetmat[i,1]<>"N"
					@nlin,00 PSAY aVetMat[i,1]+aVetMat[i,2]+aVetMat[i,3]
				ENDIF
				@nlin,44 PSAY "|"
				IF aVetmat[i+_TOT,1]<>"N"
					@nlin,45 PSAY aVetMat[i+_TOT,1]+aVetMat[i+_TOT,2]+aVetMat[i+_TOT,3]
				ENDIF
				@nlin,89 PSAY "|"
				IF aVetmat[i+(2*_TOT),1]<>"N"
					@nlin,90 PSAY aVetMat[i+(2*_TOT),1]+aVetMat[i+(2*_TOT),2]+aVetMat[i+(2*_TOT),3]
				ENDIF
				nlin:=nLin+1
			NEXT
		ELSE
			nlin:=nLin+1
			@nlin,00 PSAY " NAO HA ITENS PENDENTES "
			nlin:=nLin+1
		ENDIF
	ENDIF
	@nlin,0 PSAY REPLIC("-",216)
	nlin:=nlin+1
	@nlin,00 PSAY "OBSERVACOES :"
	nlin:=nlin+1
	IF MV_PAR03 == 1
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHB->DHB_HISLIB),1,117)+REPLIC("-",117-LEN(SUBSTR(ALLTRIM(DHB->DHB_HISLIB),1,117)))
		nlin:=nlin+2
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHB->DHB_HISLIB),118,117)+REPLIC("-",117-LEN(SUBSTR(ALLTRIM(DHB->DHB_HISLIB),178,117)))
		nlin:=nlin+2
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHB->DHB_HISLIB),235,117)+REPLIC("-",235-LEN(SUBSTR(ALLTRIM(DHB->DHB_HISLIB),235,117)))
		nlin:=nlin+2
	ELSE
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+2
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+2
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+6
	ENDIF
	@nlin,01 PSAY "RESPONSAVEL PELA INSPECAO: "+DHB->DHB_RESLIB
	nlin:=nlin+4
	@nlin,00 PSAY "----------------------------------------         "
	nlin:=nlin+2
	@nlin,00 PSAY "             Assinatura                          "
	nlin:=nlin+1
	@nlin,00 PSAY REPLIC("-",216)
	nlin:=nlin+1
	@nlin,00 PSAY "                         O NAO CUMPRIMENTO DE QUALQUER UM DOS ITENS IMPEDE O CARREGAMENTO."
ELSE
	nlin:= Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho) + 1
	nlin:= nlin+6
	@nlin,10 PSAY "NAO EXISTE CPF INFORMADO"
ENDIF
nlin:=nlin+2
Roda(0," ",Tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

RETURN
 
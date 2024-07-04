#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVR001()
Folha de Vistoria de Caminhoes
Adaptação da função TDCVR001
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVR001()
 
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
cDesc2    := PadC("informacoes de caminhoes vistoriados.........             ",74)
cDesc3    := PadC("Template Combustiveis Veiculos                            ",74)
wnrel     := "CVR001"
cPerg     := "CVR001"
nomeprog  := "DCLVR001"
nLastkey  :=  0
cString   := "DHA"
aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
li        :=  66
lContinua := .T.
m_pag     := 1
Caracter  := 18
Titulo    := PadC("INSPECAO DE VEICULOS",74)
Cabec1    := ""
Cabec2    := ""
_cPerg:="CVR001"



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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do dados.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RptDetail()},Titulo)
Return

Static Function RptDetail()
Local I:=0

DBSELECTAREA("DHA")
DBSETORDER(1)
IF DBSEEK(XFILIAL("DHA")+MV_PAR01)
	nlin:=Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,Limite)
	nlin:=nLin+1
	@nlin,01 PSAY "PLACA........:"+DHA->DHA_PLACA
	@nlin,35 PSAY "DATA EMISSAO.:"+DTOC(DATE())
	@nlin,70 PSAY "EMITENTE.....:"+SUBSTR(CUSUARIO,7,15)
	nlin:= nlin+1
	@nlin,01 PSAY "VEICULO......:"+DHA->DHA_MARCA
	@nlin,35 PSAY "ANO FAB......:"+DHA->DHA_ANOFAB
	@nlin,70 PSAY "TIPO.........:"+IIF(DHA->DHA_TIPO=='CV',"CAVALO",IIF(DHA->DHA_TIPO=="TR","TRUCK","CARRETA"))
	nlin:= nlin+1
	@nlin,01 PSAY "ESPECIFI.....: "+ALLTRIM(DHA->DHA_DESCRI)
	nlin:= nlin+1
	IF DHA->DHA_TIPO<>"CV"
		@nlin,01  PSAY "CAPACIDADE...: "+STR(DHA->DHA_CAPTOT,6)
		nlin:= nlin+1
		@nlin,01  PSAY "COMP01.......: "+STR(DHA->DHA_COMP01,6)
		@nlin,35  PSAY "COMP02.......: "+STR(DHA->DHA_COMP02,6)
		@nlin,70  PSAY "COMP03.......: "+STR(DHA->DHA_COMP03,6)
		IF DHA->DHA_COMP04 <> 0
			nlin:= nlin+1
			@nlin,01  PSAY "COMP04.......: "+STR(DHA->DHA_COMP04,6)
			@nlin,35  PSAY "COMP05.......: "+STR(DHA->DHA_COMP05,6)
			@nlin,70  PSAY "COMP06.......: "+STR(DHA->DHA_COMP06,6)
		ENDIF
		nlin:= nlin+2
	ENDIF
	@nlin,01 PSAY "TRANSP.......: "+DHA->DHA_CODTRA+" / "+DHA->DHA_NOMTRA
	@nlin,70 PSAY "FRETE........: "+IIF(DHA->DHA_TFRETE=="C","CIF","FOB")
	nlin:=nlin+1
	@nlin,0 PSAY REPLIC("-",220)
	nlin:=nlin+1
	@nlin,0 PSAY "ITENS EM DESACORDO "
	nlin:=nlin+1
	@nlin,0 PSAY "IT.   DESCRIACAO                            |   IT.  DESCRICAO                            |   IT.  DESCRICAO                           "
	nlin:=nlin+1
	@nlin,00 PSAY REPLIC("-",220)
	nlin:=nlin+1
	
	// Armazena Itens em Desacordo Marcados
	Descr := alltrim(DHA->DHA_ITEMDE)
	
	// IMPRESSAO DOS ITENS DA TABELA
	aVetmat:={}
	_TABELA:=IIF(DHA->DHA_TFRETE=="F","IC","HM")
	DBSELECTAREA("SX5")
	DBSETORDER(1)
	IF 	SX5->(DBSEEK(XFILIAL('SX5')+_TABELA))
		
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
	@nlin,0 PSAY REPLIC("-",220)
	nlin:=nlin+1
	@nlin,00 PSAY "OBSERVACOES :"
	nlin:=nlin+1
	IF MV_PAR03 == 1
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHA->DHA_HISLIB),1,117)+REPLIC("-",117-LEN(SUBSTR(ALLTRIM(DHA->DHA_HISLIB),1,117)))
		nlin:=nlin+2
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHA->DHA_HISLIB),118,117)+REPLIC("-",117-LEN(SUBSTR(ALLTRIM(DHA->DHA_HISLIB),178,117)))
		nlin:=nlin+2
		@nlin,15 PSAY SUBSTR(ALLTRIM(DHA->DHA_HISLIB),235,117)+REPLIC("-",235-LEN(SUBSTR(ALLTRIM(DHA->DHA_HISLIB),235,117)))
		nlin:=nlin+2
	ELSE
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+2
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+2
		@nlin,15 PSAY REPLIC("-",117)
		nlin:=nlin+2
	ENDIF
	//@nlin,15 PSAY " MOTORISTA: "+SZI->ZI_NOMEMOT
	@nlin,70 PSAY "RESPONSAVEL PELA INSPECAO: "+DHA->DHA_RESLIB
	nlin:=nlin+2
	@nlin,00 PSAY "               ----------------------------------------           "
	nlin:=nlin+2
	@nlin,00 PSAY "                              Assinatura                          "
	nlin:=nlin+1
	@nlin,00 PSAY REPLIC("-",220)
	nlin:=nlin+1
	@nlin,00 PSAY "                       O NAO CUMPRIMENTO DE QUALQUER UM DOS ITENS IMPEDE O CARREGAMENTO"
ELSE
	nlin:= Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho) + 1
	nlin:= nlin+6
	@nlin,10 PSAY "NAO EXISTE PLACA INFORMADA"
ENDIF
nlin:=nlin+2
Roda(0," ",Tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

RETURN


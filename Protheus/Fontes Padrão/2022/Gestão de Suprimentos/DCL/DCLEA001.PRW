#INCLUDE "PROTHEUS.CH"

#DEFINE MB_ICONASTERISK 64
#DEFINE PULALINHA Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA001
Equaliza notas fiscais de saida de acordo com fator 
 informado no arquivo D3A, FATORES
 
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA001()
Local I:=0, J:=0
Local nTamSX1   := Len(SX1->X1_GRUPO)
Local nTamNF	:= TamSX3('D3_NFORP')[1]

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CAREA,_NREC,_CIND,TAMANHO,LIMITE,CDESC1")
SetPrvt("CDESC2,CDESC3,WNREL,CPERG,NOMEPROG,NLASTKEY")
SetPrvt("CSTRING,ARETURN,LI,LCONTINUA,M_PAG,TITULO")
SetPrvt("AMAT,lOkFat,_HORA,_DATA,_CCOMP1,_CCOMP2")
SetPrvt("_QUANT,NPOS,_PRODUTO,_CCAB2,CABEC1,CABEC2")
SetPrvt("I,lOkRegrav,_SALIAS,AREGS,J,")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos Arqquivos.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVetor := {}
_aRegs :={}
_SEQ:=""
_cArea     := Alias()
_nRec      := Recno()
_cInd      := IndexOrd()

Tamanho   := "M"
Limite    := 132
cDesc1    := PadC(" RELATORIO DE MOVIMENTACOES INTERNAS EQUALIZACAO ",74)
cDesc2    := ""
cDesc3    := ""
wnrel     := "DCEA001"
_cPerg     := "DCEA001"
nomeprog  := "DCLEA001"
nLastkey  :=  0
cString   := "SD2"
aReturn   := {"Branco",1,"Comercial",1,2,1,"",1}
li        :=  66
lContinua := .T.
m_pag     := 1        
_MV_PAR01 := CTOD('  /  /  ')
_MV_PAR02 := 1
lTemDados := .F.

Titulo    := PadC("Movimentacoes Internas a Equalizar ",74)

For i:=1 to Len(_aRegs)
	If ! SX1->(dbSeek(PADR(_cPerg,nTamSX1)+_aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(_aRegs[i])
				FieldPut(j,_aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next


IF ! PERGUNTE(_CPERG,.T.)
	RETURN
ENDIF
_MV_PAR01:=MV_PAR01
_MV_PAR02:=MV_PAR02
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//areturn[4]==formato
//areturn[5]==m¡dia
//areturn[7]==filtro
//areturn[8]==ordem

//wnrel
// 8=.f.= desabilita dicionario de dados
// 9=mostra ordem
//10=comprimido/normal
//11=tamanho da letra
//12=habilita filtro

//m_pag:=1.1  NAO IMPRIME PAGINA DE PARAMETROS


RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	RptStatus({|| Execute(RptDetail)})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail
 
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------	
Static Function RptDetail()
Local i:=0
Local nTamNF := TamSX3('D3_NFORP')[1]
Local lErroSG1:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
SetRegua(Reccount())
SF2->(DbSetOrder(16)) //F2_FILIAL+DTOS(F2_EMISSAO)+F2_HORA //Índice "H"
aMat:={}
lOkFat:="S"
_DATA:=MV_PAR01

SF2->(DbSeek(XFILIAL("SF2") + DTOS(MV_PAR01),.T.))
WHILE ! EOF() .AND. SF2->F2_FILIAL == XFILIAL("SF2") .and. DTOS(F2_EMISSAO) == DTOS(MV_PAR01)
	IncRegua()
	_HORA:=SUBSTR(SF2->F2_HORA,1,2)+SUBSTR(SF2->F2_HORA,4,2)
	
	IF EMPTY(SF2->F2_HORA) .OR. EMPTY(SF2->F2_EMISSAO)
		SF2->(DbSkip())
		LOOP
	ENDIF
	
	IF SF2->F2_EMISSAO <>  MV_PAR01
		SF2->(DbSkip())
		LOOP
	ENDIF
	
	DBSELECTAREA("SD2")
	DBSETORDER(3)
	DBSEEK(XFILIAL()+SF2->F2_DOC+SF2->F2_SERIE)
	
	DH3->(DbSetOrder(2))
	DH3->(DbSeek(xFilial("DH3")+SD2->(D2_DOC+D2_SERIE+D2_ITEM)))
	
	WHILE SF2->F2_DOC == SD2->D2_DOC .AND. SF2->F2_SERIE == SD2->D2_SERIE
		
		SB1->(DBSEEK(XFILIAL()+SD2->D2_COD))
		DBSELECTAREA("SF4")
		DBSETORDER(1)
		IF ! DBSEEK(XFILIAL()+SD2->D2_TES)
			DBSELECTAREA("SD2")
			DBSKIP()
			LOOP
		ELSE
			IF SF4->F4_ESTOQUE<>"S"
				DBSELECTAREA("SD2")
				DBSKIP()
				LOOP
			ENDIF
		ENDIF
		
		DBSELECTAREA("D3A")
		DBSETORDER(1)
		lGravo:=.F.
		_DIF:=0
		DH5->(DbSetOrder(1))
		DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
		IF DH5->DH5_PREQUI <> "S"
			// PRODUTO DE APROPRIACAO DIRETA
			IF DBSEEK(XFILIAL()+DTOS(_DATA)+SD2->D2_COD)
				WHILE D3A->D3A_FILIAL == xFilial("D3A") .AND.;
					D3A->D3A_DATA   == _DATA          .AND.;
					D3A->D3A_COD    == SD2->D2_COD
					IF _HORA >= D3A->D3A_HORAIN .AND. _HORA < D3A->D3A_HORAFI						
						RECLOCK("DH3",.F.)
						DH3->DH3_TANQ1	:= D3A->D3A_TANQUE
						DH3->DH3_QTD1		:= (IF(SD2->D2_RET20G == 'S',1,D3A->D3A_FATOR) * SD2->D2_QUANT)
						MSUNLOCK()
						_DIF:=(SD2->D2_QUANT - DH3->DH3_QTD1)
						lGravo:=.T.
						EXIT
					ENDIF
					DBSELECTAREA("D3A")
					DBSKIP()
				ENDDO
				nPos := aScan(aMat,{ |X| X[1] == SD2->D2_COD+SD2->D2_LOCAL+DTOS(_DATA)})
				if nPos == 0
					Aadd(aMat,{SD2->D2_COD+SD2->D2_LOCAL+DTOS(_DATA),SD2->D2_COD,SD2->D2_LOCAL,_DATA,(SD2->D2_QUANT - DH3->DH3_QTD1),"          ",0})
				else
					aMat[nPos,5] := aMat[nPos,5] + (SD2->D2_QUANT - DH3->DH3_QTD1)
				Endif
				IF ! lGravo
					MessageBox("Não existe Fator Produto " + ALLTRIM(SD2->D2_COD) + PULALINHA + " Data Saida: " + DTOC(SF2->F2_EMISSAO) + PULALINHA + " Hora: "+SF2->F2_HORA,"Atenção",MB_ICONASTERISK)
					lOkFat:="N"
				ENDIF
			ELSE
				MessageBox("Nao Existe Fator Produto " + AllTrim(SD2->D2_COD)  + PULALINHA +  " Data Saida: " + DTOC(SF2->F2_EMISSAO)  + PULALINHA +  " Hora: "+SF2->F2_HORA,"Atenção",MB_ICONASTERISK)
            	lOkFat:="N"
			ENDIF
		ELSE
			DBSELECTAREA("SG1")
			DBSETORDER(5)
			DBSEEK(XFILIAL()+SD2->D2_COD+DTOS(_DATA),.T.)
			dFim:=SG1->G1_FIM
			_VEZES:=0
			_SEQ:=""
			WHILE SD2->D2_COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM
				_DIF:=0
				_VEZES:=_VEZES+1
				_SEQ:=SUBSTR(SG1->G1_TRT,3,1)
				DBSELECTAREA("D3A")
				DBSETORDER(1)
				
				// criar Posicionamento da DH3
				DH3->(DBSELECTAREA("DH3"))
				DH3->(DBSETORDER(2))
				DH3->(DbSeek(xFilial("DH3")+SD2->(D2_DOC+D2_SERIE+D2_ITEM)))
				
				//Valida cadastro de estrutura
				lErroSG1 := .F. 
				If Empty(_SEQ) .Or. DH3->(FieldPos("DH3_TANQ"+_SEQ)) == 0 .Or. DH3->(FieldPos("DH3_TANQ"+_SEQ)) == 0
					lErroSG1 := .T.
					Exit
				EndIf
				IF DBSEEK(XFILIAL()+DTOS(D3A_DATA)+SG1->G1_COMP)
					WHILE D3A->D3A_FILIAL == xFilial("D3A") .AND.;
						D3A->D3A_DATA   == _DATA          .AND.;
						D3A->D3A_COD    == SG1->G1_COMP
						IF _HORA >= D3A->D3A_HORAIN .AND. _HORA < D3A->D3A_HORAFI
							DBSELECTAREA("DH3")
							RECLOCK("DH3",.F.)
							_Tanque:="DH3->DH3_TANQ"+_SEQ
							_QTD   :="DH3->DH3_TANQ"+_SEQ
							&(_Tanque):= D3A->D3A_TANQUE
							&(_QTD)   := (IF(SD2->D2_RET20G == 'S',1,D3A->D3A_FATOR) * (SD2->D2_QUANT*SG1->G1_QUANT))
							MSUNLOCK()
							_DIF:=(SD2->D2_QUANT*SG1->G1_QUANT) - (D3A->D3A_FATOR * (SD2->D2_QUANT*SG1->G1_QUANT))
							lGravo:=.T.
							EXIT
						ENDIF
						DBSKIP()
					ENDDO
					nPos := aScan(aMat,{ |X| X[1] == SG1->G1_COMP+SD2->D2_LOCAL+DTOS(_DATA)})
					if nPos == 0
						Aadd(aMat,{SG1->G1_COMP+SD2->D2_LOCAL+DTOS(_DATA),SG1->G1_COMP,SD2->D2_LOCAL,_DATA,_DIF,"          ",0})
					else
						aMat[nPos,5] := aMat[nPos,5] + _DIF
					ENDIF
				ELSE
					MessageBox("Nao Existe Fator Produto " + ALLTRIM(SG1->G1_COMP) + PULALINHA + " Data Saida: " + DTOC(SF2->F2_EMISSAO) + PULALINHA + " Hora: " + SF2->F2_HORA,"Atenção",MB_ICONASTERISK)
					lOkFat:="N"
					EXIT
				ENDIF
				DBSELECTAREA("SG1")
				DBSKIP()
			ENDDO
			IF lErroSG1
				MessageBox(" Erro no cadastro da Estrutura " + ALLTRIM(SD2->D2_COD),"Atenção",MB_ICONASTERISK)
				lOkFat:="N"
			ElseIF _VEZES<VAL(_SEQ)
				MessageBox(" Nao Existe Fatores para algum Item da Estrutura " + ALLTRIM(SD2->D2_COD) + PULALINHA + " DATA SAIDA: " + DTOC(SF2->F2_EMISSAO) + PULALINHA + " HORA: "+SF2->F2_HORA,"Atenção",MB_ICONASTERISK)
				lOkFat:="N"
			ENDIF
		ENDIF
		DBSELECTAREA("SD2")
		DBSKIP()
	ENDDO
	DBSELECTAREA("SF2")
	DBSKIP()
ENDDO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DOS DADOS FILTRADOS  NO VETOR                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
_cCab2:=""

Cabec1:="Produto                     Local   Data Ref.    Qtd.a Gerar     Qtd.ja Gravada   Status"
// XXXX  XXXXXXXXXXXXXXXXXXXX   XX     99/99/99     999,999,999       999,999,999   XXXXXXXXX
//1                            30     37           50                 69            83
cabec2:=""
li:=60
_MV_PAR01:=MV_PAR01
_MV_PAR02:=MV_PAR02


DBSELECTAREA("D35") 
DBSETORDER(1)     
DBSEEK(XFILIAL("D35"))
WHILE ! EOF() .AND. D35->D35_FILIAL == XFILIAL("D35") 
	DBSELECTAREA("D3A")      
	DBSETORDER(1) 
	DBSEEK(XFILIAL("D3A")) 
	WHILE ! EOF() .AND. D3A->D3A_FILIAL = XFILIAL("D3A") 
		nPos := aScan(aMat,{ |X| X[1] == D3A->D3A_COD+D35->D35_LOCAL+DTOS(_DATA)})
		if nPos == 0
			Aadd(aMat,{D3A->D3A_COD+D35->D35_LOCAL+DTOS(_DATA),D3A->D3A_COD,D35->D35_LOCAL,_DATA,0,"          ",0})
		Endif
		DBSKIP()
	ENDDO
	DBSELECTAREA("D35")
	DBSKIP()
ENDDO

lOkTm:=.T.
DbSelectArea("SF5")
SF5->(DbSetorder(2)) //F5_FILIAL+F5_MOVTANQ+F5_TIPO
IF ! SF5->(DbSeek(xFilial()+"EQ"+"R"))
	MessageBox("Mov. Internos Req. para equalizacao nao cadastrado","Atenção",MB_ICONASTERISK)
   lOkTm:=.F.
ELSE
	_TMR:=SF5->F5_CODIGO
ENDIF

IF ! DBSEEK(XFILIAL()+"EQ"+"D")
	MessageBox("Mov. Internos Dev. para equalizacao nao cadastrado","Atenção",MB_ICONASTERISK)
   lOkTm:=.F.
ELSE
	_TMD:=SF5->F5_CODIGO
ENDIF

DBSELECTAREA("SF5")
DBSETORDER(1)

Begin Transaction

IF lOkTm
	For i:=1 to Len(aMat)
		lOkRegrav:=.T.
		If li > 55
			li :=1
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			LI:=li+1
		EndIf
		IF _DATA > GETMV("MV_ULMES")
			DBSELECTAREA("SD3")
	        DBSETORDER(16)
    	    IF SD3->(DBSEEK(XFILIAL("SD3")+Space(nTamNF)+"EQ"+" "+DTOS(_DATA)+aMat[i,2]+aMat[i,3]))
			   aMat[i,7]:=SD3->D3_QUANT
				//Se for diferente arredondando e não arredondando Ex.: 147,545 ... as vezes retorna 147,54 e as vezes retorna 147,55 -> Precisa entender melhor o que faz no SD3
				IF SD3->D3_QUANT <> NoRound(IIF(SD3->D3_TM<='500',aMat[i,5],(aMat[i,5] * -1))) .and.  SD3->D3_QUANT <> Round(IIF(SD3->D3_TM<='500',aMat[i,5],(aMat[i,5] * -1)),2)    
					aMat[i,6]:="###### <> #########"
					IF _MV_PAR02 == 1						





						lMsErroAuto:=.F.
						aVetor :=	{{"D3_NUMSEQ"	,SD3->D3_NUMSEQ	,NIL},;
									 {"D3_CHAVE"	,SD3->D3_CHAVE	,NIL},;
									 {"D3_COD"		,SD3->D3_COD		,NIL},;
					           	 {"INDEX"		,4					,NIL}}
						MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno



						If lMsErroAuto
							MOSTRAERRO()
							DisarmTransaction()
						EndIf





						aMat[i,6]:="Regravado com Sucesso"
					ENDIF
				ELSE
					aMat[i,6]:="======== OK ==========="
					lOkReGrav:=.F.
				ENDIF
			ENDIF
			
			IF lOkReGrav .AND. _MV_PAR02 == 1 .AND. aMat[i,5]<>0 .AND. lOkFat=="S"
				DBSELECTAREA("SB1")
				DBSEEK(XFILIAL()+aMat[i,2])
				lMsErroAuto := .F.
				DBSELECTAREA("SD3")
				aVetor:={ {"D3_TM"     ,IIF(aMat[i,5]>0,_TMD,_TMR),NIL},;
				{"D3_COD"    ,aMat[i,2],NIL},;
				{"D3_QUANT"  ,IIF(aMat[i,5]>0,aMat[i,5],(aMat[i,5] * -1)),NIL},;
				{"D3_LOCAL"  ,aMat[i,3],NIL},;
				{"D3_TPMOVAJ"  ,"EQ",NIL},;
				{"D3_DOC"  ,NextNumero("SD3",2,"D3_DOC",.T.),NIL},;
				{"D3_EMISSAO",_DATA,NIL}}
				MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
				If lMsErroAuto
					MOSTRAERRO()
					DisarmTransaction()
				Endif
				aMat[i,6]:=" Gravado com Sucesso "
			ENDIF
		ELSE
			aMat[i,6]:=" Fechamento ja Promovido "
		ENDIF
		aVetor:={}
		SB1->(DBSEEK(XFILIAL()+aMat[i,2]))
		If aMat[i,5] <> 0 .Or. aMat[i,7] <> 0  //Só imprime se tiver quantidade equalizada ou ajustada ou diferença
			lTemDados := .T.
			@ li,00 PSAY ALLTRIM(aMat[i,2])+"  "+SUBSTR(SB1->B1_DESC,1,20)
			@ li,31 PSAY aMat[i,3]
			@ li,38 PSAY aMat[i,4]
			@ li,50 PSAY aMat[i,5] PICTURE "@R 999,999,999"
			@ li,69 PSAY aMat[i,7] PICTURE "@R 999,999,999"
			@ li,83 PSAY aMat[i,6]
			LI:=li+1
		Endif
	next
ENDIF

If !lTemDados 
	Li:= 8
	@ li,00 PSAY "Não existem dados para ser impresso..."
Endif

End Transaction

LI:=li+1

Roda(0," ",Tamanho)
Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

dbSelectArea(_cArea)
dbSetOrder(_cInd)
dbGoto(_nRec)

RETURN



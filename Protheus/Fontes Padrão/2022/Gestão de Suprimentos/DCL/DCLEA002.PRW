#INCLUDE "PROTHEUS.CH"

#DEFINE MB_ICONASTERISK 64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA002
Browse para informacao de Hora de Saida da Nota Fiscal

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA002()
Local I:=0, J:=0
Local nTamSX1   := Len(SX1->X1_GRUPO)
Local nTamNF	:= TamSX3('D1_DOC')[1]
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que ra somente as variaveis definidas pelo usuario,  		?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
Private _cPerg      :="DCEA002"
Private aRegs      :={}

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

lAS400 := .F.

cCadastro := OemtoAnsi("Notas Fiscais Saida")

aRotina :=	{{ "Pesquisar" ,   "AxPesqui"                  , 0, 1},;
			 { "Informar Horas ","DCEA01A()", 0, 6}}

dbSelectArea("SF2")
dbSetOrder(1)
DBGOBOTTOM()
mBrowse( 6,1,22,75,"SF2")

dbSelectArea("SF2")
dbSetOrder(1)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA01A
Digitacao e gravacao de Hora de Saida da Nota Fiscal

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA01A()        // incluido pelo assistente de conversao do AP5 IDE em 21/01/01
Local nTamSX1   := Len(SX1->X1_GRUPO)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VALIDA,_TAN,_PRODUTO,")

_Valida:= .T.

IF ! PERGUNTE(_CPERG,.T.)
ELSE
	IF MV_PAR05 <= GETMV("MV_ULMES") .AND. ! EMPTY(MV_PAR05)
		MessageBox("Data Informada Anterior ao Ultimo Fechamento","Data Invalida",MB_ICONASTERISK)
		RETURN
	ENDIF

	IF SUBSTR(MV_PAR06,3,1)==":" .AND. VAL(SUBSTR(MV_PAR06,1,2)) <=24 .AND. VAL(SUBSTR(MV_PAR06,1,2))>0 ;
		.AND. VAL(SUBSTR(MV_PAR06,4,2)) <=59 .AND. VAL(SUBSTR(MV_PAR06,4,2))>=0 ;
		.AND. ! EMPTY(SUBSTR(MV_PAR06,1,1)) ;
		.AND. ! EMPTY(SUBSTR(MV_PAR06,2,1)) ;
		.AND. ! EMPTY(SUBSTR(MV_PAR06,4,1)) ;
		.AND. ! EMPTY(SUBSTR(MV_PAR06,5,1))
		DBSELECTAREA("SF2")
		DBSETORDER(1)
		IF DBSEEK(XFILIAL("SF2")+MV_PAR02+MV_PAR01)
			WHILE SF2->F2_FILIAL == xFilial("SF2") .And. ;
			  SF2->F2_DOC <= MV_PAR03 .AND. SF2->F2_SERIE == MV_PAR01 .AND. !EOF()
				RECLOCK("SF2",.F.)
				IF SF2->F2_EMISSAO <= GETMV("MV_ULMES")
					MessageBox("NF: " + SF2->F2_DOC + "/" + SF2->F2_SERIE + " Anterior ao Fechamento. ","Data Invalida",MB_ICONASTERISK)
					MSUNLOCK()
					DBSKIP()
					LOOP
                ELSEIF SF2->F2_EMISSAO <> MV_PAR04
                    DBSKIP()
                    LOOP
				ELSE
					IF MV_PAR07==1
						SF2->F2_HORA:=IIF(EMPTY(SF2->F2_HORA),MV_PAR06,SF2->F2_HORA)
					ELSE
						SF2->F2_HORA:=MV_PAR06
					ENDIF
				ENDIF

				IF MV_PAR04 < SF2->F2_EMISSAO
					MessageBox(" Data de Emissao da Nota: " + SF2->F2_DOC + " Maior que a Data Informada.","Aten豫o",MB_ICONASTERISK)
					_Valida:= .F.
				ELSE
					IF MV_PAR07==1
						SF2->F2_EMISSAO:=IIF(EMPTY(SF2->F2_EMISSAO),MV_PAR04,SF2->F2_EMISSAO)
					ELSE
						SF2->F2_EMISSAO:=MV_PAR04
					ENDIF
				ENDIF
				MSUNLOCK()
				DBSKIP()
			ENDDO
		ELSE
			MessageBox('Nota Nao Localizada ',"Aten豫o",MB_ICONASTERISK)
		ENDIF
	ELSE
		DBSELECTAREA("SF2")
		DBSETORDER(1)
		IF EMPTY(MV_PAR06) .AND. DBSEEK(XFILIAL("SF2")+MV_PAR02+MV_PAR01)
			IF SF2->F2_EMISSAO <= GETMV("MV_ULMES")
				MessageBox("NF: " + SF2->F2_DOC + "/" + SF2->F2_SERIE + " Anterior ao Fechamento: ","Data Invalida",MB_ICONASTERISK)
			ELSE
				MessageBox(" Baixa Estornada -> Nota Fiscal: " + SF2->F2_DOC + "/" + SF2->F2_SERIE,"Aten豫o",MB_ICONASTERISK)
				RECLOCK("SF2",.F.)
				SF2->F2_EMISSAO:=CTOD("  /  /  ")
				SF2->F2_HORA:=SPACE(5)
				MSUNLOCK()
			ENDIF
		ELSE
			MessageBox(" Hora informada inv?ida !!! -> Informar  HH:MM ","Aten豫o",MB_ICONASTERISK)
		ENDIF
	ENDIF
ENDIF
DBSEEK(XFILIAL("SF2")+MV_PAR02+MV_PAR01)
Return(NIL)


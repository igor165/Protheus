#include  "PROTHEUS.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º M460Livr   º Autor º      Nava       º Data º  03/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º        Programa de Geracao de Livro Fiscal para todos os Paises       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M460Livr( aItemInfo, aLivro, nTaxa, cTipoMov )            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº aItemInfo  - Impostos Variaveis do SD2 			          º±±
±±º           º aLivro     - Livros Fiscais            			          º±±
±±º           º nTaxa      - Taxa corrente da moeda     			      º±±
±±º           º cTipoMov   - Tipo Movimentacao         			          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aLivro(array com os dados do livro fiscal)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º Localizacoes 							            	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramadorº Data   º BOPS º  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºBruno Sob. º13/10/99ºxxxxxxº Gravar os campos de Nfiscal, Serie, etc.  º±±
±±º           º        º      º cuando chamado de Compras.                º±±
±±º           º        º      º                                           º±±
±±ºFernando M.º19/07/00ºxxxxxxº Gravacao dos campos F3_TPDOC e F3_TIPOMOV º±±
±±º           º        º      º (Loc. Chile)                              º±±
±±º           º        º      º                                           º±±
±±º Nava      º03/07/01ºxxxxxxº Reescrito o programa para todos os paises º±±
±±º           º        º      º                                           º±±
±±ºFernando M.º11/02/03ºxxxxxxº Gravacao dos campos F3_DOCCF e F3_TPDOCCF º±±
±±º           º        º      º (Loc. Argentina)                          º±±
±±ºNorbert W. º20/07/07º117704º Gravacao da serie informada na rotina de  º±±
±±º           º        º      º fatura global 							  º±±
±±º           º        º      º											  º±±
±±ºTiago Bizanº15/07/10ºxxxxxxº Gravação do tipo da alíquota (F3_TPALIQ) eº±±
±±º			  º	       º	  º	do campo exentas (F3_EXENTAS)localização  º±±
±±º			  º	       º	  º Venezuela								  º±±
±±ºL. Enríquezº25/06/18ºxxxxxxº Se agrega rutina FINR140 a variable lFatPVº±±
±±º			  º	       º	  º	para omitir busqueda de Cód. Fiscal en el º±±
±±º			  º	       º	  º arreglo aHeader. (COL)					  º±±
±±ºG.Santacruzº23/05/19ºDMINA-ºGeraLivr() Considera ejecución de MATA467N º±±
±±º			  º	       º  6748ºpara manejo correcto de código fiscal.(COL)º±±
±±ºARodriguez º25/06/19ºDMINA-ºTratamiento CFO para MEX igual que COL	  º±±
±±º           º        º  6748ºDepurar variables no usadas. COL/MEX		  º±±
±±º Marco A.  º05/02/20ºDMINA-ºSe quita el tratamiento de calculo de lib. º±±
±±º           º        º  8370ºfiscales para la rutina FINC021. (COL/MEX) º±±
±±º Marco A.  º06/04/20ºDMINA-ºSe quita el tratamiento de calculo de lib. º±±
±±º           º        º  8755ºfiscales para la rutina MATR700. (MEX)     º±±
±±º Marco A.  º16/04/20ºDMINA-ºSe agrega tratamiento para rutina automa-  º±±
±±º           º        º  8819ºtica. (MEX|COL)                            º±±
±±ºARodriguez º17/04/20ºDMINA-ºOmitir calculo si el arreglo aHeader no    º±±
±±º           º        º  8695ºexiste. (MEX)                              º±±
±±º Marco A.  º07/09/20ºDMINA-ºSe agrega tratamiento para llenar el campo º±±
±±º           º        º  9972ºF3_TPDOC con el valor del campo F2_TPDOC   º±±
±±º           º        º      ºcuando los doctos. sean NF/NCC/NDC. (PER)  º±±
±±ºVerónica F.º06/09/20ºDMINA-ºSe agrega tratamiento para utilizar el     º±±
±±º           º        º  9915ºcampo UB_CF cuando se ingresa desde la     º±±
±±º           º        º      ºrutina TMKA271 en la función M460Livr (MEX)º±±
±±º           º        º      ºEn la función M460Livrse obtiene el CFO porº±±
±±º           º        º      ºmedio de MaFisRet cuando se ingresa desde  º±±
±±º           º        º      ºrutina TECA400                             º±±
±±ºAlf.Medranoº21/09/20ºDMINA-ºEn Fun M460Livr  excluye referencia a posi-º±±
±±º           º        º 9922 ºción 9 del array aItemInfo para COL        º±±
±±ºEduardo Przº09/12/20ºDMINA-ºEn Fun M460Livr agrega funcion mata468n    º±±
±±º           º        º10688 ºpara permitir calculo de CFO.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460Livr(aItemInfo, aLivro, nTaxa, cTipoMov, nSinal, dDataS, cSerieF2, lUltimoItem)

/* Paises Contemplados nesta versao
DO CASE
CASE cPaisLoc == "ARG"
CASE cPaisLoc == "CHI"
CASE cPaisLoc == "COL"
CASE cPaisLoc == "MEX"
CASE cPaisLoc == "PAR"
CASE cPaisLoc == "PER"
CASE cPaisLoc == "URU"
CASE cPaisLoc == "VEN"
ENDCASE
*/

LOCAL nX,nY,nZ
LOCAL aArea 		:= GetArea()
LOCAL aImpostos		:= {}
LOCAL nTotalImp		:=	0
LOCAL aItDel
LOCAL nMoedaValor	:= 0
LOCAL nDecs			:= MsDecimais( 1 )
LOCAL nPosValr
LOCAL nPosAliq
LOCAL nPosBase
Local nPosCFO
Local lPrcDec       := SuperGetMV("MV_PRCDEC",,.F.)
Local lSC6			:= .F.
Local nPosTES       := 0
Local alAreaX
Local alAreaY
Local cConcept      := ""
Local cCFO          := ""
Local lOk           := .F.
Local cMV_AGENTE    := GetNewPar("MV_AGENTE","   ")// Parâmetro utilizado para verificar se a empresa é agente de retenção, percepção e detração
Local lCancCup      := .F.
Local nTotalBase    := 0
Local lExcento      := .F.
Local lIsLoja       := (nModulo == 12) .And. (IsInCallStack('LOJA701'))
Local lCalcIVA      := .F.
Local aArSFB        := SFB->(GetArea())
Local aArSFC        := SFC->(GetArea())
Local nPosBasBol    := 0
Local nPosLibFis    := 0

Local nFactor		:= 1
Local nValBase		:= 0
Local lNoActVal		:= .F.

//Variable utilizada para fuentes que no utilizan libros fiscales
Local lNaoLibFis := IIf(!(FunName() $ "FINC021|MATR700") .And. !isBlind(), .T., .F.)

PRIVATE cNumero     := 0
PRIVATE nE          := 0

DEFAULT nSinal		:= 1                                   
DEFAULT cSerieF2	:= ""		// Grava a serie informada na rotina de fatura global
DEFAULT lUltimoItem := .F.		// Utilizado para tratamento de arredondamento no Chile

cTipo		:=IIf(Type("cTipo")<>"C","N",cTipo)
nTaxa		:=IIf(Type("nTaxa")<>"N",0,nTaxa)

cEspecie	:= IIF(Type("cEspecie")!="U",cEspecie,MVNOTAFIS)
nMoedaAux	:= IIf(Type("nMoedaNF")	=="N",nMoedaNf,IIf(Type("nMoedaCor")=="N",nMoedaCor,1))

aImpostos	:= aItemInfo[6]
cNrLivro	:= SF4->F4_NRLIVRO
cFormula	:= SF4->F4_FORMULA
lNoActVal 	:= cPaisLoc	== "ARG" .and. Iif(Type("lNoConv") == "L", lNoConv,.F.) //lNoConv indica si es detonada al final de todos los calculos, MV_ACTLIVF = .T. indica si se actualiza el libro fiscal, si ambos son .T. se realizan las sumas sin convertir los valores por la tasa.

If !AtIsRotina("LOCXNF") .And. (nModulo == 12 .OR. nModulo == 72) .And. ; 
   (( Upper(Substr(FunName(),1,4)) == "LOJA" ) .Or.;
    ( Upper(Substr(FunName(),1,3)) == "RPC"  ) .Or.;
    ( Upper(Substr(FunName(),1,4)) <> "MATA" )).And.;
    FunName() != "LOJR130"  //Nao deve buscar a serie no SL2 para geracao de NF para cupom
     
	cNFiscal:= SL2->L2_DOC
	If cSerieF2 <> ""
		cSerie:= cSerieF2
	Else
		cSerie:= SL2->L2_SERIE
	Endif
	If nSinal < 0 .AND. (AtIsRotina("LJ140GRAVA"))
    	lCancCup  := .T. 	
	EndIf
EndIf

cNumero := IIf(Type("cNFiscal")=="C",cNFiscal,"")
cSerie  := IIF(Type("cSerie")=="C",cSerie,"")
lNaoLibFis  := (lNaoLibFis .And.(Type("aHeader")=="A" .OR. FunName()$"MATA468N|MATA461|FINR140") ) 

IF Empty( aLivro )
	aLivro := {{}}
	SX3->( DbSetOrder( 1 ) )
	SX3->( DbSeek( "SF3" ) )
	SX3->( DbEval({|| Aadd( aLivro[1], RTrim(X3_CAMPO) ) },;
	{|| (X3Uso(X3_USADO) .Or. (Substr(X3_CAMPO,1,9) $ "F3_BASIMP,F3_ALQIMP,F3_VALIMP,F3_RETIMP"))},;
	{|| X3_ARQUIVO=="SF3" } ) )
ENDIF

If Type("aImpLivr") <> "U" .and. Len(aImpLivr) > 0
	_IdxF01 := aImpLivr[1]
	_IdxF02 := aImpLivr[2]
	_IdxF03 := aImpLivr[3]
	_IdxF04 := aImpLivr[4]
	_IdxF05 := aImpLivr[5]
	_IdxF06 := aImpLivr[6]
	_IdxF07 := aImpLivr[7]
	_IdxF08 := aImpLivr[8]
	_IdxF09 := aImpLivr[9]
	_IdxF10 := aImpLivr[10]
	_IdxF11 := aImpLivr[11]
	_IdxF12 := aImpLivr[12]
	_IdxF13 := aImpLivr[13]
	_IdxF14 := aImpLivr[14]

	_IdxF15 := aImpLivr[15]
	_IdxF16 := aImpLivr[16]
	_IdxF17 := aImpLivr[17]
	_IdxF32 := aImpLivr[18]
	_IdxF33 := aImpLivr[19]
	_IdxF34 := aImpLivr[20]
	_IdxF35 := aImpLivr[21]
	_IdxF36 := aImpLivr[22]
	_IdxF37 := aImpLivr[23]
Else
	_IdxF01 := AScan( aLivro[1],{|x| x == "F3_VALCONT" } )
	_IdxF02 := AScan( aLivro[1],{|x| x == "F3_NRLIVRO" } )
	_IdxF03 := AScan( aLivro[1],{|x| x == "F3_FORMULA" } )
	_IdxF04 := AScan( aLivro[1],{|x| x == "F3_ENTRADA" } )
	_IdxF05 := AScan( aLivro[1],{|x| x == "F3_NFISCAL" } )
	_IdxF06 := AScan( aLivro[1],{|x| x == "F3_SERIE" } )
	_IdxF07 := AScan( aLivro[1],{|x| x == "F3_CLIEFOR" } )
	_IdxF08 := AScan( aLivro[1],{|x| x == "F3_LOJA" } )
	_IdxF09 := AScan( aLivro[1],{|x| x == "F3_ESTADO" } )
	_IdxF10 := AScan( aLivro[1],{|x| x == "F3_EMISSAO" } )
	_IdxF11 := AScan( aLivro[1],{|x| x == "F3_ESPECIE" } )
	_IdxF12 := AScan( aLivro[1],{|x| x == "F3_TIPOMOV" } )
	_IdxF13 := AScan( aLivro[1],{|x| x == "F3_TPDOC" } )
	_IdxF14 := AScan( aLivro[1],{|x| x == "F3_TIPO" } )
	//+---------------------------------------------------------------+
	//¦ Nao eliminar o CFO. (Lucas)...                                ¦
	//+---------------------------------------------------------------+
	_IdxF15 := AScan( aLivro[1],{|x| x == "F3_CFO" } )
	_IdxF16 := AScan( aLivro[1],{|x| x == "F3_TES" } )
	_IdxF17 := Ascan( aLivro[1],{|x| x == "F3_NIT" } )
	_IdxF32 := AScan( aLivro[1],{|x| x == "F3_EXENTAS" } )
	_IdxF33 := AScan( aLivro[1],{|x| x == "F3_FRETE" } )
	_IdxF34 := AScan( aLivro[1],{|x| x == "F3_VALMERC" } )
	_IdxF35 := AScan( aLivro[1],{|x| x == "F3_MANUAL" } )
	_IdxF36 :=0
	_IdxF37 :=0

	If Type("aImpLivr") <> "U"
		aImpLivr := {_IdxF01,_IdxF02,_IdxF03,_IdxF04,_IdxF05,_IdxF06,_IdxF07,_IdxF08,_IdxF09,_IdxF10,_IdxF11,;
						_IdxF12,_IdxF13,_IdxF14,_IdxF15,_IdxF16,_IdxF17,_IdxF32,_IdxF33,_IdxF34,_IdxF35,_IdxF36,_IdxF37}
	EndIf
EndIf

If cPaisLoc == 'URU'
	_IdxF36 := AScan( aLivro[1],{|x| x == "F3_GRPTRIB" } )	
	_IdxF37 := AScan( aLivro[1],{|x| x == "F3_CONCEPT" } )	
ElseIf cPaisLoc=="VEN"
	_IdxF36 := AScan( aLivro[1],{|x| x == "F3_TPALIQ" } )
ElseIf cPaisLoc=="EQU"
	_IdxF36 := AScan( aLivro[1],{|x| x == "F3_CONCEPT" } )
EndIf

aItDel := Array(Len(aLivro))
Afill(aItDel,.F.)
nE := Len( aLivro )

If cPaisLoc == "URU"
	If FunName()=="MATA468N" .Or. (FunName()=="MATA410" .And. Type("Acols")  <> "A")
		If Posicione("SFC",2,xFilial("SFC")+Avkey(SC6->C6_TES,"FC_IMPOSTO"),"FC_IMPOSTO")=="IRA"
			nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0 .And. nE > 1 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==SC6->C6_TES .And. AllTrim(x[_IdxF36])==POSICIONE('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO,'B1_GRPIRAE')},2),nE)
		Else
			nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)				
		EndIf
	ElseIf FunName()$"MATA410|MATA851|MATA852|MATA853" .And. aScan(aHeader,{|X| AllTrim(X[2])=='C6_TES'}) > 0
		If  nSinal > 0
			cTes:=AllTrim(If(ReadVar()=="M->C6_TES",M->C6_TES,aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='C6_TES'})]))
			cGrpIra:=AllTrim(Posicione('SB1',1,xFilial('SB1')+If(ReadVar()=="M->C6_PRODUTO".And. LEN(ACOLS)== aItemInfo[8],M->C6_PRODUTO,aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='C6_PRODUTO'})]),'B1_GRPIRAE'))
			If Posicione("SFC",2,xFilial("SFC")+cTes,"FC_IMPOSTO")=="IRA"                                                                                               
				nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0 .And. nE > 1 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra},2),nE)
			Else
				nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)
			EndIf
		Else
			cTes:=AllTrim(aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='C6_TES'})])
			cGrpIra:=AllTrim(Posicione('SB1',1,xFilial('SB1')+aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='C6_PRODUTO'})],'B1_GRPIRAE'))
			If Posicione("SFC",2,xFilial("SFC")+If(ReadVar()=="M->C6_TES",M->C6_TES,""),"FC_IMPOSTO")=="IRA"
				nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra .Or. Empty(x[_IdxF36])},2),nE)
			ElseIf Posicione("SFC",2,xFilial("SFC")+cTes,"FC_IMPOSTO")=="IRA"
				nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0  .And. nE > 1 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra .Or. Empty(x[_IdxF36])},2),nE)
			Else
				nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)
			EndIf
		EndIf
	Else
		If  nSinal > 0
			If Type("Acols") <> "U" .And. Len(aCols) > 0
				cTes    := AllTrim(If(ReadVar()=="M->D2_TES",M->D2_TES,aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='D2_TES'})]))
				cGrpIra := AllTrim(Posicione('SB1',1,xFilial('SB1')+If(ReadVar()=="M->D2_COD".And. LEN(ACOLS)== aItemInfo[8],M->D2_COD,aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='D2_COD'})]),'B1_GRPIRAE'))
			Else
				cTes    := SF4->F4_CODIGO
				If Len(aItemInfo)>=6 .and. Len(aItemInfo[6])>=1 .and. Len(aItemInfo[6][1])>=1
					cGrpIra := Posicione("SB1",1,xFilial("SB1")+aItemInfo[6][1][1],"B1_GRPIRAE")
				Else
					cGrpIra :=""
				EndIf
			EndIf
			If Posicione("SFC",2,xFilial("SFC")+cTes,"FC_IMPOSTO")=="IRA"                                                                                               
				nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0 .And. nE > 1 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra},2),nE)
			Else
				nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)				
			EndIf
		Else
			If Type("Acols") <> "U" .And. Len(aCols) > 0
				cTes:=AllTrim(aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='D2_TES'})])
				cGrpIra:=AllTrim(Posicione('SB1',1,xFilial('SB1')+aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='D2_COD'})],'B1_GRPIRAE'))
						
				If Posicione("SFC",2,xFilial("SFC")+If(ReadVar()=="M->D2_TES",M->D2_TES,""),"FC_IMPOSTO")=="IRA"                                                                                               
					nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra .Or. Empty(x[_IdxF36])},2),nE)
				ElseIf Posicione("SFC",2,xFilial("SFC")+cTes,"FC_IMPOSTO")=="IRA"
					nE:=If(_IdxF16 > 0 .And. _IdxF36 > 0  .And. nE > 1 ,Ascan( aLivro,{|x| AllTrim(x[_IdxF16])==cTes .And. AllTrim(x[_IdxF36])==cGrpIra .Or. Empty(x[_IdxF36])},2),nE)					
				Else
					nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)								
				EndIf
			EndIf
		EndIf			
	EndIf
	lOk := .T.

ElseIf cPaisLoc == "EQU"     
	If FunName()$"MATA410|MATA468N"//Pedido de Venda|Geracao de Fatura	
		If Posicione("SFC",1,xFilial("SFC")+AvKey(SC6->C6_TES,"FC_TES"),"FC_IMPOSTO")=="RIR"
			nE	:=	IIf(_IdxF16 > 0 .And. _IdxF36 > 0 ,Ascan( aLivro ,{ |x| Alltrim(x[_IdxF16])+Alltrim(x[_IdxF36]) == Alltrim(SC6->C6_TES)+Alltrim(SC6->C6_CONCEPT) } ,2),nE)
			lOk:=.T.
		Else    
			nE	:=	IIf(_IdxF16 > 0 ,Ascan( aLivro ,{ |x| Alltrim(x[_IdxF16]) == Alltrim(SC6->C6_TES)} ,2),nE)					
			lOk:=.T.
		Endif                
	ElseIf FunName()$"MATA467N|MATA465N|MATA466N"//Fatura de Saida|Nota de Cred.Deb.
		If Posicione("SFC",1,xFilial("SFC")+AvKey(Iif(Inclui,IiF(ReadVar()=="M->D2_TES",M->D2_TES,SF4->F4_CODIGO),SD2->D2_TES),"FC_TES"),"FC_IMPOSTO")=="RIR"
			cConcept:=Iif(ReadVar()=="M->D2_CONCEPT",M->D2_CONCEPT,Iif(INCLUI,aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2]) ==  "D2_CONCEPT"  } )],SD2->D2_CONCEPT))
			If Empty(cConcept)           
				lOk:=.F.
			Else
				nE	:=	IIf(_IdxF16 > 0 .And. _IdxF36 > 0 ,Ascan( aLivro ,{ |x| Alltrim(x[_IdxF16])+Alltrim(x[_IdxF36]) == Alltrim(Iif(Inclui,SF4->F4_CODIGO,SD2->D2_TES))+Alltrim(cConcept) } ,2),nE)
				lOk:=.T.
			Endif
		Else    
			If ReadVar() == "M->D2_CF"
				cCFO	:= M->D2_CF
			ElseIf ReadVar() == "M->C6_CF"
				    cCFO	:= M->C6_CF
			Else
			    If lSC6
				    nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "C6_CF " })
			    Else
				    nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D2_CF " })
			    EndIf
			    cCFO	:= aCols[aItemInfo[8]][nPosCFO]
			EndIf
			nE:= IIf(_IdxF16 >0 .And. nE > 1 ,aScan( aLivro,{|x| x[_IdxF16] == SF4->F4_CODIGO},2),nE)
			lOk:=.T.			
		Endif
	Endif

ElseIf cPaisLoc $ "COL|MEX" .And. lNaoLibFis // Colombia: Quebra sempre por TES + CFO
	lFatPV:= ( FunName()$"MATA461|FINR140|MATA468N") //Pedido de Venda|Geracao de Fat|Flujo Caja
	lSC6 := ( Type("Acols")  <> "U" .And. aScan(aHeader,{|X| AllTrim(X[2])=='C6_CF'}) > 0 ) //Pedido de Venda|Geracao de Fat

	If lFatPV .Or. ( Type("lVisualiza" )=="L" .And. lVisualiza )
		If lFatPV
			cCFO :=	SC6->C6_CF
		Else
			cCFO := SD2->D2_CF
		EndIf
    Else
		If nSinal > 0
			If ReadVar() == "M->D2_TES" .Or. ReadVar() == "M->C6_TES"
				cCFO := SF4->F4_CF
			Else
				If ReadVar() == "M->D2_CF"
					cCFO	:= M->D2_CF 
				ElseIf ReadVar() == "M->C6_CF"
					cCFO	:= M->C6_CF 
				Else
				    If Alltrim(Funname()) == "TMKA271" .And. cPaisLoc == "MEX"
						nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "UB_CF " })
				    ElseIf Alltrim(Funname()) <> "FINR610"  //Informe de comisiones
						If lSC6
							nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "C6_CF " })
						Else
							nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D2_CF " })
						EndIf
					Else
						cCFO	:= Alltrim(MaFisRet(aItemInfo[8],"IT_CF"))	
					EndIf
					If lIsLoja .And. nPosCFO == 0
						If IsInCallStack('LJGRVTRAN') //Finalização da Venda
							cCFO	:= SD2->D2_CF
						ElseIf Len(aItemInfo) > 8 //Lançamento dos items
							cCFO	:= aItemInfo[10]
						EndIf						
					ElseIf Alltrim(Funname()) $ "MATA415|TECA400" .and. MaFisFound()
						cCFO	:= Alltrim(MaFisRet(aItemInfo[8],"IT_CF"))
					ElseIf Type("aCols")<> "U" .and. Len(aCols)>= aItemInfo[8]
						If Len(aItemInfo) > 8
							cCFO	:= aItemInfo[10]
						Else
							cCFO	:= aCols[aItemInfo[8]][nPosCFO]
						EndIf
					EndIf
			    EndIf
			EndIf
		Else  // Estorna sempre usando CFO do aCols
			If lSC6
				nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "C6_CF " })
			ElseIf Alltrim(Funname()) == "TMKA271" .And. cPaisLoc == "MEX"
				nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "UB_CF " })
            Else
				nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D2_CF " })
			EndIf
			
			If lIsLoja .And. nPosCFO == 0
				If IsInCallStack('LJGRVTRAN') //Finalização da Venda
					cCFO	:= SD2->D2_CF
				ElseIf Len(aItemInfo) > 8 //Lançamento dos items
					cCFO	:= aItemInfo[10]
				EndIf
			Else
				cCFO	:= aCols[aItemInfo[8]][nPosCFO]
			EndIf
		EndIf
	EndIf

	nE := IIf(_IdxF16 >0 .And. _IdxF15 >0 .And. nE>1 ,aScan( aLivro,{|x| x[_IdxF16] == SF4->F4_CODIGO .And. x[_IdxF15] == cCFO},2),nE)
	lOk := .T.

Else
	//Quebra por TES, Bruno
	nE	:= IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)
	lOk := .T.

EndIf

If lOk .And. !(cPaisLoc $ "MEX")
	// nE < 2 significa que eh o primeiro ou que o TES escolhido nao existe no ARRAY ou que o Concepto escolhido nao existe no ARRAY
	If nE < 2
		GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataS,IIf(cPaisLoc$"COL|MEX",cCFO,))
	ENDIF
	
	IF (cPaisLoc == "CHI" .And. lPrcDec) .Or. (cPaisLoc == "PAR") .Or. (cPaisLoc == "ARG")
		If lNoActVal
			aLivro[nE,_IdxF01] += aItemInfo[3] + aItemInfo[4] + aItemInfo[5]
		Else
			aLivro[nE,_IdxF01] += (Round(xMoeda( aItemInfo[3] + aItemInfo[4] + aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa ),nDecs) * nSinal	)
		EndIf
	ELSE                                                          
		If !(cPaisLoc $ "PTG|COL")	
			aLivro[nE,_IdxF01] += xMoeda( aItemInfo[3] + aItemInfo[4] + aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa ) * nSinal
		Endif
	ENDIF		
Endif	

If lOk
	If Len(aImpostos) > 0
		lCalcIVA:=.F.
		aImpIVA:={}

		If cPaisLoc=="ARG"
			SFB->(DBGOTOP())
			While SFB->(!EOF())
				If SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"3I"  //IVA
					If ASCAN(aImpIVA,SFB->FB_CODIGO)=0
						AADD(aImpIVA,SFB->FB_CODIGO)
					Endif
				Endif
				SFB->(DBSkip())
			Enddo
			nPosTES := Ascan( aLivro[1],{|x| x == "F3_TES" } )
			DbSelectArea("SFC")
			SFC->(DbsetOrder(1))
			If DbSeek(xFilial("SFC")+  aLivro[nE,nPosTES])
				While xFilial("SFC")== SFC->FC_FILIAL .AND. SFC->FC_TES == aLivro[nE,nPosTES]   .AND. SFC->(!EOF())
					If Ascan( aImpIVA,{|x| x == SFC->FC_IMPOSTO} ) >0
			 			lCalcIVA:=.T.
	            	EndIf
	            	SFC->(DbSkip())
				EndDo
				SFB->(RestArea(aArSFB))
				SFC->(RestArea(aArSFC))
			EndIf
		EndIf

	nPosLibFis := POSICIONE( "SFB", 1, xFilial("SFB")+"IVA", "FB_CPOLVRO" )
	
		FOR nX:=1 TO Len(aImpostos)
	  		nPosBase:= Ascan( aLivro[1],{|x| x == "F3_BASIMP"+aImpostos[nX][17] } )
			nPosAliq:= Ascan( aLivro[1],{|x| x == "F3_ALQIMP"+aImpostos[nX][17] } )
			nPosValr:= Ascan( aLivro[1],{|x| x == "F3_VALIMP"+aImpostos[nX][17] } )
			
			DO CASE
				CASE cPaisLoc == "MEX"
					nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
					IIF( _IdxF15 <> 0, x[_IdxF15] == cCFO, .T. ) .AND. ;
					IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) }, 2 )
				CASE cPaisLoc == "PTG"
					nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
					IIF( _IdxF15 <> 0, x[_IdxF15] == SF4->F4_CF, .T. ) .AND. ;
					IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) }, 2 )
				CASE cPaisLoc == "COL"
				    nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
					IIF( _IdxF15 <> 0, x[_IdxF15] == cCFO, .T. ) .AND. ;
					IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) .AND. ;
					IIF( _IdxF17 <> 0, x[_IdxF17] == aItemInfo[7], .T. ) }, 2 )
			ENDCASE

					IF aImpostos[nX,17] == nPosLibFis  .And. cPaisLoc $ "BOL"
						nPosBasBol := aImpostos[nX,3]	
					ENDIF
			
			IF cPaisLoc $ "MEX|COL|PTG" .AND. (nSinal > 0 .OR. lCancCup)
				If nE == 0
					GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataS,IIf(cPaisLoc$"COL|MEX",cCFO,))  				
				EndIf
			EndIf

			If nE > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de moeda extrangeira, deve-se converter para moeda local³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nPosBase > 0	.and. nPosValr > 0 .and. nPosAliq > 0	.And. nE <>0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³         Tratamento específico para loc?alizado PERU             ³
					//³  Abaixo são efetuados os cálculos do impostoso para comporem   ³
					//³ o livro fiscal												   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If cPaisLoc $ "PER|PAR|MEX"
						alAreaX := SF4->(GetArea())
						alAreaY := SFC->(GetArea())
						nPosTES := Ascan( aLivro[1],{|x| x == "F3_TES" } )
	
						If aImpostos[nX][1] $ "IGV"

							DbSelectArea("SF4")
							DbSetOrder(1)
							If DbSeek(xFilial("SF4") + aLivro[nE,nPosTES])
								If (SF4->F4_CALCIGV <> "2" .And. SF4->F4_CALCIGV <> "3") 
									nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
									aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
									aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
									aLivro[nE,nPosAliq] := aImpostos[nX,2]

									nTotalImp += aLivro[nE,nPosValr]
							
									//+---------------------------------------------------------------------+
									//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
									//+---------------------------------------------------------------------+
							
									IF Substr(aImpostos[nX][5],2,1)=="1"
										aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
									ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
										aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
									ENDIF
								EndIf
							EndIf

						ElseIf aImpostos[nX][1] $ "PIV" 
					
							If cTipoMov $ "V"
					
								DbSelectArea("SA1")
								DbSetOrder(1)	
								If DbSeek(xFilial("SA1")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
			
									If SA1->A1_AGENTE == "2"
										nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
								
										nTotalImp += aLivro[nE,nPosValr]
								
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
								
										IF Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
										ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
										ENDIF						
									EndIf                 
						
								EndIf 
							
							ElseIf cTipoMov $ "C"

								DbSelectArea("SA2")
								DbSetOrder(1)	
								If DbSeek(xFilial("SA2")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
									If SubStr(cMV_AGENTE,2,1) == "S" .And.  SA2->A2_AGENRET <> "1"							
										nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
								
										nTotalImp += aLivro[nE,nPosValr]
								
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
								
										IF Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
										ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
										ENDIF						
									EndIf                 
						
								EndIf 
						
							EndIf
						
						ElseIf aImpostos[nX][1] $ "DIG"
					
							If cTipoMov $ "V"
					
								DbSelectArea("SA1")
								DbSetOrder(1)	
								If DbSeek(xFilial("SA1")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
			
									If SubStr(cMV_AGENTE,1,1) == "N" .And.  SA1->A1_AGENTE == "3" 
										nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
								
										nTotalImp += aLivro[nE,nPosValr]
								
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
								
										IF Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
										ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
										ENDIF						
									EndIf                 
						
								EndIf
						
							ElseIf cTipoMov $ "C"
						         
								DbSelectArea("SA2")
								DbSetOrder(1)	
								If DbSeek(xFilial("SA2")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
									If SubStr(cMV_AGENTE,3,1) == "S" .And.  SA2->A2_AGENRET <> "1" 						
										nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
								
										nTotalImp += aLivro[nE,nPosValr]
								
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
								
										IF Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
										ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
										ENDIF						
									EndIf                 
						
								EndIf					
						
							EndIf
						
						Else
							nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
							aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
							aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
							aLivro[nE,nPosAliq] := aImpostos[nX,2]
					
							nTotalImp += aLivro[nE,nPosValr]
					
							//+---------------------------------------------------------------------+
							//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
							//+---------------------------------------------------------------------+
					
							IF Substr(aImpostos[nX][5],2,1)=="1"
								aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
							ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
								aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
							ENDIF

						EndIf					

						RestArea(alAreaX)
						RestArea(alAreaY)				

					// Colombia
					ElseIf cPaisLoc $ "COL"
						alAreaX := SF4->(GetArea())
						alAreaY := SFC->(GetArea())
						nPosTES := Ascan( aLivro[1],{|x| x == "F3_TES" } )
				
						If aImpostos[nX][1] $ "IVA"
							DbSelectArea("SF4")
							DbSetOrder(1)
							If DbSeek(xFilial("SF4") + aLivro[nE,nPosTES])
								If SF4->F4_CALCIVA <> "3" 
									nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
									aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
									aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
									aLivro[nE,nPosAliq] := aImpostos[nX,2]
							
									nTotalImp += aLivro[nE,nPosValr]
							
									//+---------------------------------------------------------------------+
									//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
									//+---------------------------------------------------------------------+
							
									IF Substr(aImpostos[nX][5],2,1)=="1"
										aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
									ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
										aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
									ENDIF
								EndIf
							EndIf

						Else
							nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
							aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
							aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
							aLivro[nE,nPosAliq] := aImpostos[nX,2]
					
							nTotalImp += aLivro[nE,nPosValr]
					
							//+---------------------------------------------------------------------+
							//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
							//+---------------------------------------------------------------------+
					
							IF Substr(aImpostos[nX][5],2,1)=="1"
								aLivro[nE,_IdxF01] += nMoedaValor * nSinal		
							ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
								aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
							ENDIF
						EndIf
					
						RestArea(alAreaX)
						RestArea(alAreaY)

					Else
						If cPaisLoc == 'ARG'
							If lNoActVal
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (aImpostos[nX,3] *nSinal)
								nMoedaValor := aImpostos[nX,4]
							Else
								nValBase	:= Round(xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)
								if (Type("lInclui" )=="L" .And. !lInclui)
									nMoedaValor := Iif(nMoedaAux != 1,xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa), aImpostos[nX,4])
								else
									nMoedaValor := Iif(nMoedaAux != 1,IIf(aImpostos[nX,4]>0,(nValBase * (aImpostos[nX,2]/100)),0), xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa))
								endif
								nMoedaValor := Round(nMoedaValor, nDecs) 
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (nValBase *nSinal)
							EndIf
							aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)
						Else
							nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
							IF (cPaisLoc == "CHI" .And. lPrcDec) .Or. (cPaisloc == "PAR")
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,(Round(aLivro[nE,nPosBase]  + xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)*nSinal))
								aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,Round( aLivro[nE,nPosValr]+(nMoedaValor * nSinal),nDecs) )
							ELSE
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
								aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)			
							ENDIF
						EndIf			

						aLivro[nE,nPosAliq] := aImpostos[nX,2]

						nTotalImp += aLivro[nE,nPosValr]
					
						If cPaisloc == "COS"
							nTotalBase += aLivro[nE,nPosBase] 
						Endif
			
						//+---------------------------------------------------------------------+
						//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
						//+---------------------------------------------------------------------+
			 
						IF Substr(aImpostos[nX][5],2,1)=="1"
							IF (cPaisLoc == "CHI" .And. lPrcDec) .Or. (cPaisLoc == "PAR")
								aLivro[nE,_IdxF01] += Round(nMoedaValor,nDecs+2) * nSinal
							ELSE
								If aLivro[nE,_IdxF01] == 0
									If (cPaisLoc == "ARG")
										If lNoActVal
											aLivro[nE,_IdxF01] := aImpostos[nX,3]
										Else	
											aLivro[nE,_IdxF01] := Round(xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)
										EndIf
									Else
										aLivro[nE,_IdxF01] := xMoeda(aImpostos[nX,3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)
									EndIf						
								Endif
								aLivro[nE,_IdxF01] += nMoedaValor * nSinal
							ENDIF
						ELSEIF Substr(aImpostos[nX][5],2,1)=="2"
							aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
						ENDIF
					Endif	 
				Endif
			Endif

		    If cPaisLoc=='URU'
				SFC->(dbSetOrder(1))
				SFC->(dbGoTop())			
				If SFC->(dbSeek(xFilial('SFC')+ SF4->F4_CODIGO ))
					nConcep:=1
					While SFC->(!EOF()) .And. SFC->FC_TES == SF4->F4_CODIGO .And. nConcep <= Len(aImpostos)  
						dbSelectArea('SFF')
				  		SFF->(dbSetOrder(6))
						If SFF->(dbSeek(xFilial('SFF')+ Avkey(SFC->FC_IMPOSTO,'FF_IMPOSTO')+AvKey(SF4->F4_CF,'FF_CFO_V')))
							nPosConcep:= Ascan( aLivro[1],{|x| x == "F3_CONCEP"+aImpostos[nConcep][17] } )
							If nPosConcep > 0
								aLivro[nE,nPosConcep]:=SFF->FF_CONCIRP
							EndIf		
						EndIf
						SFC->(dbSkip())
						nConcep++
					End
				EndIf 
			EndIf	
		NEXT nX

	ElseIf cPaisLoc $ "MEX|COL|PTG"  //Tratamento quando nao ha impostos
		nE := Ascan( aLivro, { |x| IIF( _IdxF15 <> 0, x[_IdxF15] == IIf(cPaisLoc $ "COL|MEX", cCFO, SF4->F4_CF), .T. ) .AND. ;
		IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) .AND. ;
		IIf( cPaisLoc == "COL", (IIF( _IdxF17 <> 0, x[_IdxF17] == aItemInfo[7], .T. )) ,.T.) }, 2 )
		If nE == 0 .And. nSinal > 0
			GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataS,IIf(cPaisLoc $ "COL|MEX",cCFO,))
		EndIf

	EndIf
	
	If (cPaisLoc $ "URU" .And. _IdxF32 > 0 .and. SF4->(FieldPos('F4_CALCIVA')) > 0)
		If SF4->F4_CALCIVA == "3"
			lExcento := .T.
		Endif
	Endif

	If nE>0
		IF nTotalImp == 0  .AND. _IdxF32 > 0  .Or. lExcento .Or. (cPaisLoc $ "BOL" .And. _IdxF32 > 0)  // Exentas
			IF (cPaisLoc=="CHI")  .Or. (cPaisLoc == "PAR") .Or. (cPaisLoc == "ARG")
				If lNoActVal
					aLivro[nE,_IdxF32] += aItemInfo[3]+aItemInfo[4]+aItemInfo[5]
				Else
					aLivro[nE,_IdxF32] += (Round(xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)*nSinal)
				EndIf
			ELSEIF cPaisLoc $ "COL"
				If SF4->F4_CALCIVA <> "2"    
				aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
				EndIF
			ElseIF cPaisLoc == "VEN"
				If SF4->F4_CALCIVA == "3"
					aLivro[nE,_IdxF32] := aItemInfo[3]
				EndIF		
		   	ElseIf cPaisloc == "COS" 
				If nTotalBase > 0                                      
					aLivro[nE,_IdxF32] += 0				
				Else
		 			aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
		  		Endif
			ElseIf cPaisloc == "BOL" .And. nPosBasBol > 0 
					aLivro[nE,_IdxF32]+= aItemInfo[3]-nPosBasBol		
			ELSE		
				aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
			ENDIF
		ENDIF
		
		IF _IdxF33 > 0 // Frete
			IF (cPaisLoc == "CHI") .Or. (cPaisLoc == "PAR")
				aLivro[nE,_IdxF33] += (Round(xMoeda(aitemInfo[4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)*nSinal)
			ELSE
				If lNoActVal
					aLivro[nE,_IdxF33] += aitemInfo[4]
				Else
					aLivro[nE,_IdxF33] += (xMoeda(aitemInfo[4],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
				EndIf
			ENDIF
		ENDIF
		
		IF _IdxF34 > 0 // ValMerc
			IF (cPaisLoc == "CHI"  .And. lPrcDec) .Or. (cPaisLoc == "PAR") .Or. (cPaisLoc == "ARG")
				If lNoActVal
					aLivro[nE,_IdxF34] += aitemInfo[3]
				Else
					aLivro[nE,_IdxF34] += (Round(xMoeda(aitemInfo[3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa),nDecs)*nSinal)
				EndIf
			ELSE
				aLivro[nE,_IdxF34] += (xMoeda(aitemInfo[3],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
			ENDIF
		ENDIF
		
		IF cPaisLoc $ "COL MEX" .AND. Len(aLivro)>1
			aLivro[nE,_IdxF01] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF2->F2_EMISSAO,nDecs+1,nTaxa)*nSinal)
		ENDIF
	EndIf
	
	IF nSinal<0 .AND. nE>1
		IF aLivro[nE,_IdxF01]<=0 
			aItDel[nE-1]:=.T. 		
		ENDIF
	ENDIF
	
	IF nSinal<0
		nY:=Len(aItDel)
		nX:=Len(aLivro)
		IF nY>0
			FOR nZ := nY TO 1 STEP -1                  
				IF aItDel[nZ]
					aLivro := Adel(aLivro,nZ+1)
					nX--
				ENDIF
			Next nZ
			aLivro:=ASize(aLivro,nX)
		ENDIF
	ENDIF

	RestArea( aArea )
	
	If lUltimoItem .And. cPaisLoc=="CHI" .And. !lPrcDec
		aLivro[nE,_IdxF01]  := Round(aLivro[nE,_IdxF01],nDecs)
		aLivro[nE,_IdxF34]  := Round(aLivro[nE,_IdxF34],nDecs)
		If Len(aImpostos) > 0                                              
			FOR nX:=1 TO Len(aImpostos)
				If aImpostos[nX,3] <> 0.00    
					nPosBase:= Ascan( aLivro[1],{|x| x == "F3_BASIMP"+aImpostos[nX][17] } )
					nPosValr:= Ascan( aLivro[1],{|x| x == "F3_VALIMP"+aImpostos[nX][17] } )
					aLivro[nE,nPosBase] := Round(aLivro[nE,nPosBase],nDecs)
					aLivro[nE,nPosValr] := Round(aLivro[nE,nPosValr],nDecs)
				EndIf
			Next nX
		EndIf
	EndIf	
Endif	

Return( aLivro )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraLivr ³ Autor ³ Fernando Machima      ³ Data ³ 09/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados no array aLivro                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA467, MATA468, MATA466, MATA465                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function GeraLivr(aLivro,cTipoMov,aItemInfo,dDtEmis,cCFO)	

Local nY
Local lNotaManual := IIf(Type("lNFManual")#"U",lNFManual,.F.)
Local dDataDig	  := dDataBase
Local nPosParAux	:=0

DEFAULT dDtEmis := dDataBase
DEFAULT cCFO	:= SF4->F4_CF

nE := Len(aLivro)+1
AAdd(aLivro,Array(Len(aLivro[1])))
FOR nY := 1 TO Len( aLivro[1] )
	aLivro[nE, nY] := Criavar( aLivro[1, nY] )
NEXT nY

aLivro[nE,_IdxF01] := 0.00
IIf (_IdxF02 > 0, aLivro[nE,_IdxF02] := cNrLivro, .T.)
aLivro[nE,_IdxF03] := cFormula
                              
If Type("lVisualiza" )=="L" .And. lVisualiza 
	If SF4->F4_CODIGO>"500"
		If SF2->(FieldPos('F2_DTDIGIT')) > 0
			dDataDig:=SF2->F2_DTDIGIT
		EndIf
		dDtEmis:=SF2->F2_EMISSAO
	Else     
		If SF1->(FieldPos('F1_DTDIGIT')) > 0
			dDataDig:=SF1->F1_DTDIGIT
		EndIf
		dDtEmis:=SF1->F1_EMISSAO      
	EndIf	
EndIf

aLivro[nE,_IdxF04] := dDataDig
aLivro[nE,_IdxF05] := cNumero
If MaFisFound()
	aLivro[nE,_IdxF06] := MaFisRet(,"NF_SERIENF")
	If Empty(aLivro[nE,_IdxF06])
		aLivro[nE,_IdxF06] := cSerie
	EndIf		
Else
	aLivro[nE,_IdxF06] := cSerie
EndIf 
aLivro[nE,_IdxF07] := IIf(cModulo$"COM|EST",SA2->A2_COD,SA1->A1_COD)
aLivro[nE,_IdxF08] := IIf(cModulo$"COM|EST",SA2->A2_LOJA,SA1->A1_LOJA)
aLivro[nE,_IdxF09] := IIf(cModulo$"COM|EST",SA2->A2_EST,SA1->A1_EST)
aLivro[nE,_IdxF10] := dDtEmis
aLivro[nE,_IdxF11] := cEspecie
aLivro[nE,_IdxF12] := cTipoMov

IF (cPaisloc== "PAR") .and. (AllTrim(cEspecie)=="NCP") .and. (ALLTRIM(FunName()) == "MATA466N" .OR. IsBlind()) 
		
		nPosParAux := Ascan(aLivro[1],{ |x| UPPER(x) == AllTrim("F3_DOCEL") } )
		IF nPosParAux<>0 .and. SF2->(FieldPos("F2_DOCEL"))>0
			aLivro[nE][nPosParAux]:=SF2->F2_DOCEL
		ENDIF
ENDIF
IF _IdxF13 > 0 .AND. cPaisLoc == "PER"
	/*Tratamento especifico do Peru:
	Cod.  Tipo de documento
	01 - Faturas(Pessoa Juridica, possui CNPJ)
	03 - Boleta de Venda(Pessoa Fisica, nao possui CNPJ)
	07 - Nota de Credito
	08 - Nota de Debito
	
	Obs: Os codigos sao fixos
	*/
	If AllTrim(cEspecie) $ "NF|NDC|NCP"
		If SF2->(ColumnPos("F2_TPDOC")) > 0
			aLivro[nE,_IdxF13] := SF2->F2_TPDOC
		Else
			aLivro[nE,_IdxF13] := Space(TamSx3("F3_TPDOC")[1])
		EndIf
	Else
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                        
		If SA1->(DbSeek(xFilial("SA1")+aLivro[nE,_IdxF07]+aLivro[nE,_IdxF08]))
			If Alltrim(cEspecie) $ "FT"
				If Empty(SA1->A1_CGC)
					aLivro[nE,_IdxF13] := "03"
				Else
					aLivro[nE,_IdxF13] := "01"
				Endif
			Else
				aLivro[nE,_IdxF13] := "08"
			EndIf
		Endif
	EndIf
Endif
IIf (_IdxF14 > 0, aLivro[nE,_IdxF14]:= cTipo, .T.)
If cPaisLoc $ "ARG"
	If Upper(Substr(FunName(),1,4)) == "LOJA"
		IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= cCFO, .T.)
    Else
		if Len(aItemInfo) > 7      
  			IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= aItemInfo[8], .T.)
  		EndIf
  	EndIf
Else         
	If FunName()$"MATA465N|MATA467N|MATA468N|MATA461|MATA460B|MATA466N" .or. Upper(Substr(FunName(),1,4)) == "LOJA" .Or. !MaFisFound()
		IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= cCFO, .T.)        
	Else
		IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= MaFisRet(,"IT_CF"), .T.)    
	EndIf
EndIf



If cPaisLoc=="URU" .and. Type("Inclui") <> "U"
	IIf (_IdxF16 > 0, aLivro[nE,_IdxF16]:= Alltrim(Iif(Inclui,Iif(ReadVar()=="M->D2_TES",M->D2_TES,SF4->F4_CODIGO),SD2->D2_TES)), .T.)
ElseIf cPaisLoc=="EQU"
	IIf (_IdxF16 > 0, aLivro[nE,_IdxF16]:= Alltrim(Iif(Inclui,Iif(ReadVar()=="M->D2_TES",M->D2_TES,SF4->F4_CODIGO),SD2->D2_TES)), .T.)
Else
	IIf (_IdxF16 > 0, aLivro[nE,_IdxF16]:= SF4->F4_CODIGO, .T.)
Endif
IIf (cPaisLoc == "COL" .And. _IdxF17 > 0  , aLivro[nE,_IdxF17] := aItemInfo[7],.T.)
IIf (cPaisLoc == "GUA" .And. _IdxF35 > 0  , aLivro[nE,_IdxF35] := IIf(lNotaManual,"S","N"), Nil)   
IIf (cPaisLoc == "VEN" .and. _IdxF36 > 0 , aLivro[nE,_IdxF36] := SF4->F4_TPALIQ, Nil)
If FunName()=="MATA410"     
	IIf (cPaisLoc == "EQU" .And. _IdxF36 > 0 , aLivro[nE,_IdxF36] := Iif(ReadVar()=="M->C6_CONCEPT",M->C6_CONCEPT,Iif(INCLUI,aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2]) =="C6_CONCEPT"  } )],SC6->C6_CONCEPT)), .T.)   
ElseIf FunName()$"MATA468N"		
	IIf (cPaisLoc == "EQU" .And. _IdxF36 > 0 , aLivro[nE,_IdxF36] := SC6->C6_CONCEPT, .T.)   
Else
	IIf (cPaisLoc == "EQU" .And. _IdxF36 > 0 , aLivro[nE,_IdxF36] := Iif(ReadVar()=="M->D2_CONCEPT",M->D2_CONCEPT,Iif(INCLUI,aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2]) =="D2_CONCEPT"  } )],SD2->D2_CONCEPT)), .T.)   
Endif
If cPaisLoc == "URU"
	If Posicione("SFC",2,xFilial("SFC")+AvKey(aLivro[nE,_IdxF16],"FC_TES"),"FC_IMPOSTO")=="IRA"
		If FunName()=="MATA468N"
			aLivro[nE,_IdxF36] := Posicione('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO,'B1_GRPIRAE')
		
		ElseIf FunName()=="MATA410"     
				IIf (_IdxF36 > 0.And. cPaisLoc == "URU", aLivro[nE,_IdxF36] := AllTrim(Posicione('SB1',1,xFilial('SB1')+Iif(ReadVar()=="M->C6_PRODUTO",M->C6_PRODUTO,Iif(INCLUI,aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2]) ==  "C6_PRODUTO"  } )],SC6->C6_PRODUTO)),'B1_GRPIRAE')), .T.)   
		Else	
			If _IdxF36 > 0 .And. ReadVar()=="M->D2_COD" .And. LEN(ACOLS)== aItemInfo[8]
				aLivro[nE,_IdxF36] := AllTrim(Posicione('SB1',1,xFilial('SB1')+If(ReadVar()=="M->D2_COD".And. LEN(ACOLS)== aItemInfo[8],M->D2_COD,aCols[aItemInfo[8]][aScan(aHeader,{|X| AllTrim(X[2])=='D2_COD'})]),'B1_GRPIRAE'))
			ElseIf _IdxF36 > 0 .And.  !Empty(aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2]) ==  "D2_COD"  } )])                                
				aLivro[nE,_IdxF36]:=Posicione('SB1',1,xFilial('SB1')+aCols[aItemInfo[8]][Ascan(aHeader,{|x| Alltrim(x[2])=="D2_COD"})],'B1_GRPIRAE')				
			ElseIf _IdxF36 > 0 .And. LEN(ACOLS)== aItemInfo[8] .And. !Empty(SD2->D2_COD)
				aLivro[nE,_IdxF36] :=Posicione('SB1',1,xFilial('SB1')+SD2->D2_COD,'B1_GRPIRAE') 
			ElseIf _IdxF36 > 0 .And. LEN(ACOLS)== aItemInfo[8] .And. Select("SC6")>0 .And.!Empty(SC6->C6_PRODUTO)
				aLivro[nE,_IdxF36] :=Posicione('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO,'B1_GRPIRAE')  
			Endif                 
		Endif	
	Else
		If _IdxF36 > 0
			aLivro[nE,_IdxF36]	:=""
		EndIf
	Endif	             
EndIf

Return Nil

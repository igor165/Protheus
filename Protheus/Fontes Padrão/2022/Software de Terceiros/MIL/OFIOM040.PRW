// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 09     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "ofiom040.ch"
#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM040 ³ Autor ³  Renata               ³ Data ³ 11/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Escala de Produtivo                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina   (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOM040
Local aCores    := {{ 'VAI->VAI_FUNPRO == "1"','BR_VERDE' },;  //Produtivo
{'VAI->VAI_FUNPRO # "1"','BR_VERMELHO'}} //Nao Produtivo
PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0005) //"Escala de Produtivo"

DbSelectArea("VAI")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

mBrowse( 6, 1,22,75,"VAI",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OF040     ³ Autor ³Renata                 ³ Data ³ 06/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza, inclui e altera dadoas do VAI/VOE               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ OF040(CALIAS,NREG,NOPC)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFICINA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF040(cAlias,nReg,nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }
Local nOpcE := 2
Local nOpcG := nOpc
Local cChave
Local nCntFor := 0
Local _ni := 0
Local i := 0
Local i1 := 0

Private cCodPro := ""
Private cDataDe	:= DaySum(dDataBase,1)
Private cDataAte:= DaySum(dDataBase,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nOPC == 5
	OFIOM270(VAI->VAI_CODTEC)
	return .t.
endif

If VAI->VAI_FUNPRO != "1"
	Help("  ",1,"APEFUNPRO")
	DbSelectArea("VAI")
	DbSetOrder(1)
	Return .t.
EndIf

RegToMemory("VAI",.T.)
DbSelectArea("VAI")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

if nOpc == 3         //Inclui
	nOpcE := 2
	nOpcG := 3
elseif nOpc == 4     //Altera
	nOpcE := 2
	nOpcG := 4
elseif nOpc == 2     //Visualiza
	nOpcE := 2
	nOpcG := 2
else                //Exclui
	nOpcE := 2
	nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")  
dbSetOrder(1)
dbSeek("VOE")
aHeader:={}

While !Eof().And.(x3_arquivo=="VOE")
	if !X3_CAMPO $ [VOE_CODPRO/VOE_NOMPRO]
		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado:=nUsado+1
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Endif
	Endif
	dbSkip()
End

nNroReg := 0

dbSelectArea("VOE")
dbSetOrder(1)
dbSeek(xFilial()+M->VAI_CODTEC)

cCodPro := VOE->VOE_CODPRO

If Inclui .and. !(found())
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	aColA:={}
	While !eof() .and. VOE->VOE_CODPRO == M->VAI_CODTEC
		AADD(aCols,Array(nUsado+1))
		AADD(aColA,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			aColA[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		aColA[Len(aCols),nUsado+1]:=.F.
		nNroReg++
		dbSkip()
	End
Endif

If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0005 //"Escala de Produtivo"
	cAliasEnchoice:="VAI"
	cAliasGetD    :="VOE"
	cLinOk        :="OM040LINOK()"
	cTudOk        :="AllwaysTrue()"
	cFieldOk      :="FG_MEMVAR()"
	aCpoEnchoice  :={}

	aButtons := {}

	if nOpc == 4
		aAdd(aButtons, {"SALVAR",    {|| OM0400015_DeletaEscalaPeriodo() } , STR0012 }) // "Deletar escala por periodo"
	EndIf
	
	dbSelectArea("SX3")
	dbSeek("VAI")
	
	While !Eof().and.(x3_arquivo=="VAI")
		If !(x3_campo $ "VAI_FILIAL/VAI_REGIAO")
			if X3USO(x3_usado).and.cNivel>=x3_nivel
				AADD(aCpoEnchoice,x3_campo)
			Endif
		Endif
		dbSkip()
	End
	
	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,.F.,2000,,,aButtons)
	
	if _lRet .and. nOpc # 2

		asort(acols,,, { |x, y| x[FG_POSVAR("VOE_DATESC")] < y[FG_POSVAR("VOE_DATESC")] })
		
		for i:=1 to len(aCols)
			
			wReturn:=.T.   //Nao gravar acols com cpo obrigatorio em branco
			
			for i1:=1 to len(aHeader)
				if empty(aCols[i,i1]) .and. aHeader[i1,2] <> "VOE_FILPRO"
					wReturn:=.F.
					exit
				Else
					wReturn:=.T.
				Endif
			Next
			
			If wReturn == .F.
				Loop
			Endif
			
			dbselectArea("VOE") 
			dbSetOrder(1)
			
			cChave:= xFilial("VOE")+M->VAI_CODTEC+dtos(aCols[I,FG_POSVAR("VOE_DATESC")])
			
			wprocura := dbseek(cChave)
			
			if Inclui .or. Altera
				
				If aCols[i,len(aCols[i])] .And. Altera .and. WPROCURA
					RecLock("VOE",.F.,.T.)
					dbdelete()
					MsUnlock()
					WriteSx2("VOE")
					
				ElseIf !(aCols[i,len(aCols[i])])
					
					RecLock("VOE",If(WPROCURA,.F.,.T.))
					FG_GRAVAR("VOE",aCols,aHeader,i)
					VOE->VOE_FILIAL := xFilial("VOE")
					VOE->VOE_CODPRO := M->VAI_CODTEC
					MsUnlock()
					
					dbSelectArea("VAI")
					dbSetOrder(1)
					dbSeek(xFilial()+M->VAI_CODTEC)
					
					If empty(dtos(VAI->VAI_DATUES))
						If i = 1
							RecLock("VAI",.F.)
							VAI->VAI_FILIAL := xFilial("VAI")
							VAI->VAI_DULTES := VAI->VAI_DATUES
							VAI->VAI_CULTES := VAI->VAI_CATUES
							VAI->VAI_DATUES := aCols[i,FG_POSVAR("VOE_DATESC")]
							VAI->VAI_CATUES := aCols[i,FG_POSVAR("VOE_CODPER")]
							MsUnlock()
						Endif
					Endif
					
				Endif
				
			else
				
				RecLock("VOE",.F.,.T.)
				dbdelete()
				MsUnlock()
				WriteSx2("VOE")
				
			endif
			
		next
		
	EndIf
	
Else
	
	Help("  ",1,"ARQVAZIO")
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM040LINOK³ Autor ³Valdir F. Silva        ³ Data ³ 01/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se a linha esta ok											  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM040LINOK()
Local lVOH_MSBLQL := VOH->(FieldPos("VOH_MSBLQL")) > 0

If Len(aCols) == 1
	If !aCols[n,Len(aCols[1])]
		If (!Empty(aCols[n,FG_POSVAR("VOE_DATESC")]) .and. Empty(aCols[n,FG_POSVAR("VOE_CODPER")])) .OR.;
			(Empty(aCols[n,FG_POSVAR("VOE_DATESC")]) .and. !Empty(aCols[n,FG_POSVAR("VOE_CODPER")]))
			Help(" ",1,"OBRIGAT")
			Return .f.
		EndIf
	EndIf
Else
	If !aCols[n,Len(aCols[1])]
		If Empty(aCols[n,FG_POSVAR("VOE_DATESC")]) .or. Empty(aCols[n,FG_POSVAR("VOE_CODPER")])
			Help(" ",1,"OBRIGAT")
			Return .f.
		EndIf
	EndIf
EndIf

If !Empty(VAI->VAI_DATDEM) .and. aCols[n,FG_POSVAR("VOE_DATESC")] > VAI->VAI_DATDEM
	MsgInfo(STR0011+DtoC(VAI->VAI_DATDEM))
	Return .f.
EndIf

// Período Bloqueado
If !aCols[n,Len(aCols[1])] .And. lVOH_MSBLQL
	If OFA0800016_PeriodoBloqueado(aCols[n,FG_POSVAR("VOE_CODPER")])
		Return .f. // A mensagem já é exibida dentro da função OFA0800016_PeriodoBloqueado()
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM040LEG   ³ Autor ³ Valdir F. Silva      ³ Data ³ 02/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma janela contendo a legenda da mBrowse               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OM040LEG                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM040LEG()
Local aLegenda := { {"BR_VERDE",STR0007},{"BR_VERMELHO",STR0008}} //Produtivo # Nao Produtivo

BrwLegenda(cCadastro,STR0010 ,aLegenda) //Legenda

Return .T.

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesq", 0 , 1},; 			//Pesquisar
{ STR0002 ,"OF040", 0 , 2},;  		//Visualizar
{ STR0003 ,"OF040", 0 , 3},;  		//Incluir
{ STR0004 ,"OF040", 0 , 4},;			//Alterar
{STR0009,"OF040",0,5},;        		//Automatica
{STR0010,"OM040LEG", 0, 2,0,.f.}} //Legenda
Return aRotina


/*/
{Protheus.doc} OM0400015_DeletaEscalaPeriodo

@author Renato Vinicius
@since 05/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OM0400015_DeletaEscalaPeriodo()

	Local aParamBox := {}
	Local aRet		:= {}
	Local cString	:= ""
	Local i := 0

	aAdd(aParamBox,{1,STR0013,cDataDe ,"@D","MV_PAR01 > dDataBase","","",50,.f.}) //"Data de"
	aAdd(aParamBox,{1,STR0014,cDataAte,"@D","MV_PAR02 >= MV_PAR01","","",50,.f.}) //"Data até"

	If ParamBox(aParamBox,STR0015,@aRet,,,,,,,,.F.,.F.) //"Deleção de escala por periodo"

		cDataDe  := aRet[1]
		cDataAte := aRet[2]

		If MsgNoYes(STR0016)//"Confirma deleção da escala do periodo informado?"

			for i:=1 to len(aCols)

				If DtoS(aCols[i,FG_POSVAR("VOE_DATESC")]) >= DtoS(aRet[1]) .and.;
					DtoS(aCols[i,FG_POSVAR("VOE_DATESC")]) <= DtoS(aRet[2])
					aCols[i,Len(aCols[i])]:= .T.
				EndIf

			Next

		Endif
	EndIf

Return
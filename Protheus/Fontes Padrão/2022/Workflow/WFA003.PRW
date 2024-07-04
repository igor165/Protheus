#INCLUDE "Wfa003.ch"
#include "SIGAWF.ch"
#include "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WFA003  ³ Autor ³ Marcelo Abe           ³ Data ³ 30.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Agendamento de tarefas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void WFA003(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC oWF

Function WFA003()
	Local oSXMTable
	Local cIndex, cKey, cCond
	LOCAL aFixe := {}
	
	PRIVATE aRotina := MenuDef()

	PRIVATE cCadastro := STR0006 //"Agendamento de Operações"
	oWF := TWFObj()

	oSXMTable := oWF:oScheduler:oSXMTable

	if !oSXMTable:lIsOpen()
		if !oSXMTable:lOpen()
			oWF:Free()
			return
		end
	end

	dbSelectArea("SXM")

	aFixe := {{STR0008,"XM_CODIGO","C",10,0,"@!"},;
	          {STR0009,"XM_NOME","C",40,0,"@!"},;
   	       {STR0010,"XM_DESCR","C",40,0,"@!"},;
      	    {STR0031,"XM_ACAO","C",100,0,"@!"},;
         	 {STR0034,"XM_DTPROX","D",8,0,"@D"},;
	          {STR0035,"XM_HRPROX","D",8,0,"99:99"}}
          
	dbSelectArea( "SXM" )

	cIndex := CriaTrab( nil,.f. )
	cKey := "XM_FILIAL+XM_ATIVO+DTOS(XM_DTPROX)+XM_HRPROX"
	cCond := "XM_TIMEOUT <> 'T'"

	IndRegua( "SXM", cIndex, cKey,, cCond, STR0039 )
	DbSetIndex( cIndex + OrdBagExt() )
	
	oSXMTable:_First()
	mBrowse( 6, 1,22,75,"SXM",aFixe)
	oSXMTable:lClose()
Return .T.

STATIC Function MenuDef()
	local aMenuDef := {}
	AAdd( aMenuDef, { STR0002, "WFA003Sch", 0, 2 } ) //"Visualizar"
	AAdd( aMenuDef, { STR0003, "WFA003Sch", 0, 3 } ) //"Incluir"
	AAdd( aMenuDef, { STR0004, "WFA003Sch", 0, 4 } ) //"Alterar"
	AAdd( aMenuDef, { STR0005, "WFA003Sch", 0, 5, 3} ) //"Excluir"
	AAdd( aMenuDef, { STR0040, "WFA003Exe", 0, 6 } ) //"Executar"
return aMenuDef

procedure WFA003Exe()
	local op
	op := Aviso( STR0041, AllTrim( XM_DESCR ), { STR0042, STR0043 }, 1, STR0044 ) //"Executar Tarefa"###"Sim"###"Nao"###"Deseja executar a tarefa: "
	if op == 1
		oWF:oScheduler:ExecTask()
	end
return

//Função Genérica
Function WFA003Sch(cAlias,nReg,nOpcx)
	Local oOk := LoadBitmap( GetResources(), "LBOK" )
	Local oNo := LoadBitmap( GetResources(), "LBNO" )
	Local lInclui := .f.,lAltera := .f.,lVisual := .f.,lDeleta := .f.
	Local nC, nRecNo
	
Private oDlg,oCod,oNome,oDescr,oTipo,oDTIni,oHrIni,oDTFim,oHrFim
Private oInterval,oXM_ENV, oDias, oMensal, oAcao, oAtivo
Private cCodigo := Space(12), cNome := Space(30), cDescr := Space(255)
Private nTipo := 1, dDataIni := MsDate(), cXM_ENV := Space(30), dDataFim := MsDate() 
Private cHrIni := "00:00", cHrFim := "23:59", cInterval := "00:00"
Private aDias:={}, aMensal:={}, cAcao := Space(100), cAtivo := "T", cTimeOut := "F"

	Do Case
    	Case aRotina[nOpcx][4] == 2
		  lVisual := .T.	
	    Case aRotina[nOpcx][4] == 3
		  lInclui	:= .T.	
   	    Case aRotina[nOpcx][4] == 4
          lAltera	:= .T.
  	    Case aRotina[nOpcx][4] == 5
		  lDeleta	:= .T.
		  lVisual	:= .T.
	EndCase

  DEFINE MSDIALOG oDlg TITLE STR0007 From 9,0 To 30,62  //"Agendamento"
  
  @ 0.5, 0.9  SAY STR0008 of oDlg   //"Código"
  @ 1.1, 0.9  MSGET oCod VAR cCodigo Picture "@!"  SIZE 30,10 OF oDlg 

  @ 0.5, 5  SAY STR0009 of oDlg   //"Nome"
  @ 1.1, 5  MSGET oNome VAR cNome SIZE 50,10 OF oDlg 

  @ 0.5, 12  SAY STR0010 of oDlg   //"Descrição"
  @ 1.1, 12  MSGET oDescr VAR cDescr SIZE 140,10 OF oDlg 

  @ 31,7 TO 75,70 PROMPT STR0011 PIXEL OF oDlg   //"Tipo"
  @ 38,8 Radio oTipo VAR nTipo ITEMS STR0012,STR0013,STR0014 3D SIZE 50,10 ON CHANGE (ChangeTipo(nTipo,oDias,oMensal)) PIXEL OF oDlg  //"Diário"###"Semanal"###"Mensal"
  
  @ 2.5, 10  SAY STR0015 of oDlg   //"Data Início"
  @ 3.1, 10  MSGET oDtIni VAR dDataIni SIZE 35,9 Picture "@D"  OF oDlg 
  @ 4.3, 10  SAY STR0016 of oDlg   //"Hora Início"
  @ 4.9, 10  MSGET oHrIni VAR cHrIni SIZE 35,9 Picture "99:99" VALID ValidaHora(cHrIni)  OF oDlg 
  
  @ 2.5, 15  SAY STR0017 of oDlg   //"Data Final"
  @ 3.1, 15  MSGET oDtFim VAR dDataFim SIZE 35,9 Picture "@D" OF oDlg 
  @ 4.3, 15  SAY STR0018 of oDlg   //"Hora Final"
  @ 4.9, 15  MSGET oHrFim VAR cHrFim SIZE 35,9 Picture "99:99" VALID ValidaHora(cHrFim)  OF oDlg 

  @ 3.5, 20  SAY STR0019 of oDlg   //"Intervalo"
  @ 4.1, 20  MSGET oInterval VAR cInterVal SIZE 35,9 Picture "99:99" VALID ValidaHora(cInterval) OF oDlg 
  
  aadd(aDias,{.F.,STR0020}) //"Domingo"
  aadd(aDias,{.F.,STR0021}) //"Segunda Feira"
  aadd(aDias,{.F.,STR0022}) //"Terça Feira"
  aadd(aDias,{.F.,STR0023}) //"Quarta Feira"
  aadd(aDias,{.F.,STR0024}) //"Quinta Feira"
  aadd(aDias,{.F.,STR0025}) //"Sexta Feira"
  aadd(aDias,{.F.,STR0026}) //"Sábado"
  
  @ 80,07 TO 142,84 PROMPT STR0027 PIXEL OF oDlg     //"Se Semanal, nos dias:"
  @ 87,10 LISTBOX oDias FIELDS HEADER " ",STR0028;  //"Dia da Semana"
  FIELDSIZES 14, 50 SIZE 70, 52 PIXEL OF oDlg
  oDias:SetArray(aDias)
  oDias:bLine := {|| {IIF(aDias[oDias:nAt,1],oOK,oNo),aDias[oDias:nAt,2]} }
  oDias:bLDblClick := { |nRowPix, nColPix, nKeyFlags| If(oDias:nAtCol(nColPix)==1,(aDias[oDias:nAt,1] := !aDias[oDias:nAt,1],oDias:DrawSelect()),)}  
  oDias:SetDisable()

  For nC := 1 To 31
    aadd(aMensal,{.f.,StrZero(nC,2)})
  next

  @ 80,85 TO 142,162 PROMPT STR0029 PIXEL OF oDlg     //"Se Mensal, nos dias:"
  @ 87,88 LISTBOX oMensal FIELDS HEADER " ",STR0030;  //"Dia do Mês"
  FIELDSIZES 14, 50 SIZE 70, 52 PIXEL OF oDlg
  oMensal:SetArray(aMensal)
  oMensal:bLine := {|| {IIF(aMensal[oMensal:nAt,1],oOK,oNo),aMensal[oMensal:nAt,2]} }
  oMensal:bLDblClick := { |nRowPix, nColPix, nKeyFlags| If(oMensal:nAtCol(nColPix)==1,(aMensal[oMensal:nAt,1] := !aMensal[oMensal:nAt,1],oMensal:DrawSelect()),)}  
  oMensal:SetDisable()
  
  @ 6.1, 21  SAY STR0031 of oDlg   //"Ação"
  @ 6.7, 21  MSGET oAcao VAR cAcao SIZE 70,10 Picture "@!" OF oDlg 
  
  @ 7.6, 21  SAY STR0032 of oDlg   //"Environment"
  @ 8.2, 21  MSGET oXM_ENV VAR cXM_ENV SIZE 70,10 Picture "@!" OF oDlg 

  @ 9.2, 21  SAY STR0036 OF oDlg //"Ativado"
  @ 9.8, 21  COMBOBOX oAtivo VAR cAtivo ITEMS { STR0037, STR0038 } SIZE 50,10 OF oDlg //"T=Sim"###"F=Não"

  DEFINE SBUTTON FROM 145,90 TYPE 1 ENABLE OF oDlg ACTION IIf((lInclui==.T. .or. lAltera==.T.),Grava(lInclui),iif(lDeleta,Deleta(),oDlg:End()))
  DEFINE SBUTTON FROM 145,120 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End()) 
  
  if !lInclui 
    dbSelectArea("SXM")
    cCodigo := XM_CODIGO
    cNome   := XM_NOME
    cDescr  := XM_DESCR
    nTipo   := XM_TIPO
    dDataIni:= XM_DTINI
    cHrIni  := XM_HRINI
    dDataFim:= XM_DTFIM
    cHrFim  := XM_HRFIM
    cInterval := XM_INTERV
    cXM_ENV	:= XM_AMBIENT
    
    For nC := 1 to 7 
      if !( SUBS(XM_SEMANA, nC,1) == " " )
			aDias[nC][1] := .T.
      else                 
			aDias[nC][1] := .F.
      end
    next
    
//    oDias:SetArray(aDias)

    For nC := 1 to 31 
      if SUBS(XM_MENSAL,nC,1) <> " "
        aMensal[nC][1] := .T.
      else                 
      aMensal[nC][1] := .F.
      endif
    next
//    oMensal:SetArray(aMensal)
    ChangeTipo(nTipo,oDias,oMensal)
    cAcao := XM_ACAO
    cAtivo := if( Empty( XM_ATIVO ), "F", XM_ATIVO )
    cTimeOut := XM_TIMEOUT
  endif
  
  if lAltera
    oCod:SetDisable()
  endif
  If lVisual==.T. .Or. lDeleta==.T.
    oTipo:SetDisable()
    oCod:SetDisable()
    oNome:SetDisable()
    oDescr:SetDisable()
    oDias:SetDisable()
    oMensal:SetDisable()
    oDtIni:SetDisable()
    oHrIni:SetDisable()
    oDtFim:SetDisable()
    oHrFim:SetDisable()
    oInterval:SetDisable()
    oAcao:SetDisable()
    oXM_ENV:SetDisable()    
    oAtivo:SetDisable()
  endif

  ACTIVATE MSDIALOG oDlg CENTERED 
  
Return .T. 

Function ValidaHoras(cHoras)
Local lHoraOk:=.T.
Local nLenWF4_HR:=5 //Tamanho dos campos WF4_HRINI e WF4_HRFIM

If (len(alltrim(cHoras) ) < nLenWF4_HR) //verifica se as horas e minutos foram preenchidos 
    lHoraOk:=.F.
ElseIf Val(left(cHoras,2)) > 23 .or. Val(Right(cHoras,2)) > 59 //verifica se os valores são válidos
	lHoraOk:= .F.
EndIf

Return lHoraOk

Function ValidFunction( cFunction, lEmpty )
	local lResult := .t.
	default cFunction := "", lEmpty := .t.
	if Empty( cFunction )
		if !lEmpty
			Help(" ",1,"WFNOFUNC") //"Funcao nao encontrada"
			lResult := .f.
		end
	else
		if !( lResult := FindFunction( cFunction ) )
			Help(" ",1,"WFNOFUNC") //"Funcao nao encontrada"
		end
	end
return lResult

Static Function ValidaWF003(cCodigo,cNome,dDtIni,dDtFim,cHrIni,cHrFim,cAcao)
  If (Alltrim(cCodigo)="")
     Help("",1,"WFCODSCH")
     Return .F.
  Endif
  If (Alltrim(cNome)="")
     Help("",1,"WFNOMESCH")
     Return .F.
  Endif
  If (Alltrim(DTOS(dDtIni))="")
     Help("",1,"WFDtiSCH")
     Return .F.
  Endif
  If (Alltrim(DTOS(dDtFim))="")
     Help("",1,"WFDtfSCH")
     Return .F.
  Endif
  If (Alltrim(cHrIni)=":")
     Help("",1,"WFHriSCH")
     Return .F.
  Endif
  If (Alltrim(cHrFim)=":")
     Help("",1,"WFHrfSCH")
     Return .F.
  Endif
  If (Alltrim(cInterval)=":")
     Help("",1,"WFIntSCH")
     Return .F.
  Endif
  
  If (Alltrim(cAcao)="")
     Help("",1,"WFAcaoSCH")
     Return .F.
  Endif
  
  if dDtIni > dDtFim 
     Help("",1,"WFDtifSCH")
     Return .F.
  endif   
  
  if Alltrim(cXM_ENV) = ""
     Help("",1,"WFXM_ENVSCH")
     Return .F.
  endif
Return .T.

Static Function ChangeTipo(nTipo,oDias,oMensal)
  Do Case
    Case nTipo == 1
      oDias:SetDisable()
      oMensal:SetDisable()      
    Case nTipo == 2
      oDias:SetEnable()
      oMensal:SetDisable()         
    Case nTipo == 3
      oDias:SetDisable()
      oMensal:SetEnable()            
  EndCase
Return .T.

Static Function Grava(lInclui)
	Local oWF
	Local nC
	Local cSemanal := cMensal := ""
	Local lOKSemana := lOKMes:=.f.
	
	If !ValidaWF003(cCodigo,cNome,dDataIni,dDataFim,cHrIni,cHrFim,cAcao)
		Return .T.
	end
	
	dbSelectArea("SXM")

	if lInclui
		DbGoTop()
	  	LOCATE FOR ( XM_FILIAL + XM_CODIGO ) == ( xFilial("SXM") + cCodigo )
	  	if Found()
	   	Help("",1,"WFSCHEX")
			Return .T.
		end
	end

	if nTipo == 2
		For nC := 1 to 7 
			if aDias[nC][1]==.T.
				cSemanal:=cSemanal+"X"
				lOKSemana := .T.
			else                    
				cSemanal:=cSemanal+SPACE(1)
			end
		next   
	else
		cSemanal := SPACE(7)  
	end
     
	if nTipo ==  3
		For nC := 1 to 31 
			if aMensal[nC][1]==.T.
				cMensal:=cMensal+"X"
				lOKMes := .T.
			else                    
				cMensal:=cMensal+" "
			endif
		next   
	else
		cMensal := SPACE(31)  
	end
  
  if nTipo=2 .and. !lOKSemana
    Help("",1,"WFNOSEM")
    Return .T.
  endif
  
  if nTipo=3 .and. !lOKMes
    Help("",1,"WFNOMES")
    Return .T.
  endif

	cHrIni := StrZero( Val( Left( cHrIni,2 ) ),2 ) + ":" +StrZero( Val( Right( cHrIni,2 ) ),2 )
	cHrFim := StrZero( Val( Left( cHrFim,2 ) ),2 ) + ":" +StrZero( Val( Right( cHrFim,2 ) ),2 )
	cInterval := StrZero( Val( Left( cInterval,2 ) ),2 ) + ":" +StrZero( Val( Right( cInterval,2 ) ),2 )

	oWF := TWFObj()

	if RecLock("SXM",lInclui)
		XM_FILIAL := xFilial("SXM")
		XM_CODIGO := cCodigo
		XM_NOME   := cNome
		XM_DESCR  := cDescr
		XM_TIPO   := nTipo
		XM_DTINI  := dDataIni
		XM_HRINI	:= cHrIni
		XM_DTFIM  := dDataFim
		XM_HRFIM	:= If( cInterval == "00:00", cHrIni, cHrFim )
		XM_INTERV := cInterval
		XM_SEMANA	:= cSemanal
		XM_MENSAL := cMensal
		XM_ACAO   := cAcao
		XM_AMBIENT := cXM_ENV
		XM_ATIVO	:= cAtivo
		XM_TIMEOUT := cTimeOut
		MsUnlock( "SXM" )
	end

	oWF:oScheduler:Recalc()
	oDlg:End()
Return .T.

Static Function Deleta()
	if Reclock("SXM")
		dbDelete()
		MsUnlock( "SXM" )
		dbSelectArea("SXM")
	end
	oDlg:End()
Return .T.


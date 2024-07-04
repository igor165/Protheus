#Include "fileio.ch"
#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "RSPM005.CH"
#Include "TBICONN.CH"
#Include "PRCONST.CH"

#DEFINE TAB	CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} RSPM005
	Processo de exportação de Dados (CSV) para a integração GUPY
	
	@author	Wesley Alves Pereira
	@version	P12
	@since	09/05/2019
*/

Function RSPM005()

	Local oDlg      := Nil     
    Local oPanelBkg := Nil
    Local oStepWiz  := Nil
    Local oNewPag   := Nil
    Local oFont1    := TFont():New('Tahoma',,-20)
    Local oFont2    := TFont():New('Tahoma',,-12)
    Local cTpExpor  := ''
    Local cLocal    := ''
    Local oPanel := Nil

	If ( Findfunction( "RhGUPYExt" ) ) 
		If ( ! RhGUPYExt( SM0->M0_CGC ) )
			Return (.F.)
		EndIf
	EndIf
   
    oFont1:Bold := .T.
    oFont2:Bold := .F.
    
    DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) //"Exportação (CSV) GUPY"
    oDlg:nWidth := 800 //800
    oDlg:nHeight := 520 //620
 
    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1", {|oPanel|cria_pg1( oPanel,oFont1,oFont2,@cTpExpor )})
    oNewPag:SetStepDescription(STR0002) //"Primeiro Passo"
    oNewPag:SetCancelAction({||oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle(STR0012) //"VOLTAR"
    
    //----------------------
    // Pagina 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2", {|oPanel|cria_pg2(oPanel,oFont1,oFont2,@cLocal)})
    oNewPag:SetStepDescription(STR0003) //"Segundo Passo"
    oNewPag:SetCancelAction({||oDlg:End()})
    oNewPag:SetNextAction({|| IIf(valida_pg2(cTpExpor,cLocal),oDlg:End(),)})
    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
    
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} function cria_pg1
Cria a 2º pagina do Wizard
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------

Static Function cria_pg1( oPanel,oFont1,oFont2,cTpExpor )
   
    Local aItems := {STR0031,STR0032,STR0033,STR0034} //"Filiais" "Departamentos" "Cargos" "Todos"
    Local oCombo
    Local oSay1, oSay2 := Nil

    cTpExpor := aItems[1]
    
    oSay1:= TSay():New(030,10,{||STR0010},oPanel,,oFont1,,,,.T.,,,200,20) //"EXPORTAÇÃO"
    
    oSay2:= TSay():New(080,10,{||STR0011},oPanel,,oFont2,,,,.T.,,,400,20) //"Selecione o tipo de exportação que deseja realizar:"
 
    oCombo := TComboBox():New(100,10,{|u|if(PCount()>0,cTpExpor:=u,cTpExpor)},aItems,100,20,oPanel,,{||} ,,,,.T.,,,,,,,,,'cTpExpor')
 
 Return (.T.)
  
//-------------------------------------------------------------------
/*/{Protheus.doc} function cria_pg2
Cria a 3º pagina do Wizard
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function cria_pg2( oPanel,oFont1,oFont2,cLocal )
    
    Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)
    Local oTButton1 := TButton():New( 100, 010, STR0013 ,oBtnPanel,{|| fDire ( @cLocal )} , 80,20,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Local do Arquivo"
    
    Local oSay1, oSay2 := Nil
    
    oSay1:= TSay():New(030,10,{||STR0010},oPanel,,oFont1,,,,.T.,,,200,20) //"EXPORTAÇÃO"
    
    oSay2:= TSay():New(080,10,{||STR0015 + ' ' + STR0016 },oPanel,,oFont2,,,,.T.,,,400,20) //"Selecione o local para a exportação do arquivo .CSV" "e confirme a operação!"
    
    oSay3:= TSay():New(130,10,{||STR0013 + ":  " + cLocal },oPanel,,oFont2,,,,.T.,,,400,20) //"Selecione o local para a exportação do arquivo .CSV" "e confirme a operação!"
    
    oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT
 
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function valida_pg2
Valida o local escolhido para gravação do CSV
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function valida_pg2( cTpExpor,cLocal )

If Empty(cLocal)

	Help(NIL, NIL, STR0017, NIL, STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0019}) //"Gravação" "Local de gravação do arquivo" "Informe corretamente o local para gravação dos arquivos de exportação."
    Return (.F.)
EndIf

fAcao(cTpExpor,cLocal)
                   
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDire
Escolhe o local do Arquivo
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fDire (cLocal)

cLocal := cGetFile("",STR0015,1,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY ) //"Selecione o local para a exportação do arquivo .CSV"

If Empty( cLocal )
	Help(NIL, NIL, STR0017, NIL, STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0019}) //"Gravação" "Local de gravação do arquivo" "Informe corretamente o local para gravação dos arquivos de exportação."
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fAcao
Escolhe a função a ser chamada para exportação
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fAcao( cTpExpor,cLocal )

Local nOpc := "4"
Local lRet:= .T.

If(cTpExpor == STR0031) //"Filiais"
	nOpc := "1"
ElseIf(cTpExpor == STR0032) //"Departamentos"
	nOpc := "2"
ElseIf(cTpExpor == STR0033) //"Cargos"
	nOpc := "3"
Else //"Todos"
	nOpc := "4"
Endif	
  
    Do Case 
    Case nOpc == '1'
     	Processa({|| lRet := fExpFil(cLocal)},STR0025, STR0026) //"Aguarde"	"Exportando os dados da tabela de Filiais"
	Case nOpc == '2'
    	Processa({|| lRet := fExpDep(cLocal)},STR0025, STR0027) //"Aguarde" "Exportando os dados da tabela de Departamentos"
	Case nOpc == '3'
    	Processa({|| lRet := fExpFun(cLocal)},STR0025, STR0028) //"Aguarde" "Exportando os dados da tabela de Cargos" 
	Case nOpc == '4' 
	   	Processa({|| lRet := fExpFil(cLocal)},STR0025, STR0026) //"Aguarde" "Exportando os dados da tabela de Filiais"
    	Processa({|| lRet := fExpDep(cLocal)},STR0025, STR0027) //"Aguarde" "Exportando os dados da tabela de Departamentos"
    	Processa({|| lRet := fExpFun(cLocal)},STR0025, STR0028) //"Aguarde" "Exportando os dados da tabela de Cargos"
    EndCase
    If lRet	
	    Aviso( OemtoAnsi(STR0029) , OemtoAnsi(STR0030),	{ "Ok" } ) //"Sucesso!" "Exportação realizada com sucesso. Busque os dados no local escolhido!"
    Endif
                    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fExpFil
Exporta os dados da filial para um arquivo CSV.
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fExpFil( cLocal )

Local cArq     := cEmpAnt+"-"+"FIL"+"-D"+Alltrim(DTOS(DATE()))+"-T"+Replace(Time(),':','')+".CSV"
Local nHandle  := 0
Local aDados := FWLoadSM0()
Local aSM0Data := {}
Local nXi := 0
Local cNumero := ""
Local cEndere := ""
Local cOperad := ","
Local cComple := ""
Local aEmpAtu := FWArrFilAtu( cEmpAnt ) 
Local cFullDress := ""

nHandle := MsfCreate(cLocal+"\"+cArq,0)

If nHandle > 0 

	cCrLf := STR0020 + TAB //"Codigo;Nome da Filial;Endereço;Número;Cidade;Estado;País;Cep;Latitude;Longitude;"
	
	fWrite(nHandle, cCrLf )
	
	For nXi := 1 To Len (aDados)
	
		If ( Alltrim(aDados[nXi][1]) == Alltrim(cEmpAnt) ) .AND. ( aDados[nXi][3] == aEmpAtu[3] )
			
			cCrLf := ""
			cNumero := ""
			cEndere := ""
			cComple := ""
			
			cCrLf += Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_CODIGO")) + ";" //Codigo
			
			cCrLf += Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_CODFIL")) + ";" //Codigo
			cCrLf += Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_FILIAL")) + ";" //Nome da Filial
			
			cFullDress := Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_ENDENT")) //Endereço
			
			If At(cOperad,cFullDress) > 0
				cEndere := SubStr(cFullDress,1,At(cOperad,cFullDress)-1)
				cNumero := SubStr(cFullDress,At(cOperad,cFullDress)+1,Len(cFullDress))
			Else
				cEndere := cFullDress
			EndIf
			
			cCrLf += Alltrim(cEndere) + ";" //Endereço
			 
			If !Empty(cNumero)
				cComple := Alltrim(cNumero)
			EndIf
			
			If !Empty(Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_COMPENT"))) 
				If  !Empty(cComple)
					cComple += " - " + Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_COMPENT")) //Complemento
				Else
				 	cComple := Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_COMPENT")) //Complemento
				EndIf
			EndIf
			
			cCrLf += cComple + ";"  //Número + Complemento
			cCrLf += Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_CIDENT")) + ";" //Cidade
			cCrLf += Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_ESTENT")) + ";" //Estado
			cCrLf += Iif(Empty(Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_CODMUN"))),STR0023,STR0024 )+ ";" //"Indeterminado" "Brasil"
			cCrLf +=  Alltrim(Posicione("SM0",1,cEmpAnt + aDados[nXi][2],"M0_CEPENT")) + ";" //Cep 
			cCrLf += Space(1)       + ";" //Latitude 
			cCrLf += Space(1)       + ";" //Longitude 
			cCrLf += + TAB
			
			fWrite(nHandle, cCrLf )
		
		EndIf
	
	Next nXi
		
	fClose(nHandle)
				
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fExpDep
Escolhe a função a ser chamada para exportação Departamento
@author  Silvia Taguti Garcia
@since   17/05/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function fExpDep( cLocal )      

Local cArq     	:= cEmpAnt+"-"+"DEP"+"-D"+Alltrim(DTOS(DATE()))+"-T"+Replace(Time(),':','')+".CSV"
Local nHandle  	:= 0
Local aDados 	:= {}
Local aCampos	:= {}
Local nXi		:= 0
Local nY		:= 0
Local cCabDep   := ""
Local lRet		:= .F.

lRet := fCargaRCC("S132", @aDados, @aCampos)

if (! lRet)
	Return ( lRet )
EndIf

nHandle := MsfCreate(cLocal+"\"+cArq,0)

If nHandle > 0
 	
	cCrLf := STR0035 + TAB 
	
	fWrite(nHandle, cCrLf )

	For nXi := 1 To Len(aDados)
		cCrLf := ""
		If aDados[nXi,7] == "F"
			cCrLf += aDados[nXi,1] + ";" +aDados[nXi,3] + ";" + aDados[nXi,4] + ";" +aDados[nXi,5] + ";" +aDados[nXi,6] + ";"
			cCrLf += + TAB
			fWrite(nHandle, cCrLf )
			aDados[nXi,7] := "T"
			lRet := .T.
		Endif
	Next nXi
	fClose(nHandle)
	fGravaExp("S132",aDados)
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fExpFun
Escolhe a função a ser chamada para exportação Funções
@author  Silvia Taguti Garcia
@since   17/05/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function fExpFun( cLocal )  

Local cArq     	:= cEmpAnt+"-"+"FUN"+"-D"+Alltrim(DTOS(DATE()))+"-T"+Replace(Time(),':','')+".CSV"
Local nHandle  	:= 0
Local aDados 	:= {}
Local aCampos	:= {}
Local nXi		:= 0
Local nY		:= 0
Local cCabDep   := ""
Local lRet 		:= .F.

lRet := fCargaRCC("S133", @aDados, @aCampos)

if (! lRet)
	Return ( lRet )
EndIf

nHandle := MsfCreate(cLocal+"\"+cArq,0)

If nHandle > 0
 	
	cCrLf := STR0036 + TAB 
	
	fWrite(nHandle, cCrLf )

	For nXi := 1 To Len(aDados)
		cCrLf := ""
		If aDados[nXi,7] == "F"
			cCrLf += aDados[nXi,1] + ";" +aDados[nXi,3] + ";" + aDados[nXi,4] + ";" +aDados[nXi,5] + ";" +aDados[nXi,6] + ";"
			cCrLf += + TAB
			fWrite(nHandle, cCrLf )
			aDados[nXi,7] := "T"
			lRet := .T.
		Endif
	Next nXi
	fClose(nHandle)
	fGravaExp("S133",aDados)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCargaRcc
Escolhe a função a ser chamada para Carga tabelas RCC
@author  Silvia Taguti Garcia
@since   17/05/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------

Static Function fCargaRcc(cTab, aDados, aCampos)

Local aArea		:= GetArea()
Local cFilRcb	:= xFilial( "RCB")
Local cFilRcc 	:= xFilial( "RCC")
Local nCont	    := 0
Local aCabTab   := {}
Local cConteudo := ""
Local lRet		:= .T.

Default aCampos := {}

//--Carrega os campos da tabela auxiliar S033
aAdd(aCampos, "FILIAL") 

dbSelectArea( "RCB" )
RCB->( dbSeek( cFilRcb + cTab, .T.) )
While RCB->( !Eof() .And. RCB_FILIAL + RCB_CODIGO == cFilRcb + cTab )
	RCB->( aAdd( aCabTab, { RCB_CAMPOS, RCB_TIPO, RCB_TAMAN, RCB_DECIMA } ) )
	RCB->( aAdd(aCampos, RCB_CAMPOS) )
	RCB->( dbSkip() )
End While      

//--Carregar os registros da tabela auxiliar
dbSelectArea( "RCC" )
RCC->( dbSeek( cFilRcc + cTab, .T. ) )
While RCC->( !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == cFilRcc + cTab  )

	//--Reinicializa variaveis auxiliares
	aArrAux := {}
	nPosIni := 1

	Aadd(aArrAux,RCC->RCC_FIL)
	Aadd(aArrAux,RCC->RCC_SEQUEN)
	//--Carrega o conteudo do campo da tabela auxiliar
	For nCont := 1 To Len( aCabTab )
		//--Tamanho do Campo
		nTamCpo := aCabTab[nCont, 3]
		//--Guarda conteudo do campo na Variavel
		If aCabTab[nCont, 2] == "C"
			cConteudo := Subs( RCC->RCC_CONTEU, nPosIni, nTamCpo )
		Endif
		//--Guarda o conteudo em array auxiliar
 		aAdd( aArrAux, cConteudo )
		//--Posicao Proximo Campo
		nPosIni += nTamCpo
	Next nCont
	aAdd(aDados ,aArrAux )
	
	RCC->( dbSkip() )
Enddo

If Empty(aDados)
	Help( ,, "HELP",, STR0037 + TAB + TAB + STR0038, 1, 0 ) //
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGravaExp
Função para gravação de tabela Exporada
@author  Silvia Taguti Garcia
@since   17/05/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------

Static Function fGravaExp(cTab,aGrvRCC)

Local cFilRCC		:= xFilial("RCC")      
Local cChvRCC		:= Space(6)
Local nx			:= 0

dbSelectArea( "RCC" )
dbSetOrder(1)

For nX := 1 to Len(aGrvRCC)
	If dbSeek(cFilRCC + cTab + aGrvRCC[nX,1] + cChvRCC + aGrvRCC[nX,2])
		RecLock("RCC",.F.)
		RCC->RCC_CONTEU	:=  aGrvRCC[nX,03]+aGrvRCC[nX,04]+aGrvRCC[nX,05] + aGrvRCC[nX,06]+aGrvRCC[nX,07]
	Endif	
	MsUnlock()			 
Next nX

Return(.T.)                                      
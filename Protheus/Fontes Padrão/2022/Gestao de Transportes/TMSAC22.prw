#Include 'Protheus.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCAVIAFACIL()
Classe para integração SIGATMS x VIA FACIL

@author Felipe Barbiere
@since 22/04/2021
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCAVIAFACIL

    DATA cDir       As Character
    DATA aResult    As Array
    DATA cPath      As Character
	DATA cPathABCR  As Character
    DATA cFatura    As Character
    DATA cRef       As Character    
	DATA cCodFor    As Character
	DATA cLojFor    As Character
	DATA cCodTAG    As Character
	DATA nValFat    As Number

    METHOD New()    Constructor  
    METHOD LoadParams()
    METHOD LoadABCR()
    METHOD ReadFile()
    METHOD ReadABCR()
    METHOD InsPedagio()
    METHOD InsEstacionamento()
    METHOD InsMensali()
    METHOD InsCredito()
    METHOD InsAdesao()
    METHOD InsAbast()
    METHOD InsTarifa()
    METHOD RenameFile()
    METHOD ConcSemParar()
    METHOD ConcAdesoes()
    METHOD ConcCredito()
	METHOD ConcMensalidade()
	METHOD ExcluiConc()
    METHOD FechaConc()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Felipe Barbiere
@since 22/04/2021
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCAVIAFACIL

    ::aResult   := {}
    ::cPath     := ""
	::cPathABCR := ""
    ::cFatura   := ""
    ::cRef      := ""
    ::cCodFor   := ""
    ::cLojFor   := ""
	::cCodTAG   := ""
	::nValFat   := 0

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} LoadParams()
Abertura do pergunte dos parâmetros para importação do arquivoss

@author     Felipe Barbiere
@since      30/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD LoadParams() CLASS TMSBCAVIAFACIL
Local lRet := .T.
Local lPergunta := .T. 

While lPergunta

	lRet := Pergunte("TMSAP20",.T.) 

	If lRet

		If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03) .And. !Empty(MV_PAR04) .And. !Empty(MV_PAR05) .And. !Empty(MV_PAR06) .And. !Empty(MV_PAR07)
			::cPath   := Alltrim(MV_PAR01) 
			::cFatura := AllTrim(MV_PAR02)
			::cRef    := Alltrim(MV_PAR03)
			::cCodFor := Alltrim(MV_PAR04)
			::cLojFor := Alltrim(MV_PAR05)
			::cCodTAG := Alltrim(MV_PAR06)
			::nValFat := MV_PAR07
		
			::ReadFile(self:cPath, "pedagio")		//Leitura de Praças de Pedágio
			::ReadFile(self:cPath, "estacionamento")//Leitura das Estacionamento
			::ReadFile(self:cPath, "mensalidade")	//Leitura das Mensalidades
			::ReadFile(self:cPath, "credito")		//Leitura dos Créditos
			::ReadFile(self:cPath, "adesao")	    //Leitura das Adesões
			::ReadFile(self:cPath, "abastecimento")	//Leitura dos Abastecimentos

			lPergunta := .F. 
		
		Else
			lPergunta := .T.
			Help("",1,"TMSAC2201")	//-- "Preencha todos o campos."
		EndIf

	Else

		lPergunta := .F.
	
	EndIf

EndDo

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} LoadABCR()
Abertura do pergunte dos parâmetros para importação do arquivo da ABCR

@author     Valdemar Roberto Mognon
@since      06/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD LoadABCR() CLASS TMSBCAVIAFACIL
Local lRet      := .T.
Local lPergunta := .T. 

While lPergunta

	lRet := Pergunte("TMSAP20A",.T.)

	If lRet

		If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
			::cPathABCR := Alltrim(MV_PAR01) 
 			::cCodFor   := Alltrim(MV_PAR02)
			::cLojFor   := Alltrim(MV_PAR03)
		
			::ReadABCR(self:cPathABCR,"tarifas")		//Leitura de Tarifas de Pedágio da ABCR

			lPergunta := .F. 
		
		Else
			lPergunta := .T.
			Help("",1,"TMSAC2201")	//-- "Preencha todos o campos."
		EndIf

	Else

		lPergunta := .F.
	
	EndIf

EndDo

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ReadFile()
Leitura de todos os arquivos da pasta

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ReadFile(cDir, cArquivo) CLASS TMSBCAVIAFACIL
Local cLinha  := ""
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {}

Default cDir := ""

cArq    := cArquivo + ".csv"
lPrim   := .T.
aCampos := {}
aDados  := {}
If File(cDir+cArq)           
    FT_FUSE(cDir+cArq)
    FT_FGOTOP()
    While !FT_FEOF() 
            cLinha := FT_FREADLN()
            If lPrim
                aCampos := Separa(FwNoAccent(cLinha),";",.T.)
                lPrim := .F.
            Else
				If !Empty(StrTran(cLinha,";",""))
					AADD(aDados, Separa(cLinha,";",.T.))
				EndIf
			EndIf
        FT_FSKIP()
    EndDo
    AADD(::aResult, { cArquivo, aCampos, aDados } )   
    FT_FUSE()
EndIf

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} ReadABCR()
Leitura do arquivo de tarifas da ABCR

@author     Valdemar Roberto Mognon
@since      07/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ReadABCR(cDir,cArquivo) CLASS TMSBCAVIAFACIL
Local cArq      := ""
Local cLinha    := ""
Local cPalavra  := ""
Local aCampos   := {}
Local aDados    := {}
Local aLinha    := {}
Local nPos      := 0
Local nSeq      := 0
Local lValendo  := .F.

Default cDir     := ""
Default cArquivo := ""

cArq    := cArquivo + ".csv"
aCampos := {}
aDados  := {}

If File(cDir + cArq)           
	FT_FUSE(cDir + cArq)
	FT_FGOTOP()

	While !FT_FEOF() 
		cLinha := FT_FREADLN() + ";"

		nPos   := At(";",cLinha) - 1
		If nPos == 0 .Or. At("***",cLinha) > 0
			lValendo := .F.
		EndIf

		If nPos > 0
			cPalavra := Left(cLinha,nPos)
			If "Praça" $ cPalavra
				lValendo := .T.
			EndIf

			If lValendo
				If (nPos := At("Praça",cLinha)) > 0
					If Empty(aCampos)
						nPos := At(";",cLInha) - 1
						While nPos > 0
							cPalavra := NoAcento(AllTrim(Left(cLinha,nPos)))
							Aadd(aCampos,cPalavra)
							cLinha := SubStr(cLinha,nPos + 2)
							nPos := At(";",cLinha) - 1
						EndDo
					EndIf
				Else
					aLinha := {}
					nSeq   := 0
					nPos   := At(";",cLInha) - 1
					While nPos > 0
						cPalavra := NoAcento(AllTrim(Left(cLinha,nPos)))
						nSeq ++
						If Upper(aCampos[nSeq]) == "KM" .Or. Upper(aCampos[nSeq]) == "VALOR"
							cPalavra := Val(StrTran(cPalavra,",","."))
						EndIf
						Aadd(aLinha,cPalavra)
						cLinha := SubStr(cLinha,nPos + 2)
						nPos := At(";",cLInha) - 1
					EndDo
					Aadd(aDados,Aclone(aLInha))
				EndIf
			EndIf

		EndIf
		FT_FSKIP()
	EndDo

    AADD(::aResult,{cArquivo,aCampos,aDados})
	FT_FUSE()
EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} InsPedagio()
Leitura do arquivo de pedágio: "pedagio.csv"

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsPedagio() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := aScan(self:aResult, { |x| x[1] == "pedagio" }) 
Local aItens    := {}
Local aCab      := {}
Local aDadosDMJ := {}
Local nOpcxPed  := 0
Local aCposDMJ  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDMJ  := Iif(nPos > 0, DePara("pedagio", self:aResult[nPos][2])[2], {}) //Campos tabela DMJ
    self:aResult[nPos][2] := DePara("pedagio", self:aResult[nPos][2])[1]
    nSeq   := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDMJ, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DMJ_DATPAS"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], CtoD(self:aResult[nPos][3][nCont][nCont2]), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMJ_HORPAS"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], SubStr(self:aResult[nPos][3][nCont][nCont2],1,2) + ;
                    											 SubStr(self:aResult[nPos][3][nCont][nCont2],4,2), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMJ_VALPAS"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil }) 
                ElseIf self:aResult[nPos][2][nCont2] == "DMJ_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DMJ_FILIAL"  , xFilial("DMJ")  	, Nil })
            Aadd(aItens, {"DMJ_SEQUEN"  , StrZero(nSeq, Len(DMJ->DMJ_SEQUEN))  	, Nil })
			If !ExistReg("DMJ",Aclone(aCab),Aclone(aItens),{"DMJ_NUMCON","DMJ_PLACA","DMJ_DATPAS","DMJ_HORPAS"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDMJ     , {} )
	    Aadd(aDadosDMJ[Len(aDadosDMJ)], aClone(aReg))
	    Aadd(aDadosDMJ[Len(aDadosDMJ)] , "MdGridDMJ" )
	    Aadd(aDadosDMJ[Len(aDadosDMJ)] , "DMJ" )
	EndIf

    If !Empty(aMaster) .And. !Empty(aDadosDMJ)
        lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDMJ,  nOpcxPed, .T.  )
    EndIf

    If lCont
        ::RenameFile("pedagio")
    EndIf
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} InsMensali()
Leitura de todos os arquivos da pasta

@author     Valdemar Roberto Mognon
@since      03/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsMensali() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := aScan(self:aResult, { |x| x[1] == "mensalidade" }) 
Local aItens    := {}
Local aCab      := {}
Local aDadosDML := {}
Local nOpcxPed  := 0
Local aCposDML  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDML  := DePara("mensalidade", self:aResult[nPos][2])[2] //Campos tabela DML
    self:aResult[nPos][2] := DePara("mensalidade", self:aResult[nPos][2])[1]
    nSeq      := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDML, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DML_VALOR"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil }) 
                ElseIf self:aResult[nPos][2][nCont2] == "DML_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DML_FILIAL"  , xFilial("DML")  	, Nil })
            Aadd(aItens, {"DML_SEQUEN"  , StrZero(nSeq, Len(DML->DML_SEQUEN))  	, Nil })
			If !ExistReg("DML",Aclone(aCab),Aclone(aItens),{"DML_NUMCON","DML_PLACA"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDML     , {} )
	    Aadd(aDadosDML[Len(aDadosDML)], aClone(aReg))
	    Aadd(aDadosDML[Len(aDadosDML)] , "MdGridDML" )
	    Aadd(aDadosDML[Len(aDadosDML)] , "DML" )
	EndIf
	
    If !Empty(aMaster) .And. !Empty(aDadosDML)
	    lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDML,  nOpcxPed, .T.  )   
    EndIf
    
    If lCont
        ::RenameFile("mensalidade")
    EndIf
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} InsCredito()
Leitura de todos os arquivos da pasta

@author     Valdemar Roberto Mognon
@since      08/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsCredito() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := aScan(self:aResult, { |x| x[1] == "credito" }) 
Local aItens    := {}
Local aCab      := {}
Local aDadosDMM := {}
Local nOpcxPed  := 0
Local aCposDMM  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDMM  := DePara("credito", self:aResult[nPos][2])[2] //Campos tabela DMM
    self:aResult[nPos][2] := DePara("credito", self:aResult[nPos][2])[1]
    nSeq   := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDMM, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DMM_VALCRE"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil }) 
                ElseIf self:aResult[nPos][2][nCont2] == "DMM_DATCRE"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], CtoD(self:aResult[nPos][3][nCont][nCont2]), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMM_HORCRE"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], SubStr(self:aResult[nPos][3][nCont][nCont2],1,2) + ;
                    											 SubStr(self:aResult[nPos][3][nCont][nCont2],4,2), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMM_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DMM_FILIAL"  , xFilial("DMM")  	, Nil })
            Aadd(aItens, {"DMM_SEQUEN"  , StrZero(nSeq, Len(DMM->DMM_SEQUEN))  	, Nil })
			If !ExistReg("DMM",Aclone(aCab),Aclone(aItens),{"DMM_NUMCON","DMM_PLACA","DMM_DATCRE","DMM_HORCRE"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDMM     , {} )
	    Aadd(aDadosDMM[Len(aDadosDMM)], aClone(aReg))
	    Aadd(aDadosDMM[Len(aDadosDMM)] , "MdGridDMM" )
	    Aadd(aDadosDMM[Len(aDadosDMM)] , "DMM" )
	EndIf

    If !Empty(aMaster) .And. !Empty(aDadosDMM)
	    lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDMM,  nOpcxPed, .T.  )   
    EndIf

    If lCont
        ::RenameFile("credito")
    EndIf  
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} InsEstacionamento()
Leitura do arquivo de pedágio: "estacionamento.csv"

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsEstacionamento() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := aScan(self:aResult, { |x| x[1] == "estacionamento" }) 
Local aItens    := {}
Local aCab      := {}
Local aDadosDMK := {}
Local nOpcxPed  := 0
Local aCposDMK  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDMK  := Iif(nPos > 0, DePara("estacionamento", self:aResult[nPos][2])[2], {}) //Campos tabela DMJ
    self:aResult[nPos][2] := DePara("estacionamento", self:aResult[nPos][2])[1]
    nSeq   := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDMK, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DMK_DATENT"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], CtoD(SubStr(self:aResult[nPos][3][nCont][nCont2],1,10)), Nil })
                    AAdd(aItens, {"DMK_HORENT"                 , SubStr(self:aResult[nPos][3][nCont][nCont2],12,2) + ;
                    										     SubStr(self:aResult[nPos][3][nCont][nCont2],15,2), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMK_DATSAI"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], CtoD(SubStr(self:aResult[nPos][3][nCont][nCont2],1,10)), Nil })
                    AAdd(aItens, {"DMK_HORSAI"                 , SubStr(self:aResult[nPos][3][nCont][nCont2],12,2) + ;
                    										     SubStr(self:aResult[nPos][3][nCont][nCont2],15,2), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMK_VALOR"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil }) 
                ElseIf self:aResult[nPos][2][nCont2] == "DMK_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DMK_FILIAL"  , xFilial("DMK")  	, Nil })
            Aadd(aItens, {"DMK_SEQUEN"  , StrZero(nSeq, Len(DMK->DMK_SEQUEN))  	, Nil })
			If !ExistReg("DMK",Aclone(aCab),Aclone(aItens),{"DMK_NUMCON","DMK_PLACA","DMK_DATENT","DMK_HORENT","DMK_DATSAI","DMK_HORSAI"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDMK     , {} )
	    Aadd(aDadosDMK[Len(aDadosDMK)], aClone(aReg))
	    Aadd(aDadosDMK[Len(aDadosDMK)] , "MdGridDMK" )
	    Aadd(aDadosDMK[Len(aDadosDMK)] , "DMK" )
	EndIf

    If !Empty(aMaster) .And. !Empty(aDadosDMK)
	    lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDMK,  nOpcxPed, .T.  )
    EndIf

    If lCont
        ::RenameFile("estacionamento")
    EndIf
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} InsAdesao()
Leitura de todos os arquivos da pasta

@author     Felipe M. Barbiere
@since      08/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsAdesao() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := IIf(!Empty(self:aResult), aScan(self:aResult, { |x| x[1] == "adesao" }), 0)
Local aItens    := {}
Local aCab      := {}
Local aDadosDMN := {}
Local nOpcxPed  := 0
Local aCposDMN  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDMN  := DePara("adesao", self:aResult[nPos][2])[2] //Campos tabela DMN
    self:aResult[nPos][2] := DePara("adesao", self:aResult[nPos][2])[1]
    nSeq   := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDMN, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DMN_VALOR"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil })                 
                ElseIf self:aResult[nPos][2][nCont2] == "DMN_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DMN_FILIAL"  , xFilial("DMN")  	, Nil })
            Aadd(aItens, {"DMN_SEQUEN"  , StrZero(nSeq, Len(DMN->DMN_SEQUEN))  	, Nil })
			If !ExistReg("DMN",Aclone(aCab),Aclone(aItens),{"DMN_NUMCON","DMN_PLACA"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDMN     , {} )
	    Aadd(aDadosDMN[Len(aDadosDMN)], aClone(aReg))
	    Aadd(aDadosDMN[Len(aDadosDMN)] , "MdGridDMN" )
	    Aadd(aDadosDMN[Len(aDadosDMN)] , "DMN" )
	EndIf

    If !Empty(aMaster) .And. !Empty(aDadosDMN)
	    lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDMN,  nOpcxPed, .T.  )   
    EndIf

    If lCont
        ::RenameFile("adesao")
    EndIf
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} InsAbast()
Leitura de todos os arquivos da pasta

@author     Valdemar Roberto Mognon
@since      08/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsAbast() CLASS TMSBCAVIAFACIL
Local nCont     := 0
Local nCont2    := 0
Local nPos      := IIf(!Empty(self:aResult), aScan(self:aResult, { |x| x[1] == "abastecimento" }), 0)
Local aItens    := {}
Local aCab      := {}
Local aDadosDMT := {}
Local nOpcxPed  := 0
Local aCposDMT  := {}
Local aMaster   := {}
Local lCont     := .T.
Local nSeq      := 0
Local aReg      := {}

If !Empty(self:aResult) .And. nPos > 0 
    //Preenchimento do cabeçalho
    DMI->(DbSetOrder(2)) //DMI_FILIAL+DMI_FATURA
	If DMI->(DbSeek(xFilial("DMI")+self:cFatura))
        nOpcxPed := 4 //Alterar
        Aadd( aCab , {"DMI_NUMERO"  , DMI->DMI_NUMERO   , Nil })
    Else
        nOpcxPed := 3 //Incluir
        aCab := GeraCab(self:cFatura, self:cRef, self:cCodFor, self:cLojFor, self:cCodTAG, self:nValFat)
    EndIf
    
    // Preenchimento dos Itens
    aCposDMT  := DePara("abastecimento", self:aResult[nPos][2])[2] //Campos tabela DMT
    self:aResult[nPos][2] := DePara("abastecimento", self:aResult[nPos][2])[1]
    nSeq   := 1
    For nCont := 1 to Len(self:aResult[nPos][3])
        aItens := {}        
        For nCont2 := 1 to Len(self:aResult[nPos][3][nCont])
            If Ascan(aCposDMT, { |x| x[2] == self:aResult[nPos][2][nCont2] })  
                If self:aResult[nPos][2][nCont2] == "DMT_DATABA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], CtoD(self:aResult[nPos][3][nCont][nCont2]), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMT_HORABA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], SubStr(self:aResult[nPos][3][nCont][nCont2],1,2) + ;
                    											 SubStr(self:aResult[nPos][3][nCont][nCont2],4,2), Nil })
                ElseIf self:aResult[nPos][2][nCont2] == "DMT_VALOR"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], Val(StrTran(StrTran(self:aResult[nPos][3][nCont][nCont2], "R$", ""), ",", ".")), Nil })                 
                ElseIf self:aResult[nPos][2][nCont2] == "DMT_PLACA"
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], StrTran(self:aResult[nPos][3][nCont][nCont2], "-", ""), Nil })
                Else
                    AAdd(aItens, {self:aResult[nPos][2][nCont2], self:aResult[nPos][3][nCont][nCont2], Nil })                
                EndIF
            EndIf
        Next nCont2  
        If !Empty(aItens)
            Aadd(aItens, {"DMT_FILIAL"  , xFilial("DMT")  	, Nil })
            Aadd(aItens, {"DMT_SEQUEN"  , StrZero(nSeq, Len(DMT->DMT_SEQUEN))  	, Nil })
			If !ExistReg("DMT",Aclone(aCab),Aclone(aItens),{"DMT_NUMCON","DMT_PLACA","DMT_DATABA","DMT_HORABA"})
	            AAdd(aReg, aItens)
		        nSeq++
			EndIf
        EndIf        
    Next nCont 

	If !Empty(aCab)
		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDMI" )
		Aadd( aMaster[Len(aMaster)] , "DMI" )  
	EndIf
	
	If !Empty(aReg)
	    Aadd(aDadosDMT     , {} )
	    Aadd(aDadosDMT[Len(aDadosDMT)], aClone(aReg))
	    Aadd(aDadosDMT[Len(aDadosDMT)] , "MdGridDMT" )
	    Aadd(aDadosDMT[Len(aDadosDMT)] , "DMT" )
	EndIf

    If !Empty(aMaster) .And. !Empty(aDadosDMT)
	    lCont := TMSExecAuto( "TMSAP10",  aMaster, aDadosDMT,  nOpcxPed, .T.  )   
    EndIf

    If lCont
        ::RenameFile("abastecimento")
    EndIf
EndIf

Return lCont

//-----------------------------------------------------------------
/*/{Protheus.doc} RenameFile()
Leitura de todos os arquivos da pasta

@author     Felipe M. Barbiere
@since      08/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD RenameFile(cArquivo) CLASS TMSBCAVIAFACIL

Default cArquivo := ""

If !Empty(cArquivo)
    FRename(self:cPath + cArquivo + ".csv" , self:cPath + cArquivo + "_" + Self:cRef + ".csv" )
EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ConcSemParar()
Concilia as passagens nas praças de pedágio

@author     Valdemar Roberto Mognon
@since      13/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ConcSemParar(cAlias,cNumero) CLASS TMSBCAVIAFACIL
Local cQuery    := ""
Local cAliasQry := ""
Local cCpoDat1  := ""
Local cCpoHor1  := ""
Local cCpoDat2  := ""
Local cCpoHor2  := ""
Local cConfer   := ""
Local cCodRod   := ""
Local cCodExt   := ""
Local cPalavra  := ""
Local aAreas    := {DTZ->(GetArea()),GetArea()}
Local aPedagios := {}
Local nLinha    := 0
Local nCntFor1  := 0
Local nPos      := 0
Local nKM       := 0

Default cAlias  := ""
Default cNumero := ""

If !Empty(cAlias)
	If cAlias == "DMJ"
		cCpoDat1 := "_DATPAS"
		cCpoHor1 := "_HORPAS"
	ElseIf cAlias == "DMK"
		cCpoDat1 := "_DATENT"
		cCpoHor1 := "_HORENT"
		cCpoDat2 := "_DATSAI"
		cCpoHor2 := "_HORSAI"
	ElseIf cAlias == "DMT"
		cCpoDat1 := "_DATABA"
		cCpoHor1 := "_HORABA"
	EndIf
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT " + cAlias + ".R_E_C_N_O_ REGISTRO,DTQ_FILORI FILORI,DTQ_VIAGEM VIAGEM,DTQ_TIPVIA TIPVIA,DA4_NOME NOMMOT,DTR_CODVEI CODVEI,DTR_VALPDG VALPDG,DA3_COD DA3COD, "
	cQuery += "        DMI_NUMERO NUMERO, " + cAlias + "_NUMCON NUMCON, " + cAlias + "_PLACA PLACA, "
	If cAlias == "DMJ"
		cQuery += "        " + cAlias + "_DATPAS DATPAS, " + cAlias + "_HORPAS HORPAS, " + cAlias + "_VALPAS VALPAS, "
		cQuery += "        " + cAlias + "_LOCAL LOCALI "
	ElseIf cAlias == "DMK"
		cQuery += "        " + cAlias + "_DATENT DATENT, " + cAlias + "_HORENT HORENT, " + cAlias + "_DATSAI DATSAI, " + cAlias + "_HORSAI HORSAI, " + cAlias + "_VALOR VALOR "
	ElseIf cAlias == "DMT"
		cQuery += "        " + cAlias + "_DATABA DATABA, " + cAlias + "_HORABA HORABA, " + cAlias + "_VALOR VALOR "
	EndIf
	cQuery += "   FROM " + RetSQLName(cAlias) + " " + cAlias + " "
	
	cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
	cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
	If Empty(cNumero)
		cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
	Else
		cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
	EndIf
	cQuery += "    AND DMI_CONFER = '2' "
	cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
	cQuery += "    AND DMI.D_E_L_E_T_ =  ''"
	
	cQuery += "   JOIN " + RetSQLName("DA3") + " DA3 "
	cQuery += "     ON DA3_FILIAL = '" + xFilial("DA3") +"' "
	cQuery += "    AND DA3_PLACA  = " + cAlias + "_PLACA "
	cQuery += "    AND DA3.D_E_L_E_T_ =  '' "
	
	cQuery += "   JOIN " + RetSQLName("DTR") + " DTR "
	cQuery += "     ON DTR_FILIAL = '" + xFilial("DTR") +"' "
	cQuery += "    AND DTR_CODVEI = DA3_COD "
	cQuery += "    AND DTR.D_E_L_E_T_ =  '' "

	cQuery += "   JOIN " + RetSQLName("DUP") + " DUP "
	cQuery += "     ON DUP_FILIAL = '" + xFilial("DUP") +"' "
	cQuery += "    AND DUP_FILORI = DTR_FILORI "
	cQuery += "    AND DUP_VIAGEM = DTR_VIAGEM "
	cQuery += "    AND DUP_ITEDTR = DTR_ITEM "
	cQuery += "    AND DUP.D_E_L_E_T_ =  '' "

	cQuery += "   JOIN " + RetSQLName("DA4") + " DA4 "
	cQuery += "     ON DA4_FILIAL = '" + xFilial("DA4") +"' "
	cQuery += "    AND DA4_COD    = DUP_CODMOT "
	cQuery += "    AND DA4.D_E_L_E_T_ =  '' "
	
	cQuery += "   JOIN " + RetSQLName("DTQ") + " DTQ "
	cQuery += "     ON DTQ_FILIAL = '" + xFilial("DTQ") +"' "
	cQuery += "    AND DTQ_FILORI = DTR_FILORI "
	cQuery += "    AND DTQ_VIAGEM = DTR_VIAGEM "
	cQuery += "    AND DTQ.D_E_L_E_T_ =  '' "
	
	cQuery += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) +"' "
	cQuery += "    AND " + cAlias + "_NUMCON = DMI_NUMERO "
	cQuery += "    AND " + cAlias + "_CONFER = '2' "
	cQuery += "    AND (((" + cAlias + cCpoDat1 + " >= DTQ_DATFEC AND " + cAlias + cCpoHor1 + " >= DTQ_HORFEC AND DTQ_DATFEC <> ' ' AND DTQ_HORFEC <> ' ')) "
	If cAlias != "DMK"
		cQuery += "    AND ((" + cAlias + cCpoDat1 + " <= DTQ_DATENC AND " + cAlias + cCpoHor1 + " <= DTQ_HORENC) OR "
		cQuery += "         (DTQ_DATENC = ' ' AND DTQ_HORENC = ' ' ))) "
	Else
		cQuery += "    AND ((" + cAlias + cCpoDat2 + " <= DTQ_DATENC AND " + cAlias + cCpoHor2 + " <= DTQ_HORENC) OR "
		cQuery += "         (DTQ_DATENC = ' ' AND DTQ_HORENC = ' ' ))) "
	EndIf
	cQuery += "    AND " + cAlias + ".D_E_L_E_T_ =  '' "
	
	cQuery += "  UNION ALL "
	
	cQuery += " SELECT " + cAlias + ".R_E_C_N_O_ REGISTRO,' ' FILORI,' ' VIAGEM,' ' TIPVIA,' ' NOMMOT,' ' CODVEI,0 VALPDG,DA3_COD DA3COD, "
	cQuery += "        DMI_NUMERO NUMERO, " + cAlias + "_NUMCON NUMCON, " + cAlias + "_PLACA PLACA, "
	If cAlias == "DMJ"
		cQuery += "        " + cAlias + "_DATPAS DATPAS, " + cAlias + "_HORPAS HORPAS, " + cAlias + "_VALPAS VALPAS, "
		cQuery += "        " + cAlias + "_LOCAL LOCALI "
	ElseIf cAlias == "DMK"
		cQuery += "        " + cAlias + "_DATENT DATENT, " + cAlias + "_HORENT HORENT, " + cAlias + "_DATSAI DATSAI, " + cAlias + "_HORSAI HORSAI, " + cAlias + "_VALOR VALOR "
	ElseIf cAlias == "DMT"
		cQuery += "        " + cAlias + "_DATABA DATABA, " + cAlias + "_HORABA HORABA, " + cAlias + "_VALOR VALOR "
	EndIf
	cQuery += "   FROM " + RetSQLName(cAlias) + " " + cAlias + " "
	
	cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
	cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
	If Empty(cNumero)
		cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
	Else
		cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
	EndIf
	cQuery += "    AND DMI_CONFER = '2' "
	cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
	cQuery += "    AND DMI.D_E_L_E_T_ =  ''"

	cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3 "
	cQuery += "     ON DA3_FILIAL = '" + xFilial("DA3") +"' "
	cQuery += "    AND DA3_PLACA  = " + cAlias + "_PLACA "
	cQuery += "    AND DA3.D_E_L_E_T_ =  '' "
	
	cQuery += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) +"' "
	cQuery += "    AND " + cAlias + "_NUMCON = DMI_NUMERO "
	cQuery += "    AND " + cAlias + "_CONFER = '2' "
	cQuery += "    AND " + cAlias + ".D_E_L_E_T_ =  '' "
	
	cQuery += "    AND NOT EXISTS (SELECT 1 "
	cQuery += "                      FROM " + RetSQLName("DA3") + " DA3 "
	cQuery += "                     WHERE DA3_FILIAL = '" + xFilial("DA3") +"' "
	cQuery += "                       AND DA3_PLACA  = " + cAlias + "_PLACA "
	cQuery += "                       AND DA3.D_E_L_E_T_ =  '') "
	cQuery += "  ORDER BY REGISTRO "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	TCSetField(cAliasQry,"VALPDG","N",TamSx3("DTR_VALPDG")[1],TamSx3("DTR_VALPDG")[2])
	If cAlias == "DMJ"
		TCSetField(cAliasQry,"VALPAS","N",TamSx3("DMJ_VALPAS")[1],TamSx3("DMJ_VALPAS")[2])
	ElseIf cAlias == "DMK"
		TCSetField(cAliasQry,"VALOR" ,"N",TamSx3("DMK_VALOR")[1] ,TamSx3("DMK_VALOR")[2])
	ElseIf cAlias == "DMT"
		TCSetField(cAliasQry,"VALOR","N" ,TamSx3("DMT_VALOR")[1] ,TamSx3("DMT_VALOR")[2])
	EndIf
	
	While (cAliasQry)->(!Eof())
		&(cAlias + "->(DbGoTo((cAliasQry)->REGISTRO))")
		RecLock(cAlias,.F.)
		If Empty((cAliasQry)->VIAGEM)
			If Empty((cAliasQry)->DA3COD)
				&(cAlias + "->" + cAlias + "_TIPO   := '4'")	//-- Particular
			Else
				&(cAlias + "->" + cAlias + "_TIPO   := '2'")	//-- Sem Viagem
			EndIf
			cConfer := "2"	//-- Não
		Else
			&(cAlias + "->" + cAlias + "_FILORI := (cAliasQry)->FILORI")
			&(cAlias + "->" + cAlias + "_VIAGEM := (cAliasQry)->VIAGEM")
			&(cAlias + "->" + cAlias + "_NOMMOT := (cAliasQry)->NOMMOT")
			If (cAliasQry)->TIPVIA == "2"
				&(cAlias + "->" + cAlias + "_TIPO   := '3'")	//-- Viagem Vazia
			Else
				&(cAlias + "->" + cAlias + "_TIPO   := '1'")	//-- Com Viagem
			EndIf
			If cAlias == "DMJ"
				//-- Define informações para tentar localizar a praça de pedágio
				cPalavra := (cAliasQry)->LOCALI
				nPos := At(",",cPalavra) - 1
				If nPos == 5
					cCodRod  := Space(Len(DTZ->DTZ_CODROD))
					cCodExt  := SubStr(cPalavra,1,2) + "-" + SubStr(cPalavra,3,nPos - 2)
					cPalavra := SubStr(cPalavra,nPos + 2)
					DTZ->(DbSetOrder(3))
					If DTZ->(DbSeek(xFilial("DTZ") + cCodExt))
						cCodRod := DTZ->DTZ_CODROD
					EndIf
					nPos := At("KM",cPalavra) + 2
					If nPos == 4
						cPalavra := SubStr(cPalavra,nPos)
						nPos := At("+",cPalavra) - 1
						If nPos > 0
							nKM := Val(SubStr(cPalavra,1,nPos))
							cPalavra := SubStr(cPalavra,nPos + 2)
							nPos := At(",",cPalavra) - 1
							If nPos > 0
								nKM += (Val(SubStr(cPalavra,1,nPos)) / 1000)
							EndIf
						EndIf
					EndIf
				EndIf
				If (nLinha := Ascan(aPedagios,{|x| x[1] == (cAliasQry)->NUMERO .And. x[2] == (cAliasQry)->FILORI .And. x[3] == (cAliasQry)->VIAGEM .And. x[4] == (cAliasQry)->CODVEI})) > 0
					aPedagios[nLinha,6] += (cAliasQry)->VALPAS
					Aadd(aPedagios[nLinha,7],{cCodRod,nKM,(cAliasQry)->VALPAS})
				Else
					Aadd(aPedagios,{(cAliasQry)->NUMERO,(cAliasQry)->FILORI,(cAliasQry)->VIAGEM,(cAliasQry)->CODVEI,(cAliasQry)->VALPDG,(cAliasQry)->VALPAS,{{cCodRod,nKM,(cAliasQry)->VALPAS}}})
				EndIf
				cConfer := "9"	//-- Status provisório pois quando for passagem em pedágio, também será verificado o total da viagem no TMS Protheus
			Else
				cConfer := "1"	//-- Sim
			EndIf
		EndIf
		If cAlias == "DMJ"
			If ExistReg(cAlias,{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
							   {{cAlias + "_NUMCON",(cAliasQry)->NUMCON      ,Nil},;
							    {cAlias + "_PLACA" ,(cAliasQry)->PLACA       ,Nil},;
							    {cAlias + "_DATPAS",SToD((cAliasQry)->DATPAS),Nil},;
							    {cAlias + "_HORPAS",(cAliasQry)->HORPAS      ,Nil}},;
							   {cAlias + "_NUMCON",cAlias + "_PLACA",cAlias + "_DATPAS",cAlias + "_HORPAS"},.T.)
				cConfer := "3"	//-- Duplicidade
			EndIf
		ElseIf cAlias == "DMK"
			If ExistReg(cAlias,{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
							   {{cAlias + "_NUMCON",(cAliasQry)->NUMCON      ,Nil},;
							    {cAlias + "_PLACA" ,(cAliasQry)->PLACA       ,Nil},;
							    {cAlias + "_DATENT",SToD((cAliasQry)->DATENT),Nil},;
							    {cAlias + "_HORENT",(cAliasQry)->HORENT      ,Nil},;
							    {cAlias + "_DATSAI",SToD((cAliasQry)->DATSAI),Nil},;
							    {cAlias + "_HORSAI",(cAliasQry)->HORSAI      ,Nil}},;
							   {cAlias + "_NUMCON",cAlias + "_PLACA",cAlias + "_DATENT",cAlias + "_HORENT",cAlias + "_DATSAI",cAlias + "_HORSAI"},.T.)
				cConfer := "3"	//-- Duplicidade
			EndIf
		ElseIf cAlias == "DMT"
			If ExistReg(cAlias,{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
							   {{cAlias + "_NUMCON",(cAliasQry)->NUMCON      ,Nil},;
							    {cAlias + "_PLACA" ,(cAliasQry)->PLACA       ,Nil},;
							    {cAlias + "_DATABA",SToD((cAliasQry)->DATABA),Nil},;
							    {cAlias + "_HORABA",(cAliasQry)->HORABA      ,Nil}},;
							   {cAlias + "_NUMCON",cAlias + "_PLACA",cAlias + "_DATABA",cAlias + "_HORABA"},.T.)
				cConfer := "3"	//-- Duplicidade
			EndIf
		EndIf
		&(cAlias + "->" + cAlias + "_CONFER := '" + cConfer + "'")
		&(cAlias + "->(MsUnlock())")
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())

	//-- Confere também na passagem de pedágio o valor das passagens com o valor do TMS Protheus
	If cAlias == "DMJ"
		For nCntFor1 := 1 To Len(aPedagios)
			If aPedagios[nCntFor1,5] == aPedagios[nCntFor1,6]
				cConfer := "1"	//-- Sim
			Else
				cConfer := "2"	//-- Não
			EndIf
			
			//--Busca valores das praças de pedágio
			If cConfer == "2"
				If ValidPraca(aPedagios[nCntFor1,4],Aclone(aPedagios[nCntFor1,7]))
					cConfer := "1"
				EndIf
			EndIf
			
			cUpdate := " UPDATE " + RetSqlName("DMJ")
			cUpdate += "    SET DMJ_CONFER = '" + cConfer + "' "
			cUpdate += "  WHERE DMJ_FILIAL = '" + xFilial("DMJ") + "' "
			cUpdate += "    AND DMJ_NUMCON = '" + aPedagios[nCntFor1,1] + "' "
			cUpdate += "    AND DMJ_FILORI = '" + aPedagios[nCntFor1,2] + "' "
			cUpdate += "    AND DMJ_VIAGEM = '" + aPedagios[nCntFor1,3] + "' "
			cUpdate += "    AND DMJ_CONFER <> '3' "
			cUpdate += "    AND D_E_L_E_T_ = ' ' "
			TCSqlExec(cUpdate)
		Next nCntFor1
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ExcluiConc()
Exclui Conciliação

@author     Valdemar Roberto Mognon
@since      15/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ExcluiConc(cNumero) CLASS TMSBCAVIAFACIL
Local aArea     := GetArea()
Local cQuery    := ""
Local cTabelas  := "DMJDMKDMLDMMDMNDMT"
Local cAlias    := ""
Local nCntFor1  := 0

Default cNumero := ""

If !Empty(cNumero)
	If !Empty(DMI->DMI_PEDCOM)
		Help("",1,"TMSAC2202")	//-- "Conciliação com pedido de compras gerado." # "Exclua o pedido de compras."
	Else
		For nCntFor1 := 1 To 6
			cAlias := SubStr(cTabelas,nCntFor1 * 3 - 2,3)

			cQuery := " UPDATE " + RetSqlName(cAlias)
			cQuery += "    SET " + cAlias + "_CONFER = '2', "
			cQuery +=            + cAlias + "_TIPO   = '2' "
			If cAlias $ "DMJ:DMK:DMT"
				cQuery += ", "
				cQuery +=            + cAlias + "_FILORI = '" + Space(Len(DTQ->DTQ_FILORI)) + "', "
				cQuery +=            + cAlias + "_VIAGEM = '" + Space(Len(DTQ->DTQ_VIAGEM)) + "', "
				cQuery +=            + cAlias + "_NOMMOT = '" + Space(Len(DA4->DA4_NOME)) + "' "
			EndIf
			cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
			cQuery += "    AND " + cAlias + "_NUMCON = '" + cNumero + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			TCSqlExec(cQuery)
		Next nCntFor1

		RecLock("DMI",.F.)
		DMI->DMI_CONFER := StrZero(2,Len(DMI->DMI_CONFER))
		DMI->(MsUnlock())
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} FechaConc()
Fecha conciliação se todas as tabelas estiverem ok

@author     Valdemar Roberto Mognon
@since      17/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD FechaConc(cNumero,nValFat) CLASS TMSBCAVIAFACIL
Local aAreas    := {DMI->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasQry := ""
Local cTabelas  := "DMJDMKDMLDMMDMNDMT"
Local cAlias    := ""
Local nCntFor1  := 0
Local nValTot   := 0
Local lCont     := .T.

Default cNumero := DMI->DMI_NUMERO
Default nValFat := DMI->DMI_VALFAT

If !Empty(cNumero)
	For nCntFor1 := 1 To 6
		cAlias    := SubStr(cTabelas,nCntFor1 * 3 - 2,3)

		//-- Verifica quantidade
		cAliasQry := GetNextAlias()
		cQuery := "SELECT COUNT(" + cAlias + "_PLACA) QTDREG "
		cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
		cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cQuery += "   AND " + cAlias + "_NUMCON = '" + cNumero + "' "
		cQuery += "   AND " + cAlias + "_CONFER = '2' "
		cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDREG > 0
			lCont := .F.
			Exit
		EndIf
		(cAliasQry)->(DbCloseArea())

		//-- Verifica valor
		If lCont
			cAliasQry := GetNextAlias()
			cQuery := "SELECT "
			If cAlias == "DMJ"
				cQuery += "SUM(" + cAlias + "_VALPAS) VALOR "
			ElseIf cAlias == "DMM"
				cQuery += "SUM(" + cAlias + "_VALCRE) VALOR "
			Else
				cQuery += "SUM(" + cAlias + "_VALOR) VALOR "
			EndIf
			cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
			cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
			cQuery += "   AND " + cAlias + "_NUMCON = '" + cNumero + "' "
			cQuery += "   AND " + cAlias + "_CONFER = '1' "
			cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				If cAlias == "DMM"
					nValTot -= (cAliasQry)->VALOR
				Else
					nValTot += (cAliasQry)->VALOR
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Next nCntFor1
	
	If lCont .And. nValTot == nValFat
		DMI->(DbSetOrder(1))
		If DMI->(DbSeek(xFilial("DMI") + cNumero))
			Reclock("DMI",.F.)
			DMI->DMI_CONFER := StrZero(1,Len(DMI->DMI_CONFER))	//-- Conferido
			DMI->(MsUnlock())
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} DePara()
Função De <> Para para gravaçao dos campos

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function DePara(cArquivo, aCampos)

Local aDePara := {}
Local nCont   := 0
Local nPosCpo := 0

Default aCampos := {}

If cArquivo == "pedagio"
    aDePara := cpoPedag()
EndIf

If cArquivo == "estacionamento"
    aDePara:= cpoEstac()
EndIf

If cArquivo == "mensalidade"
    aDePara := cpoMensal()
EndIf

If cArquivo == "credito"
    aDePara := cpoCredito()
EndIf

If cArquivo == "adesao"
    aDePara := cpoAdesao()
EndIf

If cArquivo == "abastecimento"
    aDePara := cpoAbast()
EndIf

For nCont := 1 to Len(aDePara)
    nPosCpo := Ascan(aCampos, { |x| x == aDePara[nCont][1] }) 
    If nPosCpo > 0
        aCampos[nPosCpo] := aDePara[nCont][2]
    EndIf
Next nCont
    
Return { aCampos, aDePara }

//-----------------------------------------------------------------
/*/{Protheus.doc} GeraCab()
Gera cabeçalho

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function GeraCab(cNumFat, cDataRef, cCodFor, cLojFor, cCodTAG, nValFat)
Local aCab := {}

Default cNumFat  := ""
Default cDataRef := ""
Default cCodFor  := ""
Default cLojFor  := ""
Default cCodTAG  := ""
Default nValFat  := 0

Aadd( aCab , {"DMI_FILIAL"  , xFilial('DMI') 	, Nil })
Aadd( aCab , {"DMI_NUMERO"  , GETSX8NUM("DMI","DMI_NUMERO")             , Nil })  
Aadd( aCab , {"DMI_FATURA"  , cNumFat           , Nil })
Aadd( aCab , {"DMI_USULEI"  , __cUserId         , Nil })
Aadd( aCab , {"DMI_DATLEI"  , dDataBase         , Nil })
Aadd( aCab , {"DMI_CONFER"  , "2"               , Nil })
Aadd( aCab , {"DMI_REF"     , cDataRef          , Nil }) //MM/AAAA Periodo de refrência
Aadd( aCab , {"DMI_HORLEI"  , SubStr(Time(),1,2) + SubStr(Time(),4,2)   , Nil })
Aadd( aCab , {"DMI_CODFOR"  , cCodFor           , Nil })
Aadd( aCab , {"DMI_LOJFOR"  , cLojFor           , Nil })
Aadd( aCab , {"DMI_CODTAG"  , cCodTAG           , Nil })
Aadd( aCab , {"DMI_VALFAT"  , nValFat           , Nil })

Return aCab

//-----------------------------------------------------------------
/*/{Protheus.doc} cpoEstac()
Campos da Planilha para o Banco de Dados

@author     fabio marchiori sampaio
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoEstac()
Local aDePara   := {}

    aDePara := {;
        {"PLACA"	   ,"DMK_PLACA"         },;
        {"ENTRADA"	   ,"DMK_DATENT"        },;
        {"ENTRADA"     ,"DMK_HORENT"        },;
        {"SAIDA"	   ,"DMK_DATSAI"        },;
        {"SAIDA"       ,"DMK_HORSAI"        },;
        {"PERMANENCIA" ,"DMK_TMPEST"        },;
        {"NOME"	       ,"DMK_LOCAL"         },;
        {"VALOR"       ,"DMK_VALOR"         };
    }

Return aDePara

//-----------------------------------------------------------------
/*/{Protheus.doc} cpoPedag()
Campos da Planilha para o Banco de Dados

@author     fabio marchiori sampaio
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoPedag()

Local aDePara   := {}

    aDePara := {;
        {"PLACA"   , "DMJ_PLACA"        },;
        {"VALOR"   , "DMJ_VALPAS"       },;
        {"DATA"    , "DMJ_DATPAS"       },;
        {"HORA"    , "DMJ_HORPAS"       },;
        {"PRACA"   , "DMJ_LOCAL"        };
    }    

Return aDePara
//-----------------------------------------------------------------
/*/{Protheus.doc} cpoMensal()
Campos da Planilha para o Banco de Dados

@author     fabio marchiori sampaio
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoMensal()

Local aDePara   := {}

    aDePara := {;
        {"PLACA"   , "DML_PLACA"        },;
        {"VALOR"   , "DML_VALOR"        };
    } 

Return aDePara

//-----------------------------------------------------------------
/*/{Protheus.doc} cpoCredito()
Campos da Planilha para o Banco de Dados

@author     fabio marchiori sampaio
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoCredito()

Local aDePara   := {}

    aDePara := {;
        {"PLACA"    , "DMM_PLACA"        },;
        {"DESCRICAO", "DMM_MOTIVO"       },;
        {"DATA"     , "DMM_DATCRE"       },;
        {"HORA"     , "DMM_HORCRE"       },;
        {"VALOR"    , "DMM_VALCRE"       };
    }  

Return aDePara

//-----------------------------------------------------------------
/*/{Protheus.doc} cpoAdesao()
Campos da Planilha para o Banco de Dados

@author     fabio marchiori sampaio
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoAdesao()

Local aDePara   := {}

    aDePara := {;
        {"PLACA"    , "DMN_PLACA"        },;
        {"VALOR"    , "DMN_VALOR"        };
    }  

Return aDePara

//-----------------------------------------------------------------
/*/{Protheus.doc} cpoAbast()
Campos da Planilha para o Banco de Dados

@author     Valdemar Roberto Mognon
@since      13/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function cpoAbast()

Local aDePara   := {}

    aDePara := {;
        {"PLACA"    , "DMT_PLACA"        },;
        {"DATA"     , "DMT_DATABA"       },;
        {"HORA"     , "DMT_HORABA"       },;
        {"LOCAL"    , "DMT_POSTO"        },;
        {"VALOR"    , "DMT_VALOR"        };
    }  

Return aDePara

//-----------------------------------------------------------------
/*/{Protheus.doc} ExistReg()
Verifica se o registro já existe nas tabelas filho

@author     Valdemar Roberto Mognon
@since      14/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function ExistReg(cAlias,aCabec,aDados,aCpoChv,lDuplic)
Local aArea     := GetArea()
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""
Local nCntFor1  := 0

Default cAlias  := ""
Default aCabec  := {}
Default aDados  := {}
Default aCpoChv := {}
Default lDuplic := .F.

If !Empty(cAlias) .And. !Empty(aCabec) .And. !Empty(aDados) .And. !Empty(aCpoChv)
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(*) QTDREG "
	cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
	cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "

	For nCntFor1 := 1 To Len(aCpoChv)
		If "NUMCON" $ aCpoChv[nCntFor1]
			cQuery += "   AND " + aCpoChv[nCntFor1] + " = '" + aCabec[Ascan(aCabec,{|x| x[1] == "DMI_NUMERO"}),2] + "' "
		ElseIf "_DAT" $ aCpoChv[nCntFor1]
			cQuery += "   AND " + aCpoChv[nCntFor1] + " = '" + DToS(aDados[Ascan(aDados,{|x| x[1] == aCpoChv[nCntFor1]}),2]) + "' "
		Else
			cQuery += "   AND " + aCpoChv[nCntFor1] + " = '" + aDados[Ascan(aDados,{|x| x[1] == aCpoChv[nCntFor1]}),2] + "' "
		EndI
	Next nCntFor1
	
	cQuery += "     AND " + cAlias + ".D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDREG > 0
		//-- Somente verifica quantidade maior ou igual a 2 para verificar duplicidade
		If (lDuplic .And. (cAliasQry)->QTDREG > 1) .Or. !lDuplic
			lRet := .T.
		EndIf
	EndIf
	
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aArea)
FwFreeArray(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ConcAdesoes()
Concilia as adesoes

@author     Fabio Marchiori Sampaio
@since      17/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ConcAdesoes(cNumero,cCodTAG) CLASS TMSBCAVIAFACIL

Local cQuery    := ""
Local cAliasQry := ""
Local dDatIni := CToD("")
Local dDatFim := CToD("")
Local cDias   := "312831303130313130313031"
Local cConfer := ""
Local nAno    := 0
Local nMes    := 0
Local cRef    := ""

Default cNumero := ""
Default cCodTAG := ""

If Empty(cNumero)
	cRef := Self:cRef
Else
	cRef := DMI->DMI_REF
EndIf

dDatIni := CToD("01/" + Left(cRef,2) + "/" + Right(cRef,4))
nMes := Val(SubStr(cRef,1,2))
nAno := Val(SubStr(cRef,4,4))
If nMes == 2
	If (nAno % 4) == 0
		StrTran(cDias,"28","29")
	EndIf
EndIf
dDatFim := StoD(StrZero(nAno,4) + StrZero(nMes,2) + SubStr(cDias,nMes * 2 -1,2))

cAliasQry := GetNextAlias()
cQuery := " SELECT DMN.R_E_C_N_O_ REGISTRO,1 TIPO, DMG_ADEPED DTADESAO, "
cQuery += "        DMI_NUMERO NUMERO, DMN_NUMCON NUMCON, DMN_PLACA PLACA "
cQuery += "   FROM " + RetSQLName("DMN") + " DMN "

cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
If Empty(cNumero)
	cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
Else
	cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
EndIf
cQuery += "    AND DMI_CONFER = '2' "
cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
cQuery += "    AND DMI.D_E_L_E_T_ =  ''"

cQuery += "   JOIN " + RetSQLName("DA3") + " DA3 "
cQuery += "     ON DA3_FILIAL = '" + xFilial("DA3") +"' "
cQuery += "    AND DA3_PLACA  = DMN_PLACA "
cQuery += "    AND DA3.D_E_L_E_T_ =  '' "

cQuery += "   JOIN " + RetSQLName("DMG") + " DMG "
cQuery += "     ON DMG_FILIAL = '" + xFilial("DMG") +"' "
cQuery += "    AND DMG_CODVEI = DA3_COD "
If Empty(cCodTAG)
	cQuery += "    AND DMG_CODTAG = '" + Self:cCodTAG + "' "
Else
	cQuery += "    AND DMG_CODTAG = '" + cCodTAG + "' "
EndIf
cQuery += "    AND DMG_ADEPED BETWEEN '" + Dtos(dDatIni) + "' AND '" + DTos(dDatFim) + "' "
cQuery += "    AND DMG_VALADE = DMN_VALOR "	//-- Verifica o valor real da adesão
cQuery += "    AND DMG.D_E_L_E_T_ =  '' "

cQuery += "	 WHERE DMN_FILIAL = '" + xFilial("DMN") +"' "
cQuery += "    AND DMN_NUMCON = DMI_NUMERO "
cQuery += "    AND DMN_CONFER = '2' "
cQuery += "    AND DMN.D_E_L_E_T_ =  '' "

cQuery += "  UNION ALL "

cQuery += " SELECT DMN.R_E_C_N_O_ REGISTRO,2 TIPO, ' ' DTADESAO, "
cQuery += "        DMI_NUMERO NUMERO, DMN_NUMCON NUMCON, DMN_PLACA PLACA "
cQuery += "   FROM " + RetSQLName("DMN") + " DMN "

cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
If Empty(cNumero)
	cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
Else
	cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
EndIf
cQuery += "    AND DMI_CONFER = '2' "
cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
cQuery += "    AND DMI.D_E_L_E_T_ =  ''"

cQuery += "	 WHERE DMN_FILIAL = '" + xFilial("DMN") + "' "
cQuery += "    AND DMN_NUMCON = DMI_NUMERO "
cQuery += "    AND DMN_CONFER = '2' "
cQuery += "    AND DMN.D_E_L_E_T_ =  '' "

cQuery += "    AND NOT EXISTS (SELECT 1 "
cQuery += "                      FROM " + RetSQLName("DA3") + " DA3 "
cQuery += "                     WHERE DA3_FILIAL = '" + xFilial("DA3") +"' "
cQuery += "                       AND DA3_PLACA  = DMN_PLACA "
cQuery += "                       AND DA3.D_E_L_E_T_ =  '') "
cQuery += "  ORDER BY REGISTRO "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	DMN->(DbGoTo((cAliasQry)->REGISTRO))
	RecLock("DMN",.F.)
	If (cAliasQry)->TIPO == 2
		DMN->DMN_TIPO   := '2'	//-- Particular
		cConfer := "2"	//-- Não
	Else
		DMN->DMN_TIPO   := '1'	//-- Frota
		cConfer := "1"	//-- Sim
	EndIf
	If ExistReg("DMN",{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
					  {{"DMN_NUMCON",(cAliasQry)->NUMCON,Nil},;
					   {"DMN_PLACA" ,(cAliasQry)->PLACA ,Nil}},;
					  {"DMN_NUMCON","DMN_PLACA"},.T.)
		cConfer := "3"	//-- Duplicidade
	EndIf
	DMN->DMN_CONFER := cConfer
	DMN->(MsUnlock())
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ConcCredito()
Concilia as adesoes

@author     Fabio Marchiori Sampaio
@since      17/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ConcCredito(cNumero) CLASS TMSBCAVIAFACIL

Local cQuery    := ""
Local cAliasQry := ""
Local cConfer   := ""

Default cNumero := ""

cAliasQry := GetNextAlias()
	cQuery := " SELECT DMM.R_E_C_N_O_ REGISTRO,1 TIPO, "
	cQuery += "        DMI_NUMERO NUMERO, DMM_NUMCON NUMCON, DMM_PLACA PLACA, DMM_DATCRE DATCRE, DMM_HORCRE HORCRE "
	cQuery += "   FROM " + RetSQLName("DMM") + " DMM "
	
	cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
	cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
	If Empty(cNumero)
		cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
	Else
		cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
	EndIf
	cQuery += "    AND DMI_CONFER = '2' "
	cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
	cQuery += "    AND DMI.D_E_L_E_T_ =  ''"
	
	cQuery += "   JOIN " + RetSQLName("DA3") + " DA3 "
	cQuery += "     ON DA3_FILIAL = '" + xFilial("DA3") +"' "
	cQuery += "    AND DA3_PLACA  = DMM_PLACA "
	cQuery += "    AND DA3.D_E_L_E_T_ =  '' "
	
	cQuery += "	 WHERE DMM_FILIAL = '" + xFilial("DMM") +"' "
	cQuery += "    AND DMM_NUMCON = DMI_NUMERO "
	cQuery += "    AND DMM_CONFER = '2' "
	cQuery += "    AND DMM.D_E_L_E_T_ =  '' "
	
	cQuery += "  UNION ALL "
	
	cQuery += " SELECT DMM.R_E_C_N_O_ REGISTRO,2 TIPO, "
	cQuery += "        DMI_NUMERO NUMERO, DMM_NUMCON NUMCON, DMM_PLACA PLACA, DMM_DATCRE DATCRE, DMM_HORCRE HORCRE "
	cQuery += "   FROM " + RetSQLName("DMM") + " DMM "
	
	cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
	cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
	If Empty(cNumero)
		cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
	Else
		cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
	EndIf
	cQuery += "    AND DMI_CONFER = '2' "
	cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
	cQuery += "    AND DMI.D_E_L_E_T_ =  ''"
	
	cQuery += "	 WHERE DMM_FILIAL = '" + xFilial("DMM") + "' "
	cQuery += "    AND DMM_NUMCON = DMI_NUMERO "
	cQuery += "    AND DMM_CONFER = '2' "
	cQuery += "    AND DMM.D_E_L_E_T_ =  '' "
	
	cQuery += "    AND NOT EXISTS (SELECT 1 "
	cQuery += "                      FROM " + RetSQLName("DA3") + " DA3 "
	cQuery += "                     WHERE DA3_FILIAL = '" + xFilial("DA3") +"' "
	cQuery += "                       AND DA3_PLACA  = DMM_PLACA "
	cQuery += "                       AND DA3.D_E_L_E_T_ =  '') "
	cQuery += "  ORDER BY REGISTRO "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

    While (cAliasQry)->(!Eof())
		DMM->(DbGoTo((cAliasQry)->REGISTRO))
		RecLock("DMM",.F.)
		If (cAliasQry)->TIPO == 2
			DMM->DMM_TIPO   := '2'	//-- Particular
			cConfer := "2"	//-- Não
		Else
			DMM->DMM_TIPO   := '1'	//-- Frota
		EndIf
		If ExistReg("DMM",{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
						  {{"DMM_NUMCON",(cAliasQry)->NUMCON      ,Nil},;
						   {"DMM_PLACA" ,(cAliasQry)->PLACA       ,Nil},;
						   {"DMM_DATCRE",SToD((cAliasQry)->DATCRE),Nil},;
						   {"DMM_HORCRE",(cAliasQry)->HORCRE      ,Nil}},;
						  {"DMM_NUMCON","DMM_PLACA"},.T.)
			cConfer := "3"	//-- Duplicidade
		EndIf
		DMM->DMM_CONFER := cConfer
		DMM->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo

(cAliasQry)->(DbCloseArea())

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ConcMensalidade()
Concilia as Mensalidade

@author     Fabio Marchiori Sampaio
@since      17/09/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD ConcMensalidade(cNumero,cCodTAG) CLASS TMSBCAVIAFACIL

Local cQuery    := ""
Local cAliasQry := ""
Local dDatFim   := CToD("")
Local cDias     := "312831303130313130313031"
Local cConfer   := ""
Local nAno      := 0
Local nMes      := 0
Local cRef      := ""

Default cNumero := ""
Default cCodTAG := ""

If Empty(cNumero)
	cRef := Self:cRef
Else
	cRef := DMI->DMI_REF
EndIf

nMes := Val(SubStr(cRef,1,2))
nAno := Val(SubStr(cRef,4,4))
If nMes == 2
	If (nAno % 4) == 0
		StrTran(cDias,"28","29")
	EndIf
EndIf
dDatFim := StoD(StrZero(nAno,4) + StrZero(nMes,2) + SubStr(cDias,nMes * 2 -1,2))

cAliasQry := GetNextAlias()
cQuery := " SELECT DML.R_E_C_N_O_ REGISTRO,1 TIPO, DMG_ADEPED DTADESAO, "
cQuery += "        DMI_NUMERO NUMERO, DML_NUMCON NUMCON, DML_PLACA PLACA "
cQuery += "   FROM " + RetSQLName("DML") + " DML "

cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
If Empty(cNumero)
	cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
Else
	cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
EndIf
cQuery += "    AND DMI_CONFER = '2' "
cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
cQuery += "    AND DMI.D_E_L_E_T_ =  ''"

cQuery += "   JOIN " + RetSQLName("DA3") + " DA3 "
cQuery += "     ON DA3_FILIAL = '" + xFilial("DA3") +"' "
cQuery += "    AND DA3_PLACA  = DML_PLACA "
cQuery += "    AND DA3.D_E_L_E_T_ =  '' "

cQuery += "   JOIN " + RetSQLName("DMG") + " DMG "
cQuery += "     ON DMG_FILIAL = '" + xFilial("DMG") +"' "
cQuery += "    AND DMG_CODVEI = DA3_COD "
If Empty(cCodTAG)
	cQuery += "    AND DMG_CODTAG = '" + Self:cCodTAG + "' "
Else
	cQuery += "    AND DMG_CODTAG = '" + cCodTAG + "' "
EndIf
cQuery += "    AND DMG_ADEPED <= '" + Dtos(dDatFim) + "' "
cQuery += "    AND DMG_VALMEN = DML_VALOR "	//-- Verifica o valor real da mensalidade
cQuery += "    AND DMG.D_E_L_E_T_ =  '' "

cQuery += "	 WHERE DML_FILIAL = '" + xFilial("DML") +"' "
cQuery += "    AND DML_NUMCON = DMI_NUMERO "
cQuery += "    AND DML_CONFER = '2' "
cQuery += "    AND DML.D_E_L_E_T_ =  '' "

cQuery += "  UNION ALL "

cQuery += " SELECT DML.R_E_C_N_O_ REGISTRO,2 TIPO, ' ' DTADESAO, "
cQuery += "        DMI_NUMERO NUMERO, DML_NUMCON NUMCON, DML_PLACA PLACA "
cQuery += "   FROM " + RetSQLName("DML") + " DML "

cQuery += "   JOIN " + RetSQLName("DMI") + " DMI "
cQuery += "	    ON DMI_FILIAL = '" + xFilial("DMI") +"' "
If Empty(cNumero)
	cQuery += "    AND DMI_REF    = '" + Self:cRef + "' "
Else
	cQuery += "    AND DMI_NUMERO = '" + cNumero + "' "
EndIf
cQuery += "    AND DMI_CONFER = '2' "
cQuery += "    AND DMI_PEDCOM = '" + Space(Len(DMI->DMI_PEDCOM)) + "' "
cQuery += "    AND DMI.D_E_L_E_T_ =  ''"

cQuery += "	 WHERE DML_FILIAL = '" + xFilial("DML") + "' "
cQuery += "    AND DML_NUMCON = DMI_NUMERO "
cQuery += "    AND DML_CONFER = '2' "
cQuery += "    AND DML.D_E_L_E_T_ =  '' "

cQuery += "    AND NOT EXISTS (SELECT 1 "
cQuery += "                      FROM " + RetSQLName("DA3") + " DA3 "
cQuery += "                     WHERE DA3_FILIAL = '" + xFilial("DA3") +"' "
cQuery += "                       AND DA3_PLACA  = DML_PLACA "
cQuery += "                       AND DA3.D_E_L_E_T_ =  '') "
cQuery += "  ORDER BY REGISTRO "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	DML->(DbGoTo((cAliasQry)->REGISTRO))
	RecLock("DML",.F.)
	If (cAliasQry)->TIPO == 2
		DML->DML_TIPO   := '2'	//-- Particular
		cConfer := "2"	//-- Não
	Else
		DML->DML_TIPO   := '1'	//-- Frota
		cConfer := "1"	//-- Sim
	EndIf
	If ExistReg("DML",{{"DMI_NUMERO",(cAliasQry)->NUMERO,Nil}},;
					  {{"DML_NUMCON",(cAliasQry)->NUMCON,Nil},;
					   {"DML_PLACA" ,(cAliasQry)->PLACA ,Nil}},;
					  {"DML_NUMCON","DML_PLACA"},.T.)
		cConfer := "3"	//-- Duplicidade
	EndIf
	DML->DML_CONFER := cConfer
	DML->(MsUnlock())
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} InsTarifa()
Grava os arquivos com as tarifas da ANCR

@author     Valdemar Roberto Mognon
@since      10/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD InsTarifa() CLASS TMSBCAVIAFACIL
Local cProximo  := ""
Local cItem     := ""
Local cSeqDU0   := ""
Local aAreas    := {DTZ->(GetArea()),DU0->(GetArea()),DYP->(GetArea()),GetArea()}
Local aCampos   := Aclone(::aResult[1,2])
Local aDados    := Aclone(::aResult[1,3])
Local aTipos    := {}
Local nPosRodov := 0
Local nPosCateg := 0
Local nPosEixos := 0
Local nPosValor := 0
Local nPosKm    := 0
Local nPosCat   := 0
Local nCntFor1  := 0
Local nCntFor2  := 0

If !Empty(aDados)
	Limpa()

	nPosRodov := Ascan(aCampos,{|x| x= "Rodovia"})
	nPosCateg := Ascan(aCampos,{|x| x= "Descricao categoria"})
	nPosEixos := Ascan(aCampos,{|x| x= "Eixos"})
	nPosValor := Ascan(aCampos,{|x| x= "Valor"})
	nPosKm    := Ascan(aCampos,{|x| x= "KM"})
	nPosCat   := Ascan(aCampos,{|x| x= "Cat."})

	DTZ->(DbSetOrder(3))
	DYP->(DbSetOrder(2))
	For nCntFor1 := 1 To Len(aDados)

		//-- Atualiza rodovia
		If !DTZ->(DbSeek(xFilial("DTZ") + aDados[nCntFor1,nPosRodov]))
			cProximo := Proximo("DTZ")
			RecLock("DTZ",.T.)
			DTZ->DTZ_FILIAL := xFilial("DTZ")
			DTZ->DTZ_CODROD := cProximo
			DTZ->DTZ_NOMROD := "Rodovia " + aDados[nCntFor1,nPosRodov]
			DTZ->DTZ_CODEXT := aDados[nCntFor1,nPosRodov]
			DTZ->(MsUnlock())
		EndIf

		//-- Atualiza praça de pedágio
		If Empty(cSeqDU0 := BuscaPraca(DTZ->DTZ_CODROD,aDados[nCntFor1,nPosKm]))
			cProximo := Proximo("DU0",DTZ->DTZ_CODROD)
			RecLock("DU0",.T.)
			DU0->DU0_FILIAL := xFilial("DU0")
			DU0->DU0_CODROD := DTZ->DTZ_CODROD
			DU0->DU0_SEQPDG := cProximo
			DU0->DU0_CODFOR := ::cCodFor
			DU0->DU0_LOJFOR := ::cLojFor
			DU0->DU0_KM     := aDados[nCntFor1,nPosKm]
			DU0->DU0_VALEIX := Round(aDados[nCntFor1,nPosValor] / 2,2)
			DU0->DU0_VALVEI := aDados[nCntFor1,nPosValor]
			DU0->(MsUnlock())
			cSeqDU0 := cProximo
		EndIf

		//-- Atualiza praça de pedágio por tipo de veículo
		aTipos := BuscaTipos(aDados[nCntFor1,nPosCat])
		For nCntFor2 := 1 To Len(aTipos)
			If !DYP->(DbSeek(xFilial("DYP") + DTZ->DTZ_CODROD + cSeqDU0 + aTipos[nCntFor2]))
				cItem := Proximo("DYP",DTZ->DTZ_CODROD,cSeqDU0)
				RecLock("DYP",.T.)
				DYP->DYP_FILIAL := xFilial("DYP")
				DYP->DYP_ITEM   := cItem
				DYP->DYP_CODROD := DTZ->DTZ_CODROD
				DYP->DYP_SEQPDG := cSeqDU0
				DYP->DYP_TIPVEI := aTipos[nCntFor2]
				DYP->DYP_VALOR  := aDados[nCntFor1,nPosValor]
				DYP->(MsUnlock())
			EndIf
		Next nCntFor2

	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Limpa()
Limpa os registros para nova importação

@author     Valdemar Roberto Mognon
@since      10/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function Limpa()
Local cQuery := ""

cQuery := "DELETE "
cQuery += "  FROM " + RetSqlName("DTZ")
cQuery += " WHERE DTZ_FILIAL = '" + xFilial("DTZ") + "' "
TcSqlExec(cQuery)

cQuery := "DELETE "
cQuery += "  FROM " + RetSqlName("DU0")
cQuery += " WHERE DU0_FILIAL = '" + xFilial("DU0") + "' "
TcSqlExec(cQuery)

cQuery := "DELETE "
cQuery += "  FROM " + RetSqlName("DYP")
cQuery += " WHERE DYP_FILIAL = '" + xFilial("DYP") + "' "
TcSqlExec(cQuery)

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Proximo()
Localiza o próximo registro na tabela de praças de pedágio

@author     Valdemar Roberto Mognon
@since      10/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function Proximo(cAlias,cCodRod,cSeqDU0)
Local cRet      := ""
Local cQuery    := ""
Local cAliasQry := ""
Local aArea     := GetArea()

cAliasQry := GetNextAlias()
If cAlias == "DTZ"
	cQuery := "SELECT MAX(DTZ_CODROD) ULTIMO "
ElseIf cAlias == "DU0"
	cQuery := "SELECT MAX(DU0_SEQPDG) ULTIMO "
Else
	cQuery := "SELECT MAX(DYP_ITEM) ULTIMO "
EndIf
cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
If cAlias $ "DU0:DYP"
	cQuery += "   AND " + cAlias + "_CODROD = '" + cCodRod + "' "
	If cAlias == "DYP"
		cQuery += "   AND " + cAlias + "_SEQPDG = '" + cSeqDU0 + "' "
	EndIf
EndIf
cQuery += "   AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->ULTIMO)
	cRet := StrZero(1,Iif(cAlias == "DTZ",Len(DTZ->DTZ_CODROD),Iif(cAlias == "DU0",Len(DU0->DU0_SEQPDG),Len(DYP->DYP_ITEM))))
Else
	cRet := Soma1((cAliasQry)->ULTIMO)
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} BuscaTipos()
Busca os tipos de veículos por meio da categoria da Via Fácil

@author     Valdemar Roberto Mognon
@since      10/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function BuscaTipos(cCategoria)
Local aRet      := {}
Local cQuery    := ""
Local cAliasQry := ""
Local aArea     := GetArea()

Default cCategoria := ""

cAliasQry  := GetNextAlias()
cQuery := "SELECT DUT_TIPVEI "
cQuery += "  FROM " + RetSQLName("DUT") + " DUT "
cQuery += " WHERE DUT_FILIAL = '" + xFilial("DUT") + "' "
cQuery += "   AND DUT_CATEXT = '" + cCategoria + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->(!Eof())
	Aadd(aRet,(cAliasQry)->DUT_TIPVEI)
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return Aclone(aRet)

//-----------------------------------------------------------------
/*/{Protheus.doc} BuscaPraca()
Busca Sequencia da Praça de Pedágio da Rodovia pelo KM

@author     Valdemar Roberto Mognon
@since      13/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function BuscaPraca(cCodRod,nKM)
Local cRet      := ""
Local cQuery    := ""
Local cAliasQry := ""
Local aArea     := GetArea()

cAliasQry  := GetNextAlias()
cQuery := "SELECT DU0_SEQPDG "
cQuery += "  FROM " + RetSQLName("DU0") + " DU0 "
cQuery += " WHERE DU0_FILIAL = '" + xFilial("DU0") + "' "
cQuery += "   AND DU0_CODROD = '" + cCodRod + "' "
cQuery += "   AND DU0_KM     = " + AllTrim(Str(nKM)) + " "
cQuery += "   AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If (cAliasQry)->(!Eof())
	cRet = (cAliasQry)->DU0_SEQPDG
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ValidPraca()
Valida os valores das praças de pedágio

@author     Valdemar Roberto Mognon
@since      13/01/2022
@version    1.0 
/*/
//--------------------------------------------------------------------
Static Function ValidPraca(cCodVei,aPracas)
Local aAreas    := {GetArea()}
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local nCntFor1  := 0

For nCntFor1 := 1 To Len(aPracas)
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DU0_VALVEI,DYP_VALOR "
	cQuery += "   FROM " + RetSQLName("DU0") + " DU0 "

	cQuery += "   LEFT OUTER JOIN " + RetSQLName("DYP") + " DYP "
	cQuery += "	    ON DYP_FILIAL = '" + xFilial("DYP") +"' "
	cQuery += "    AND DYP_CODROD = DU0_CODROD "
	cQuery += "    AND DYP_SEQPDG = DU0_SEQPDG "
	cQuery += "    AND DYP_TIPVEI = '" + DA3->DA3_TIPVEI + "' "
	cQuery += "    AND DYP.D_E_L_E_T_ =  '' "
	
	cQuery += "	 WHERE DU0_FILIAL = '" + xFilial("DU0") +"' "
	cQuery += "    AND DU0_CODROD = '" + aPracas[nCntFor1,1] + "' "
	cQuery += "    AND DU0_KM     = " + AllTrim(Str(aPracas[nCntFor1,2])) + " "
	cQuery += "    AND DU0.D_E_L_E_T_ =  '' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(!Eof())
		If (cAliasQry)->DYP_VALOR > 0
			If (cAliasQry)->DYP_VALOR != aPracas[nCntFor1,3]
				lRet := .F.
			EndIf
		Else
			If (cAliasQry)->DU0_VALVEI != aPracas[nCntFor1,3]
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	If !lRet
		Exit
	EndIf
Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

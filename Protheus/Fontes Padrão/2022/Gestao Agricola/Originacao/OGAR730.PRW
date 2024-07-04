#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OGAR730.CH"      

Static __dTcertf := dDataBase

/*/{Protheus.doc} OGAR730
Programa de impressão do certificado de peso dos contêineres da intrução de embarque.
@type  Function
@author rafael.kleestadt
@since 05/01/2018
@version 1.0
@param param, param_type, param_descr
@return returno,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function OGAR730()
	Local aAdvSize	   := {}
	Local aInfoAdvSize := {}
	Local aObjSize	   := {}
	Local aObjCoords   := {}	
	Private _oDlg	   := NIL
	Private	_cPerg	   := "OGAR730"    
    Private _nTotFrd   := 0

	//Carrega os paremetros da impressão conforme dados das perguntas(OGAR730)
	Pergunte(_cPerg,.F.)

	//*===========================================================================================================================================
	//*	Monta as Dimensoes dos Objetos                					           					    					  
	//*===========================================================================================================================================
	aAdvSize	 := MsAdvSize()
	aAdvSize[5]	 := (aAdvSize[5]/100) * 60	//horizontal
	aAdvSize[6]	 := (aAdvSize[6]/100) * 40	//Vertical
	aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord := { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	//1,3 Vertical /1,4 Horizontal

	DEFINE MSDIALOG _oDlg TITLE OemToAnsi(STR0001) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Integração Com Ms-word"
	
	@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
	@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0002) PIXEL //"Impressão de documentos no Word."
	@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0003) PIXEL //"O arquivo será impresso de acordo com a seleção dos parâmetros."

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Pergunte(_cPerg,.T.)
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0019) SIZE 55,11 ACTION fVarW_Imp()	//"Impr. _Variáveis"  
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5  BUTTON OemToAnsi(STR0004) SIZE 55,11 ACTION Imprime() //"Impr. _Documento"
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(_oDlg)
	
	ACTIVATE DIALOG _oDlg CENTERED

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Imprime
Impressão dos documentos
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Imprime()
    
    Processa( {|| WordImp() }, STR0028+"...") //Aguarde

Return

/*/{Protheus.doc} WordImp()
Função principal de impressão do arquivo word.
@type  Function
@author rafael.kleestadt	
@since 29/12/2017
@version 1.0
@param param, param_type, param_descr
@return return,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function WordImp()
	Local aCnts    := {}
	Local aCampos  := {}
	Local aRet     := {}
	Local aAgruCnt := {}
	Local nX       := 0
    Local nY       := 0
    Local nPos     := 0
	Local cArqWord := mv_par01
	Local cDestino := mv_par02
	Local cN91Memo := ""    
    Local cMsg     := ""
    Local aGerados := {}
    Local nTotPesB := 0
    Local nTotPesT := 0
    Local nTotPesL := 0
	Private _oWord := Nil    
    Private _lPrint    := .F.
    
    _lPrint := Iif(MV_PAR03 == 1, .F., .T.)
    
    If Empty(cArqWord) .Or. Empty(cDestino)
        Help(" ", 1, "OGAR730PARVAZI") //##Problema: Um dos parâmetros não foi informado.
                                        //##Solução: Informe todos os parâmetros corretamente para gerar o certificado de peso.
        Return	
    EndIf

    nPos := Rat("\",cDestino)
    If nPos = 0
        cDestino := cDestino + "\"
    EndIF

    /* Conecta ao word */
    _oWord := OLE_CreateLinX()
    
    If (_oWord != "0")
        Alert(STR0029) //MS-WORD não encontrado nessa máquina!
        Return
    EndIf
    
    aAgruCnt := fAgrpCnt()
    
    ProcRegua(Len(aAgruCnt))

    For nX := 1 To Len(aAgruCnt)    
        IncProc(STR0030 + "...")  //Processando documento
        aCnts := aAgruCnt[nX,2]        
        cNomeAq  := "DRAFT WEIGHT CERTIFICATE_"+ (aAgruCnt[nX,1]) +".docx"	//"DRAFT WEIGHT CERTIFICATE_"            
        
        //Monta o arquivo texto que será enviado para a macro do word criar a tabela
        cN91Memo := ""
        _nTotFrd := 0
        nTotPesB := 0
        nTotPesT := 0
        nTotPesL := 0
        For nY := 1 to Len(aCnts)
            _nTotFrd += aCnts[nY][2]
            nTotPesB += aCnts[nY][4]
            nTotPesT += aCnts[nY][5]
            nTotPesL += aCnts[nY][6]

            cN91Memo += aCnts[nY][1]      + "#*" //AGR_NRCNT	   
            cN91Memo += Str(aCnts[nY][2]) + "#*" //AGR_QTDFRDCNT
            cN91Memo += aCnts[nY][3]      + "#*" //AGR_LACRE
            cN91Memo += Str(aCnts[nY][4]) + "#*" //AGR_PSBRUTCNT
            cN91Memo += Str(aCnts[nY][5]) + "#*" //AGR_TARA
            cN91Memo += Str(aCnts[nY][6]) + "#*" //AGR_PSLIQCNT                
        Next nY            

        cN91Memo += "TOTAL"       + "#*" //AGR_NRCNT	    
        cN91Memo += Str(_nTotFrd) + "#*" //AGR_QTDFRDCNT
        cN91Memo += ""            + "#*" //AGR_LACRE
        cN91Memo += Str(nTotPesB) + "#*" //AGR_PSBRUTCNT
        cN91Memo += Str(nTotPesT) + "#*" //AGR_TARA
        cN91Memo += Str(nTotPesL) + "#*" //AGR_PSLIQCNT                
        
        aCampos  := fCposWord(aAgruCnt[nX,1])
        
        //Pondo de entrada destinado a adicionar novos campos no documento word
        //Exemplo:
        //VARIAVEL PARA WORD , VARIAVEL DE IMPRESSAO, VARIAVEL DE PICTURE, DESCRIÇÃO VARIAVEIS
        //aAdd( aExp, {'AGR_DESPRO'		 , cProdut      		, "SB1->B1_DESC"     , STR0010             }) //"GOODS DESCRIPTION"
        If ExistBlock('AGR730VAR')
            aRet := ExecBlock('AGR730VAR',.F.,.F.,aCampos)
            If ValType(aRet) == 'A'
                aCampos	:= aClone(aRet)
            EndIf
        EndIf

        BeginMsOle()
            OLE_NewFile( _oWord, cArqWord )            
            
            If _lPrint
                OLE_SetProperty(_oWord,oleWdVisible,  .F.)
                OLE_SetProperty(_oWord,oleWdPrintBack,.T.)
            Else
                OLE_SetProperty(_oWord,oleWdVisible,  .F.)
                OLE_SetProperty(_oWord,oleWdPrintBack,.F.)
            EndIf

            /* Ajustando as Variaveis do Documento */
            Aeval( aCampos																								 ,;
                    { |x| OLE_SetDocumentVar( _oWord, x[1]  																 ,;
                                                IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          					 ,;
                                                    Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		 ,;
                                                                                Subst( AllTrim( x[3] )  				 ,;
                                                                                        - ( Len( AllTrim( x[3] ) ) - 5 )  ;
                                                                                    )	  	 							  ;
                                                                                )                                         ;
                                                            )															 ,;
                                                            Transform( x[2] , x[3] )                                      ;
                                                    ) 														 	 		  ;
                                            )																			  ;
                    }     																 							 	  ;
                )

            OLE_SetDocumentVar(_oWord, "cParam01", cN91Memo) 				  //Envia para a variavel de documento o conteudo completo da tabela
            OLE_SetDocumentVar(_oWord, "cParam02", AllTrim(Str(Len(aCnts)+2))) //Envia para a variavel de documento a qtd de linhas da tabela
            OLE_ExecuteMacro(_oWord, "tabitens") 							  //Executa macro do Word que cria a tabela e insere o conteudo do cMemo
            OLE_SetDocumentVar(_oWord, "cParam01", "") 						  //Limpa variavel
            OLE_SetDocumentVar(_oWord, "cParam02", "") 						  //Limpa variavel            

            /* Atualizando as variaveis do documento do Word */
            OLE_UpdateFields(_oWord)         

            If _lPrint
                /* Imprimindo o Documento */
                OLE_SetProperty( _oWord, '208', .F. ) 
                OLE_PrintFile( _oWord, "ALL",,, 1 )                
            Else
                /* Salva o arquivo de destino */
                OLE_SaveAsFile( _oWord, Alltrim(cDestino)+Alltrim(cNomeAq) )
            EndIf
            
            aAdd(aGerados,Alltrim(cDestino)+Alltrim(cNomeAq))
            
        Next nX  
    EndMsOle()    
    
    /* Encerrando o LinX com o Documento */
    OLE_CloseLinX(_oWord)       
    
    If _lPrint
       cMsg := STR0031 + iif(Len(aGerados) > 0, "s "," ") + STR0032 + iif(Len(aGerados) > 0, "s "," ") +STR0033 //Documento enviado para impressora  
       MsgInfo(cMsg)
    Else
        cMsg := STR0034 //"Processamento finalizado com sucesso."

        If MsgYesNo(cMsg + STR0035) //" Deseja visualizar os arquivos gerados?"
            For nX := 1 to Len(aGerados)
                /* Abre o MS Word */
                ShellExecute( "Open", aGerados[nX], " "," ", 3 )
            Next nX
        EndIf
    EndIf      

	_oDlg:End()

Return()

/*/{Protheus.doc} PROCMODEL()
Validação do tipo de arquivo(modelo) word a ser usado como documento de origem.
@type  Function
@author rafael.kleestadt	
@since 29/12/2017
@version 1.0
@param param, param_type, param_descr
@return .t., logical, true or false
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function PROCMODEL()

	IF !Empty( mv_par01 )
		IF Len( mv_par01 ) > 99
			Help(" ", 1, "OGAR730DIREARQ") //##Problema: A localização completa do arquivo do Word excedeu o limite de 99 caracteres.
									       //##Solução: Mova este arquivo para outro local ou selecione outro arquivo.
			Return .F.
		Else
			IF  Upper( Subst( AllTrim( mv_par01 ), - 3 ) ) != Upper( AllTrim( "DOT" ) )  .AND. ; 
                Upper( Subst( AllTrim( mv_par01 ), - 4 ) ) != Upper( AllTrim( "DOTX" ) ) .AND. ;				
                Upper( Subst( AllTrim( mv_par01 ), - 4 ) ) != Upper( AllTrim( "DOTM" ) ) .AND. ;				
                Upper( Subst( AllTrim( mv_par01 ), - 4 ) ) != Upper( AllTrim( "DOCM" ) ) 
                Help( , , STR0036, , STR0037, 1, 0, ,,,,,{STR0038} ) //Tipo de arquivo inválido! //Selecione um arquivo com extensão .DOT, .DOTX, .DOTM ou .DOCM
				Return .F.
            ElseIf !File(mv_par01) 
                Help( , , STR0036, , STR0045, 1, 0, ,,,,,{} ) //Arquivo ou diretório inválido.
				Return .F.            
			EndIf
		EndIf	
	EndIF
Return .T.

/*/{Protheus.doc} PROCDESTI()
Validação do tipo de arquivo(documento) word a ser usado como documento de destino.
@type  Function
@author rafael.kleestadt	
@since 03/01/2018
@version 1.0
@param param, param_type, param_descr
@return .t., logical, true or false
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function PROCDESTI()	

    IF !Empty( mv_par02 )
		IF Len( mv_par02 ) > 99
			Help(" ", 1, "OGAR730DIREARQ") //##Problema: A localização completa do arquivo do Word excedeu o limite de 99 caracteres.
									       //##Solução: Mova este arquivo para outro local ou selecione outro arquivo.
			Return .F.
		Else
			If !ExistDir( mv_par02, , .f. )	
				Help( , , STR0036, , STR0039, 1, 0, ,,,,,{STR0040} ) //"Diretório não encontrado." //"Informe um caminho de diretório válido."
				Return .F.				
			EndIf
		EndIf	
	EndIF
    
Return .t. 

/*/{Protheus.doc} fCposWord()
Carrega os dados variaveis do cabeçalho e retorna para impressão
@type  Function
@author rafael.kleestadt	
@since 29/12/2017
@version 1.0
@param param, param_type, param_descr
@return aExp, array, array com as informações dos campos variaveis do cabeçalho
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function fCposWord(cFilOrg)
	Local aExp     := {}
	Local cCodFor  := AllTrim(POSICIONE('NJ0',1,XFILIAL('NJ0')+N7Q->N7Q_ENTENT+N7Q->N7Q_LOJENT,'NJ0_CODFOR')) //Fornecedor da entidade de destino da IE
	Local cCidCer  := AllTrim(POSICIONE('SA2',1,XFILIAL('SA2')+cCodFor,'A2_MUN')) //Cidade do fornecedor da entidade de destino da IE
	Local cProdut  := Posicione('SB1',1,xFilial('SB1')+N7Q->N7Q_CODPRO,'B1_DESC') //Descrição do produto
	Local cEmbarc  := Posicione('EE6',1,xFilial('EE6')+N7Q->N7Q_EMBARC,'EE6_NOME') //Nome do navio vinculado a IE
	Local cDtLocal := cCidCer + ', ' + StrZero(Day(dDataBase),2) + "/" + StrZero(Month(dDataBase),2) + "/" + Str(Year(dDataBase),4)
	Local cCertif  := AllTrim(Posicione('SA2',1,xFilial('SA2')+cCodFor,'A2_NREDUZ'))
	Local cCompany := AllTrim(FWCompanyName(, cFilOrg))    
	Local cFilAtu  := AllTrim(FWFilialName(, cFilOrg, 1))  
	Local cCnpj    := FwArrFilAtu()[18]  
	Local cEnd     := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_END"))
	Local cMun     := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_MUN"))
	Local cEst     := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_EST"))
	Local cImport  := ""
    Local cImpEnd  := ""
	
	cActMeers := cCompany + " " + cFilAtu

    NJ0->(dbSetOrder(1))
    If NJ0->(dbSeek(XFILIAL('NJ0')+N7Q->N7Q_IMPORT+N7Q->N7Q_IMLOJA))
        cImport := alltrim(NJ0->NJ0_NOME)

        SA1->(dbSetOrder(1))
        If SA1->(dbSeek(FwxFilial("SA1")+NJ0->NJ0_CODCLI+NJ0->NJ0_LOJCLI))    
            cImpEnd := " " + alltrim(SA1->A1_END)
        EndIf
    EndIf

	cOrig := cCompany + " " + cFilAtu + " CNPJ: " + cCnpj + ": " + cEnd + " " + cMun + " " + cEst + " Brazil"
	cEmNomeDe := " ON BEHALF OF "

	cShipper := cOrig + cEmNomeDe + cImport + cImpEnd

				/*=================== ============================ ====================  ================================================*/
		        /*VARIAVEL PARA WORD , VARIAVEL DE IMPRESSAO      , VARIAVEL DE PICTURE , DESCRIÇÃO VARIAVEIS		   		  		     */
		        /*=================== ============================ ====================  ================================================*/ 
	aAdd( aExp, {'AGR_DESPRO'		 , cProdut      		      , "SB1->B1_DESC"      , STR0010 }) //"GOODS DESCRIPTION"
	aAdd( aExp, {'AGR_SHIPPER'		 , cShipper		   		      , "N7Q->N7Q_DESINE"   , STR0041 }) //"SHIPPER"
	aAdd( aExp, {'AGR_CONSIGNEE'	 , fConsignee() 		      , "N7Q->N7Q_CONEN2"   , STR0042 }) //"CONSIGNEE"
	aAdd( aExp, {'AGR_NOTIFY'		 , fNotify() 		          , "N7Q->N7Q_DESNT1"   , STR0043 }) //"NOTIFY"
	aAdd( aExp, {'AGR_PORORI'		 , PortoPais(N7Q->N7Q_PORORI) , "SY9->Y9_DESCR"     , STR0011 }) //"PORT OF LOADING"
	aAdd( aExp, {'AGR_PORDES'	     , PortoPais(N7Q->N7Q_PORDES) , "SY9->Y9_DESCR"     , STR0012 }) //"PORT OF DISCHARGE"
	aAdd( aExp, {'AGR_NAVIO'	     , cEmbarc      		      , "EE6->EE6_NOME"     , STR0013 }) //"VESSEL"
	aAdd( aExp, {'AGR_QTDFRD'	     , _nTotFrd                   , "N7Q->N7Q_QFRCER"   , STR0014 }) //"QUANTITY"
	aAdd( aExp, {'AGR_DTLOCAL'	     , cDtLocal                   , "N91->N91_DTCHEG"   , STR0015 }) //"LOCAL, DATA"
	aAdd( aExp, {'AGR_CERTF'	     , cCertif                    , "SA2->A2_NREDUZ"    , STR0016 }) //"EMPRESA CERTIFICADORA"
	aAdd( aExp, {'AGR_DTCERTF'	     , retDtCert()                , "N91->N91_DTPREV"   , STR0017 }) //"DATA CERTIFICAÇÃO"
	aAdd( aExp, {'AGR_DESINE'	     , N7Q->N7Q_DESINE            , "N7Q->N7Q_DESINE"   , STR0018 }) //"INSTRUÇÃO DE EMBARQUE"
	aAdd( aExp, {'AGR_ACTMEERS'	     , cActMeers                  , "N7Q->N7Q_DESINE"   , STR0044 }) //"ACCOUNT OF MESSRS"

Return ( aExp )

/*/{Protheus.doc} PortoPais
Retorna o nome do porto(SY9) concatenado com o país(SYA)
@type  Function
@author rafael.kleestadt
@since 04/01/2018
@version 1.0
@param cPorto, caractere, código do porto cadastrado no EEC(SY9)
@return cRet, caractere, nome do porto(SY9) concatenado com o país(SYA) 
@example
"PORTO, PAÍS"
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function PortoPais(cPorto)
	Local cPort    := ""
	Local cCodPais := ""
	Local cPais    := ""
	Local cRet     := ""
    Local aAreaSY9 := SY9->(GetArea())
    Local aAreaSYA := SYA->(GetArea())

	If !Empty(cPorto)
		cPort    := UPPER(AllTrim(POSICIONE('SY9',1,XFILIAL('SY9')+cPorto,'Y9_DESCR')))
		cCodPais := UPPER(AllTrim(POSICIONE('SY9',1,XFILIAL('SY9')+cPorto,'Y9_PAIS')))
		cPais    := UPPER(AllTrim(POSICIONE('SYA',1,XFILIAL('SYA')+cCodPais,'YA_DESCR')))
		cRet     := cPort + ', ' + cPais
	EndIf	

    RestArea(aAreaSY9)
    RestArea(aAreaSYA)
	
Return cRet

/*/{Protheus.doc} retDtCert
Retorna a data de certificação formatada
@type  Static Function
@author rafael.kleestadt
@since 19/01/2018
@version 1.0
@param param, param_type, param_descr
@return cDtCertif, caracter, data formatada
@example
"January 19, 2018"
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function retDtCert()

	//Meses no fonte em Inglês pois o certificado de peso é emitido em Inglês
	Local aMeses:= {"January", "February", "March", "April", "May", "June", "July" ,"August", "September", "October", "November", "December"} 
    Local cDtCertif := UPPER(aMeses[Month(__dTcertf)]) + ' ' + StrZero(Day(__dTcertf),2) + ', ' + Str(Year(__dTcertf),4)

Return cDtCertif

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fVarW_Imp()
	/*Define Variaveis Locais */
	Local cString		:= 'N91'
	Local aOrd			:= {STR0020,STR0021}	//"Variável"#"Descrição Da Variável"

	/*Define Variaveis Privates Basicas*/
	Private NomeProg	:= 'OGAR730'
	Private AT_PRG		:= NomeProg
	Private aReturn		:= {STR0022, 1,STR0023, 2, 2, 1, '',1 } //"Código de barras"###"Administração"
	Private cDesc1		:= STR0024 //"Relatório Das Variáveis Agr_word."
	Private cDesc2		:= STR0025 //"Sera impresso de acordo com os parâmetro s solicitados pelo"                     
	Private cDesc3		:= STR0026 //"Utilizador."   	
	Private wCabec0		:= 1
	Private wCabec1		:= STR0027 //"Variáveis                      Descrição"
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1
	Private cBtxt		:= ""
	Private aLinha		:= {}
	Private nLastKey	:= 0

	/*Envia controle para a funcao SETPRINT*/
	WnRel := "WORD_VAR"
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	SetDefault(aReturn,cString)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	/*Chamada do Relatorio. */
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fImpVar()
	Local nOrdem	:= aReturn[8]
	Local aCampos	:= {}
	Local nX		:= 0
	Local cDescr	:= ""

	/*Carregando Variaveis*/
	aCampos := fCposWord()

	/*Ordena aCampos de Acordo com a Ordem Selecionada*/        
	IF nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIF

	/*Carrega Regua de Processamento*/        
	SetRegua( Len( aCampos ) )

	/*Impressao do Relatorio*/        
	For nX := 1 To Len( aCampos )

        /*Movimenta Regua Processamento*/        
		IncRegua()

        /*Cancela ImpresÃ†o*/
		IF lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIF

		/* Mascara do Relatorio*/
        //        10        20        30        40        50        60        70        80
        //12345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Variaveis                      Descricao
		// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
		/*Carregando Variavel de Impressao*/
		cDescr := AllTrim( aCampos[nX,4] )

      	/*Imprimindo Relatorio*/
		Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )
        
		If Len(cDescr) > 50
			Impr( Space(31) + SubStr(cDescr,51,50) )
		Endif

		If Len(cDescr) > 100
			Impr( Space(31) + SubStr(cDescr,101,50) )
		Endif

	Next nX

	IF aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIF

	MS_FLUSH()

Return( NIL )

/*/{Protheus.doc} fAgrpCnt()
Quebra e agrupa os fardos da ie por filial e cnt para gerar um certificado por filial.
@type  Function
@author rafael.kleestadt
@since 21/12/2018
@version 1.0
@param param, param_type, conteineres agrupados por filial.
@return aCnts, array, return_description
@example
(examples)
@see (links_or_references)
/*/
Function fAgrpCnt()	
	Local nPosFil    := 0
    Local nPosCnt    := 0
	Local nQtdFar    := 1
	Local aCnts      := {}
	Local cAliasN9D  := GetNextAlias()		
	
    cQuery := "     SELECT N9D.N9D_FILIAL AS FILIAL, "
	cQuery += " 	       N9D.N9D_SAFRA AS SAFRA, "
	cQuery += " 		   N9D.N9D_BLOCO AS BLOCO, "
	cQuery += " 		   N9D.N9D_CODFAR AS CODFAR, "
	cQuery += " 		   DXI.DXI_PSESTO AS PSESTO, "	
	cQuery += " 		   (DXI.DXI_PSBRUT - DXI.DXI_PSLIQU) AS TARA, "
    cQuery += " 		   (DXI.DXI_PSBRUT - DXI.DXI_PSLIQU) + DXI.DXI_PESCER AS PESOBRT, "
    cQuery += " 		   DXI.DXI_PESCER AS DXI_PESCER, "    
	cQuery += " 		   DXI.DXI_CONTNR AS CONTNR "
	cQuery += "       FROM " + RetSqlName("N9D") + " N9D "
	cQuery += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.DXI_ETIQ = N9D.N9D_FARDO "
	cQuery += "        AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
	cQuery += "        AND DXI.DXI_BLOCO = N9D.N9D_BLOCO "
	cQuery += "        AND DXI.DXI_SAFRA = N9D.N9D_SAFRA "
	cQuery += "        AND DXI.D_E_L_E_T_ = ''  "
	cQuery += "      WHERE N9D.N9D_CODINE =  '" + N7Q->N7Q_CODINE + "'" 
	cQuery += "        AND N9D.N9D_TIPMOV = '05' "
	cQuery += "        AND N9D.N9D_STATUS = '2' "
	cQuery += "        AND N9D.N9D_TIPOPE = '1' " //Somente estufagem Fisica
	cQuery += "        AND N9D.D_E_L_E_T_ = '' "
	cQuery += "   ORDER BY N9D.N9D_FILIAL "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9D, .F., .T.)
	DbselectArea( cAliasN9D )
	(cAliasN9D)->(DbGoTop())

	While (cAliasN9D)->( !Eof() )

			cLacre := Posicione("N91", 1, FwxFilial("N91")+N7Q->N7Q_CODINE+(cAliasN9D)->CONTNR, "N91_LACRE")
			
			nPosFil := aScan(aCnts, {|x| AllTrim( x[1] ) == AllTrim( (cAliasN9D)->FILIAL ) })

			If nPosFil == 0
				aAdd(aCnts, { (cAliasN9D)->FILIAL,; 							
				              {{(cAliasN9D)->CONTNR,;								    //AGR_NRCNT	  
							  nQtdFar,;											        //AGR_QTDFRDCNT
							  cLacre,;											        //AGR_LACRE	
							  (cAliasN9D)->PESOBRT,;								    //AGR_PSBRUTCNT
							  (cAliasN9D)->TARA,;                                     //AGR_TARA
							  (cAliasN9D)->DXI_PESCER}}})								//AGR_PSLIQCNT
			Else				
                nPosCnt := aScan(aCnts[nPosFil,2], {|x| AllTrim( x[1] ) == AllTrim( (cAliasN9D)->CONTNR )})                
                
                If nPosCnt == 0
                    aAdd(aCnts[nPosFil,2], {(cAliasN9D)->CONTNR,;								//AGR_NRCNT	  
							  nQtdFar,;											//AGR_QTDFRDCNT
							  cLacre,;											//AGR_LACRE	
							  (cAliasN9D)->PESOBRT,;								//AGR_PSBRUTCNT
							  (cAliasN9D)->TARA  ,;   //AGR_TARA
							  (cAliasN9D)->DXI_PESCER})
                Else                
                    aCnts[nPosFil, 2, nPosCnt, 2] += 1
                    aCnts[nPosFil, 2, nPosCnt, 4] += (cAliasN9D)->PESOBRT
                    aCnts[nPosFil, 2, nPosCnt, 5] += (cAliasN9D)->TARA
                    aCnts[nPosFil, 2, nPosCnt, 6] += (cAliasN9D)->DXI_PESCER
                EndIf
			EndIf

			//Armazena a data da ultima certificação de conteiner
			dDtCert := Posicione("N91", 1, FwxFilial("N91")+N7Q->N7Q_CODINE+(cAliasN9D)->CONTNR, "N91_DTCERT")
			If Len(aCnts) <= 1
				__dTcertf := cLacre := dDtCert
			Else
				__dTcertf := Iif(dDtCert > __dTcertf, dDtCert, __dTcertf)
			EndIf		
		(cAliasN9D)->(DbSkip())
	EndDo
	(cAliasN9D)->(DbCloseArea())
	
Return aCnts

//-------------------------------------------------------------------
/*/{Protheus.doc} fConsignee
Monta descrição Consignee
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fConsignee()
    Local cRet := ""

    cRet := alltrim(N7Q->N7Q_CONDES) + " " + alltrim(N7Q->N7Q_CONEND) + " " + alltrim(N7Q->N7Q_CONEN2)    

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fNotify
Monta descriçãod Notify
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fNotify()
    Local cRet := ""

    cRet := alltrim(N7Q->N7Q_DESNT1) + " " + alltrim(N7Q->N7Q_ENDNT1) + " " + alltrim(N7Q->N7Q_EN2NT1)
    If !Empty(N7Q->N7Q_ENDNT2)
        cRet += "|" + alltrim(N7Q->N7Q_ENDNT2) + " " + alltrim(N7Q->N7Q_CODNT2) + " " + alltrim(N7Q->N7Q_EN2NT2)
    Endif

Return cRet

#Include 'Protheus.ch'
#Include 'FISA194A.ch'

Function FISA194A(); RETURN
    
    /*Classe da Tabela temporaria*/  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} TABTEMPCAT42
 
Classe da tabela Temporaria
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------    
CLASS TABTEMPCAT42 FROM LongClassName
    
    Data cAliasTmp		as String		READONLY		//Alias da tabela temporária que deverá ser criada
    Data cArqTmp		as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
    Data cAliasCAd		as String		READONLY		//Alias da tabela temporária que deverá ser criada
    Data cArqCad		as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
    Data cIndice		as String		READONLY		//Indíce que deverá ser utilizado na criação da tabela
    Data cDelimit		as String		READONLY		//Delimitador para separação entre os campos do registro
    Data aCampos		as Array		READONLY		//Array com estrutura da tabela a ser criada.
    Data aRegistro		as Array		READONLY		//Array com informação do registro a ser processado
    Data nPosRelac		as Integer		READONLY		//Posição do array que representa
    Data cLinhaTxt		as String 		READONLY		//Linha que deverá ser gravada na tabela
    Data cGrupo			as String 		READONLY		//Conteúdo do grupo que deverá ser gravado na tabela.
    Data cBloco			as String 		READONLY		//Número do bloco que deverá ser gravado na tabela.
    Data cRegistro		as String 		READONLY		
    Data cDiretorio		as String 		READONLY		
    Data cPathArq		as String 		READONLY		
    Data cNomeArq		as String 		READONLY		
    Data cRecno			as String 		READONLY		
    
    METHOD New()
    METHOD CriaTabela()
    METHOD SetcAliasTmp( cAliasTmp)
    METHOD SetcArqTmp( cArqTmp)
    METHOD SetcAliasCAd( cAliasCAd)
    METHOD SetcArqCad( cArqCad)
    METHOD SetcIndice( cIndice)
    METHOD SetcDelimit( cDelimit)
    METHOD SetaCampos( aCampos)
    METHOD SetaRegistro(aRegistro)
    METHOD SetnPosRelac( nPosRelac)
    METHOD SetcLinhaTxt( cLinhaTxt)
    METHOD SetcGrupo( cGrupo)
    METHOD SetcBloco( cBloco)
    METHOD SetcRegist(cRegistro)
    METHOD SetcDireto( cDiretorio)
    METHOD SetcPathArq( cPathArq)
    METHOD SetcNomeArq( cNomeArq)
    METHOD SetcRecno( cRecno)
    METHOD GrvReg()
    METHOD GeraLinha()
    METHOD GravaLinha()
    METHOD GravaTXT()
    METHOD DelTabela()
    METHOD DelTabCad()
    METHOD GetAlias()
    
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} New
 
Método que inicializa/limpa todos os atributos da CLASSe
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD New() CLASS TABTEMPCAT42
    
    Self:aRegistro	:={}
    
RETURN
METHOD SetcAliasTmp( cAliasTmp) CLASS TABTEMPCAT42
    Self:cAliasTmp := cAliasTmp
RETURN

METHOD SetcArqTmp( cArqTmp) CLASS TABTEMPCAT42
    Self:cArqTmp := cArqTmp
RETURN

METHOD SetcAliasCAd( cAliasCAd) CLASS TABTEMPCAT42
    Self:cAliasCAd := cAliasCAd
RETURN

METHOD SetcArqCad( cArqCad) CLASS TABTEMPCAT42
    Self:cArqCad := cArqCad
RETURN

METHOD SetcIndice( cIndice) CLASS TABTEMPCAT42
    Self:cIndice := cIndice
RETURN

METHOD SetcDelimit( cDelimit)   CLASS TABTEMPCAT42
    Self:cDelimit := cDelimit
RETURN

METHOD SetaCampos( aCampos) CLASS TABTEMPCAT42
    Self:aCampos := aCampos
RETURN

METHOD SetaRegistro( aRegistro) CLASS TABTEMPCAT42
    Self:aRegistro := aRegistro
RETURN

METHOD SetnPosRelac( nPosRelac) CLASS TABTEMPCAT42
    Self:nPosRelac := nPosRelac
RETURN

METHOD SetcLinhaTxt( cLinhaTxt) CLASS TABTEMPCAT42
    Self:cLinhaTxt := cLinhaTxt
RETURN

METHOD SetcGrupo( cGrupo)    CLASS TABTEMPCAT42
    Self:cGrupo := cGrupo
RETURN

METHOD SetcBloco( cBloco)   CLASS TABTEMPCAT42
    Self:cBloco := cBloco
RETURN

METHOD SetcRegist( cRegistro)   CLASS TABTEMPCAT42
    Self:cRegistro := cRegistro
RETURN

METHOD SetcDireto( cDiretorio)  CLASS TABTEMPCAT42
    Self:cDiretorio := cDiretorio
RETURN

METHOD SetcPathArq( cPathArq)   CLASS TABTEMPCAT42
    Self:cPathArq := cPathArq
RETURN

METHOD SetcNomeArq( cNomeArq)   CLASS TABTEMPCAT42
    Self:cNomeArq := cNomeArq
RETURN

METHOD SetcRecno( cRecno)   CLASS TABTEMPCAT42
    Self:cRecno := cRecno
RETURN

METHOD GetAlias()   CLASS TABTEMPCAT42
RETURN Self:cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela
 
Método que irá criar a tabela temporária para gravação dos registros
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD CriaTabela() CLASS TABTEMPCAT42
Local aCmp		:= {}
Local cArquivo      := "CAT42"+GetDBExtension() /*Recupera o nome fisico gerado*/
Local cAliasTRB     := "CAT42"
Local oArqtmp 

aAdd (aCmp, {'NROBLOCO',	'C', 	002,	0})	/*Número do bloco*/
aAdd (aCmp, {'REGISTRO',	'C', 	004,	0})	/*Registro que deverá ser gravado*/
aAdd (aCmp, {'GRUPO',	    'C', 	052,	0})	/*Código do grupo utilizado para ordenação da tabela, no momento da gravação do arquivo texto*/
aAdd (aCmp, {'CONTEUDO',	'C', 	500,	0})	/*Conteúdo da linha a ser gravada no arquivo texto*/

Self:cAliasTmp	:= cAliasTRB
Self:cArqTmp	:= cArquivo

oArqtmp := FWTemporaryTable():New(cAliasTRB)
oArqtmp:SetFields(aCmp)
oArqtmp:AddIndex("01", {"NROBLOCO","GRUPO","REGISTRO"} )
oArqtmp:Create()

//Self:cArqTmp := CriaTrab (aCmp)
//DbUseArea (.T., __LocalDriver, Self:cArqTmp, Self:cAliasTmp)
//IndRegua (Self:cAliasTmp, Self:cArqTmp, 'NROBLOCO+GRUPO+REGISTRO')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela
 
Método que apaga a tabela temporária criada para geração do arquivo texto
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD DelTabela() CLASS TABTEMPCAT42
    
/*Está função fecha a tabela temporária*/
FWCLOSETEMP(Self:cAliasTmp)
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvReg
 
Método de Gravação
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD GrvReg(aRegistro) CLASS TABTEMPCAT42
    
    /*Passa array para CLASSe*/
    Self:aRegistro	:= aRegistro
    
    /*Grava o registro*/
    Self:GeraLinha()
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvReg
 
Método que monta a linha a ser denonstrada no arquivo
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD GeraLinha() CLASS TABTEMPCAT42
Local nContR	:= 0
Local nContC	:= 0
Local nDecimal	:= 2
Local cLinha	:= ''
Local cConteudo	:= ''
Local cType		:= ''
Local dDate		:= cTod('  /  /    ')

Self:cDelimit	:= '|'
/*Laço para percorrer os registros*/
For nContR	:= 1 to Len(Self:aRegistro)
    /*Relacionamento dos registros*/
    Self:cGrupo	:= AllTrim(Self:aRegistro[nContR][1])
    Self:cRegistro:= AllTrim(Self:aRegistro[nContR][2])
    Self:setcRegist(Self:cRegistro)
    /*Laço para percorrer os campos dos registros*/
    For nContC	:= 2 to Len(Self:aRegistro[nContR])
        
        cType	:= ValType(Self:aRegistro[nContR][nContC])
        
        IF cType == 'A'
            
            IF  valtype(Self:aRegistro[nContR][nContC][1]) == 'N'
                
                /*Pega quantidade de casas decimais na segunda posição informada no campo*/
                nDecimal	:=	Self:aRegistro[nContR][nContC][2]                    
                If Len(Self:aRegistro[nContR][nContC]) == 2
                        //Passou somente qtde de decimais
                        /*Formata colocando víergula no lugar de ponto, e formatando decimais conforme passado na segunda posição do array*/
                    cConteudo	:= AllTrim (StrTran (Str (Self:aRegistro[nContR][nContC][1],,nDecimal), ".", ","))
                
                ElseIF Len(Self:aRegistro[nContR][nContC]) == 3 .AND. Self:aRegistro[nContR][nContC][3] == 'P'
                        //Passou atde decimal e tabm 'P'
                    //Deverá fazer tratamento de número significativo.
                        cConteudo	:= NumSignif(Self:aRegistro[nContR][nContC][1], nDecimal)
                EndIF
                                        
            Else
                cConteudo	:= AllTrim (Self:aRegistro[nContR][nContC][1])
            ENDIF
            
            
        ElseIF cType == 'N'          
            nDecimal	:= 2
            cConteudo	:= AllTrim(StrTran (Str (Self:aRegistro[nContR][nContC],,nDecimal), ".", ","))
        ElseIF cType == 'C'
            If Self:cRegistro == '1200' .And. !Empty(Self:aRegistro[nContR][5]) .And. nContC == 5 // no array aRegistro a posição 5 corresponde a serieECF(SeriePDV)
                cConteudo	:= NoAcento(Self:aRegistro[nContR][nContC])
            Else
                cConteudo	:= NoAcento(AllTrim(Self:aRegistro[nContR][nContC]))
            EndiF    
        ElseIF cType == 'D'
            dDate		:= Self:aRegistro[nContR][nContC]
            cConteudo	:=	StrZero (Day(dDate),2)+StrZero(Month(dDate),2)+StrZero(Year(dDate),4)
        Else
            cConteudo	:= ''
        ENDIF
        
        cLinha += cConteudo + Self:cDelimit
        
    Next nContC/*Fim do laço dos campos*/
        
    /*Retira o delimitador do Final*/
    cLinha := AllTrim(Left(cLinha,Len(cLinha)-1))
    
    Self:cLinhaTxt 	:= cLinha
    
    /*Aqui chama método para realizar a gravação do registro na tabela temporária*/
    Self:GravaLinha()
    cLinha	:= ''
Next nContR /*Fim do laço do registro*/
    
Return   
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} GravaLinha
 
Método que efetua a gravação da linha na tabela temporaria
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD GravaLinha() CLASS TABTEMPCAT42
    
RecLock(Self:cAliasTmp,.T.)

Replace NROBLOCO    With Self:cBloco
Replace REGISTRO    With Self:cRegistro
Replace GRUPO     	With Self:cGrupo
Replace CONTEUDO    With Self:cLinhaTxt

(Self:cAliasTmp)->(MsUnLock())
    
RETURN

 //-------------------------------------------------------------------
/*/{Protheus.doc} GravaTXT
 
Método que efetua a gravação do arquivo texto
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//------------------------------------------------------------------- 
METHOD GravaTXT() CLASS TABTEMPCAT42
    
Local cNomeTmp	:= Self:cDiretorio+'CAT42 - '+cFilAnt+'.Txt'
Local cNomeReal := Self:cDiretorio+Self:cNomeArq
Local lRet  := .F.
Local bError
Local lErro := .F.

dbSelectArea(Self:cAliasTmp)
(Self:cAliasTmp)->(DBSetOrder(1))
(Self:cAliasTmp)->(DbGoTop ())
Set Filter To

bError := ErrorBlock( {|| lErro := .T. } )
BEGIN SEQUENCE
    
    Copy to &cNomeReal FIELDS 'CONTEUDO' DELIMITED WITH ''
    
    
END SEQUENCE
ErrorBlock( bError )

If lErro
    Alert(STR0001) //'Erro ao gravar arquivo texto'
EndIF
    
Return Iif(lErro,cNomeTmp,'')

//-------------------------------------------------------------------
/*/{Protheus.doc} CAT42
 
Classe que gera os registro do Bloco Zero e abertura e fechamento
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------    

CLASS CAT42 FROM LongClassName
    
/*ATRIBUTOS DA CLASSE*/

/*Genéricos*/
Data cReg			as String		READONLY
Data aReg			as Array		READONLY
Data cGrupoReg	    as String		READONLY		//Grupo do registro
Data cRelac		    as String		READONLY		//Esta variável terá o conteúdo de relacionamento para gravação na tabela.
Data aNumeracao	    as Array		READONLY
Data aReg0000		as Array		HIDDEN

Data aReg0001		as Array		READONLY
Data aReg0990		as Array		READONLY
Data aReg5001		as Array		READONLY
Data aReg5990		as Array		READONLY
Data aReg9001		as Array		READONLY		//Array com informações de controle do bloco.
Data aReg9900		as Array		READONLY		//Array com informações de controle do bloco
Data aReg9990		as Array		READONLY		//Array com informações de controle do bloco.
Data aReg9999		as Array		READONLY		//Array com informações de controle do bloco.


/*Métodos*/
METHOD New()
METHOD ClearCat42()
METHOD SetcReg( cReg)
METHOD setaNumer()
METHOD setRelac(cRelac)
METHOD AbreBloco(cReg,aReg,cIndMov)
METHOD FechaBloco(cReg,aReg, nQtde)

METHOD getGrupo()
    
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
 
Método que inicializa/limpa todos os atributos da CLASSe
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------  
METHOD New() CLASS CAT42
    Self:ClearCat42()
RETURN

METHOD ClearCat42() CLASS CAT42
Self:cReg		:= ''
Self:cGrupoReg	:= ''
Self:cRelac		:= ''
Self:aNumeracao	:= {}
Self:aReg		:= {}
Self:aReg0000	:= {}
Self:aReg0001	:= {}
Self:aReg0990	:= {}
Self:aReg5001	:= {}
Self:aReg5990	:= {}
Self:aReg9001	:= {}
Self:aReg9900	:= {}
Self:aReg9990	:= {}
Self:aReg9999	:= {}
RETURN

METHOD SetcReg( cReg) CLASS CAT42
    Self:cReg := cReg
RETURN

METHOD setaNumer( aNumeracao) CLASS CAT42
    Self:aNumeracao := aNumeracao
RETURN

METHOD setRelac( cRelac) CLASS CAT42
    Self:cRelac := cRelac
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreBloco
 
Método que faz a abertura de Blocos
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------    
METHOD AbreBloco(cReg,aReg,cIndMov) CLASS CAT42
    
Local nPos	:= 0

Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,'', cReg)
aAdd(aReg, {})
nPos := Len(aReg)
aAdd (aReg[nPos], Self:cGrupoReg)       /*Relacionamento com registro pai*/
aAdd (aReg[nPos], cReg)                 /*Registro*/
aAdd (aReg[nPos], cIndMov)              /*Indica se tem ou não movimento*/
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaBloco
 
Método que faz o fechamento de Blocos
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//------------------------------------------------------------------- 
METHOD FechaBloco(cReg,aReg, nQtde) CLASS CAT42
    
Local nPos	:= 0

Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,'', cReg)
aAdd(aReg, {})
nPos := Len(aReg)
aAdd (aReg[nPos], Self:cGrupoReg)       /*Relacionamento com registro pai*/
aAdd (aReg[nPos], cReg)                 /*Registro*/
aAdd (aReg[nPos], nQtde)                /*Indica se tem ou não movimento*/
    
RETURN

METHOD getGrupo() CLASS CAT42
RETURN Self:cGrupoReg

//-------------------------------------------------------------------
/*/{Protheus.doc} BLOCOREG
 
Classe de geração do Bloco de Registros
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//------------------------------------------------------------------- 

CLASS BLOCOREG FROM CAT42
    
/*Bloco 0000*/
Data cReg		as String		READONLY
Data cPeriodo	as String		READONLY
Data cNome		as String		READONLY
Data cCNPJ      as String       READONLY
Data cIE		as String		READONLY
Data cCodMun	as String		READONLY
Data cVersao	as String		READONLY
Data cFinalid	as String		READONLY

/*Registro 0150*/
Data cCodPar	as String	READONLY
Data cNomPar    as String   READONLY
Data nPais      as Integer	READONLY
Data nCNPJ      as Integer	READONLY
Data nCPF       as Integer	READONLY
Data nIE        as Integer  READONLY
Data nCodMun    as Integer	READONLY

/*Registro 0200*/
Data cCodItem   as String	READONLY
Data cDescItem  as String	READONLY
Data cCodBar    as String   READONLY
Data cUn        as String	READONLY
Data cNcm       as String	READONLY
Data nAliqIcms  as Integer  READONLY
Data cCest      as String   READONLY

/*Registro 0205*/
Data cCodAnt    as String	READONLY
Data cDescAnt   as String	READONLY

/*Registro 1050*/
Data nQtdeIni   as Integer	READONLY
Data nValorIni  as Integer	READONLY
Data nQtdeFim   as Integer	READONLY
Data nValorFim  as Integer	READONLY

/*Registro 1100*/
Data cChave     as String  READONLY
Data dDataDigit as Date    READONLY
Data nItem      as Integer READONLY
Data nOperacao  as Integer READONLY
Data nCFOP      as Integer READONLY
Data nQtde      as Integer READONLY
Data nICMSSup   as Integer READONLY
Data nVlrConf   as Integer READONLY
Data nCodEnquad as Integer READONLY

/*Registro 1200*/
Data cEspecie   as String   READONLY
Data cNumSerie  as String   READONLY
Data cNumDoc    as String   READONLY
Data cNumSerEcf as String   READONLY

/*Arrays dos registros*/
Data aReg0150   as Array	READONLY
Data aReg0200   as Array    READONLY
Data aReg0205   as Array    READONLY
Data aReg1050   as Array    READONLY
Data aReg1100   as Array    READONLY
Data aReg1200   as Array    READONLY

/*Métodos Registro 0000*/
METHOD SetcVersao(cNome)
METHOD SetcFinalid(cFinalid)
METHOD SetcPeriodo(cPeriodo)
METHOD SetcNome(cNome)
METHOD SetcIE(cIE)
METHOD SetsetUF(cCodMun)

/*Métodos Registro 0150*/
METHOD SetcCodPar(cCodPar)
METHOD SetnPais(nPais)
METHOD SetnCNPJ(nCNPJ)
METHOD SetnCPF(nCPF)
METHOD SetcUF(cUF)
METHOD SetnCodMun(nCodMun)

/*Métodos Registro 0200*/
METHOD SetcCodItem(cCodItem)
METHOD SetcDescItem(cDescItem)
METHOD SetcCodBar(cCodBar)
METHOD SetcUn(cUn)
METHOD SetcNcm(cNcm)
METHOD SetnAliqIcms(nAliqIcms)
METHOD SetcCest(cCest)

/*Métodos Registro 0205*/
METHOD SetcCodAnt(cCodAnt)
METHOD SetcDescAnt(cDescAnt)

/*Métodos Registro 1050*/
METHOD SetnQtdeIni(nQtdeIni)
METHOD SetnValorIni(nValorIni)
METHOD SetnQtdeFim(nQtdeFim)
METHOD SetnValorFim(nValorFim)

/*Métodos registro 1100*/
METHOD SetcChave(cChave)
METHOD SetdDataDigit(dDataDigit)
METHOD SetnItem(nItem)
METHOD SetnOperacao(nOperacao)
METHOD SetnCFOP(nCFOP)
METHOD SetnQtde(nQtde)
METHOD SetnICMSSup(nICMSSup)
METHOD SetnVlrConf(nVlrConf)
METHOD SetnCodEnquad(nCodEnquad)

/*Métodos registro 1200*/
METHOD SetcEspecie(cEspecie)
METHOD SetcNumSerEcf(cNumSerEcf)
METHOD SetcSerie(cNumSerie)
METHOD SetcNumDoc(cNumDoc)

METHOD  Add0000(cReg)
METHOD  Add0150(cReg)
METHOD  Add0200(cReg)
METHOD  Add0205(cReg)
METHOD  Add1050(cReg)
METHOD  Add1100(cReg)
METHOD  Add1200(cReg)

METHOD New()

/*Limpa os Arrays dos Registros*/
METHOD Clear(nReg)
    
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS BLOCOREG
/*0000*/
Self:cVersao        := ''
Self:cFinalid       := ''
Self:cPeriodo       := ''
Self:cNome          := ''
Self:cIE            := ''
Self:cCodMun        := ''

/*0150*/
Self:cCodPar        := ''
Self:cNome          := ''
Self:nPais          := 0
Self:nCNPJ          := 0
Self:nCPF           := 0
Self:cIE            := ''
Self:nCodMun        := 0

/*0200*/
Self:cCodItem       := ''
Self:cDescItem      := ''
Self:cCodBar        := ''
Self:cUn            := ''
Self:cNcm           := ''
Self:nAliqIcms      := 0
Self:cCest          := ''

/*0205*/
Self:cCodItem       := ''
Self:cCodAnt        := ''
Self:cDescAnt       := ''


/*1050*/
Self:cCodItem       := ''
Self:nQtdeIni       := 0
Self:nValorIni      := 0
Self:nQtdeFim       := 0
Self:nValorFim      := 0

/*1100*/
Self:cChave         := 0
Self:dDataDigit     := CtoD('  /  /    ')
Self:nItem          := 0
Self:nOperacao      := 0
Self:cCodItem       := ''
Self:nCFOP          := 0
Self:nQtde          := 0
Self:nICMSSup       := 0
Self:nVlrConf       := 0
Self:nCodEnquad     := 0

/*1200*/
Self:cCodPar        := ''
Self:cEspecie       := ''
Self:cNumSerEcf     := ''
Self:cNumSerie      := ''
Self:cNumDoc        := ''
Self:nItem           := 0
Self:nOperacao      := 0
Self:dDataDigit     := CtoD('  /  /    ')
Self:nCFOP          := 0
Self:cCodItem       := ''
Self:nQtde          := 0
Self:nICMSSup       := 0
Self:nVlrConf       := 0
Self:nCodEnquad     := 0

/*Arrays*/
Self:aReg0000       := {}
Self:aReg0150       := {}
Self:aReg0200       := {}
Self:aReg0205       := {}
Self:aReg1050       := {}
Self:aReg1100       := {}
Self:aReg1200       := {}


Self:ClearCat42()
Return

/*Métodos Reg 0000*/
METHOD SetcVersao( cVersao) CLASS BLOCOREG
    Self:cVersao := cVersao
Return
METHOD SetcFinalid( cFinalid) CLASS BLOCOREG
    Self:cFinalid := cFinalid
Return
METHOD SetcPeriodo( cPeriodo) CLASS BLOCOREG
    Self:cPeriodo := cPeriodo
Return
METHOD SetcNome( cNome) CLASS BLOCOREG
    Self:cNome := cNome
Return
METHOD SetnCNPJ( nCNPJ) CLASS BLOCOREG
    Self:nCNPJ := nCNPJ
Return
METHOD SetcIE( cIE) CLASS BLOCOREG
    Self:cIE := cIE
Return
METHOD SetsetUF( cCodMun) CLASS BLOCOREG
    Self:cCodMun := cCodMun
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0000
 
Método para geração do registro de Abertura do Arquivo
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
METHOD Add0000(cReg) CLASS BLOCOREG
Local nPos		:= 0

Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,'', '0000')

aAdd(Self:aReg0000, {})
nPos:=	Len (Self:aReg0000)
aAdd (Self:aReg0000[nPos], Self:cGrupoReg)  /*Grupo do Registro*/
aAdd (Self:aReg0000[nPos], cReg)            /*01-Texto Fixo Contendo "0000"*/
aAdd (Self:aReg0000[nPos], Self:cPeriodo)   /*02-Período das Informações contidas no arquivo*/
aAdd (Self:aReg0000[nPos], Self:cNome)      /*03-Nome empresarial do estabelecimento informante*/
aAdd (Self:aReg0000[nPos], Self:nCNPJ)      /*04-CNPJ do Estabelecimento Informante*/
aAdd (Self:aReg0000[nPos], Self:cIE)        /*05-Inscrição Estadual do Estabelecimento Informante*/
aAdd (Self:aReg0000[nPos], Self:cCodMun)    /*06-Código do Municipio do Estabelecimento Informante*/
aAdd (Self:aReg0000[nPos], Self:cVersao)    /*07-Código da Versão do Layout */
aAdd (Self:aReg0000[nPos], Self:cFinalid)   /*08-Código da Finalidade do arquivo*/

aReg := Self:aReg0000
    
Return (aReg)


/*Métodos Reg 0150*/
METHOD SetcCodPar(cCodPar)	 CLASS BLOCOREG
    Self:cCodPar := cCodPar
Return
METHOD SetnPais(nPais) CLASS BLOCOREG
    Self:nPais := nPais
Return
METHOD SetnCPF(nCPF) CLASS BLOCOREG
    Self:nCPF := nCPF
Return
METHOD SetnCodMun(nCodMun) CLASS BLOCOREG
    Self:nCodMun := nCodMun
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0150
 
Método para geração do registro 0150
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
METHOD Add0150(cReg) CLASS BLOCOREG
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '0150')
        aAdd (Self:aReg0150, {})
        nPos	:=	Len (Self:aReg0150)
        aAdd (Self:aReg0150[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0150[nPos], cReg)
        aAdd (Self:aReg0150[nPos], Self:cCodPar)
        aAdd (Self:aReg0150[nPos], Self:cNome)
        aAdd (Self:aReg0150[nPos], Self:nPais)
        aAdd (Self:aReg0150[nPos], Self:nCNPJ)
        aAdd (Self:aReg0150[nPos], Self:nCPF)
        aAdd (Self:aReg0150[nPos], Self:cIE)
        aAdd (Self:aReg0150[nPos], Self:nCodMun)
        
        aReg := Self:aReg0150
Return (aReg)

/*Métodos Registro 0200*/
METHOD SetcCodItem(cCodItem)    CLASS BLOCOREG
    Self:cCodItem := cCodItem
Return
METHOD SetcDescItem(cDescItem)  CLASS BLOCOREG
    Self:cDescItem := cDescItem
Return
METHOD SetcCodBar(cCodBar)  CLASS BLOCOREG
    Self:cCodBar := cCodBar
Return
METHOD SetcUn(cUn)  CLASS BLOCOREG
    Self:cUn := cUn
Return
METHOD SetcNcm(cNcm)  CLASS BLOCOREG
    Self:cNcm := cNcm
Return
METHOD SetnAliqIcms(nAliqIcms)  CLASS BLOCOREG
    Self:nAliqIcms := nAliqIcms
Return
METHOD SetcCest(cCest)  CLASS BLOCOREG
    Self:cCest := cCest
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0200
 
Método para geração do registro 0200
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
METHOD Add0200(cReg)    CLASS BLOCOREG
Local aReg       := {}

Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '0200')
aAdd (Self:aReg0200, {})
nPos	:=	Len (Self:aReg0200)
aAdd (Self:aReg0200[nPos], Self:cGrupoReg)
aAdd (Self:aReg0200[nPos], cReg)
aAdd (Self:aReg0200[nPos], Self:cCodItem)
aAdd (Self:aReg0200[nPos], Self:cDescItem)
aAdd (Self:aReg0200[nPos], Self:cCodBar)
aAdd (Self:aReg0200[nPos], Self:cUn)
aAdd (Self:aReg0200[nPos], Self:cNcm)
aAdd (Self:aReg0200[nPos], Self:nAliqIcms)
aAdd (Self:aReg0200[nPos], Self:cCest)

aReg := Self:aReg0200

Return (aReg)

/*Métodos Reg 0205*/
METHOD SetcCodAnt(cCodAnt) 	 CLASS BLOCOREG
    Self:cCodAnt := cCodAnt
Return
METHOD SetcDescAnt(cDescAnt) 	 CLASS BLOCOREG
    Self:cDescAnt := cDescAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0205
 
Método para geração do registro 0205
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
METHOD Add0205(cReg) CLASS BLOCOREG
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '0205')
        aAdd (Self:aReg0205, {})
        nPos	:=	Len (Self:aReg0205)
        aAdd (Self:aReg0205[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0205[nPos], cReg)
        aAdd (Self:aReg0205[nPos], Self:cCodItem)
        aAdd (Self:aReg0205[nPos], Self:cCodAnt)
        aAdd (Self:aReg0205[nPos], Self:cDescAnt)
        
        aReg := Self:aReg0205
RETURN (aReg)

/*Métodos Reg 1050*/

METHOD SetnQtdeIni(nQtdeIni) CLASS BLOCOREG
    Self:nQtdeIni := nQtdeIni
RETURN
METHOD SetnValorIni(nValorIni) CLASS BLOCOREG
    Self:nValorIni := nValorIni
RETURN
METHOD SetnQtdeFim(nQtdeFim) CLASS BLOCOREG
    Self:nQtdeFim := nQtdeFim
RETURN
METHOD SetnValorFim(nValorFim) CLASS BLOCOREG
    Self:nValorFim := nValorFim
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1050
 
Método para geração do registro 1050
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------

METHOD Add1050(cReg) CLASS BLOCOREG
    Local aReg       := {}

        Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '1050')
        aAdd (Self:aReg1050, {})
        nPos	:=	Len (Self:aReg1050)
        aAdd (Self:aReg1050[nPos], Self:cGrupoReg)
        aAdd (Self:aReg1050[nPos], cReg)
        aAdd (Self:aReg1050[nPos], Self:cCodItem)
        aAdd (Self:aReg1050[nPos], Self:nQtdeIni)
        aAdd (Self:aReg1050[nPos], Self:nValorIni)
        aAdd (Self:aReg1050[nPos], Self:nQtdeFim)
        aAdd (Self:aReg1050[nPos], Self:nValorFim)
        aReg := Self:aReg1050

RETURN (aReg)

/*Métodos registro 1100*/

METHOD SetcChave(cChave) CLASS BLOCOREG
    Self:cChave := cChave
RETURN
METHOD SetdDataDigit(dDataDigit) CLASS BLOCOREG
    Self:dDataDigit := dDataDigit
RETURN
METHOD SetnItem(nItem) CLASS BLOCOREG
    Self:nItem := nItem
RETURN
METHOD SetnOperacao(nOperacao) CLASS BLOCOREG
    Self:nOperacao := nOperacao
RETURN
METHOD SetnCFOP(nCFOP) CLASS BLOCOREG
    Self:nCFOP := nCFOP
RETURN
METHOD SetnQtde(nQtde) CLASS BLOCOREG
    Self:nQtde := nQtde
RETURN
METHOD SetnICMSSup(nICMSSup) CLASS BLOCOREG
    Self:nICMSSup := nICMSSup
RETURN
METHOD SetnVlrConf(nVlrConf) CLASS BLOCOREG
    Self:nVlrConf := nVlrConf
RETURN
METHOD SetnCodEnquad(nCodEnquad) CLASS BLOCOREG
    Self:nCodEnquad := nCodEnquad
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Add1100
 
Método para geração do registro 1100
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------

METHOD Add1100(cReg) CLASS BLOCOREG
Local nPos		:= 0
Local aReg       := {}

Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '1100')
aAdd (Self:aReg1100, {})
nPos	:=	Len (Self:aReg1100)
aAdd (Self:aReg1100[nPos], Self:cGrupoReg)
aAdd (Self:aReg1100[nPos], cReg)
aAdd (Self:aReg1100[nPos], Self:cChave)
aAdd (Self:aReg1100[nPos], Self:dDataDigit)
aAdd (Self:aReg1100[nPos], Self:nItem)
aAdd (Self:aReg1100[nPos], Self:nOperacao)
aAdd (Self:aReg1100[nPos], Self:cCodItem)
aAdd (Self:aReg1100[nPos], Self:nCFOP)
aAdd (Self:aReg1100[nPos], Self:nQtde)
aAdd (Self:aReg1100[nPos], Self:nICMSSup)
aAdd (Self:aReg1100[nPos], Self:nVlrConf)
aAdd (Self:aReg1100[nPos], Self:nCodEnquad)

aReg := Self:aReg1100   
    
RETURN (aReg)

/*Métodos registro 1200*/
METHOD SetcEspecie(cEspecie) CLASS BLOCOREG
    Self:cEspecie := cEspecie
RETURN
METHOD SetcNumSerEcf(cNumSerEcf) CLASS BLOCOREG
    Self:cNumSerEcf := cNumSerEcf
RETURN
METHOD SetcSerie(cNumSerie) CLASS BLOCOREG
    Self:cNumSerie := cNumSerie
RETURN
METHOD SetcNumDoc(cNumDoc) CLASS BLOCOREG
    Self:cNumDoc := cNumDoc
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1200
 
Método para geração do registro 1200
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------

METHOD Add1200(cReg) CLASS BLOCOREG
Local nPos  := 0
Local aReg  := {}
    
Self:cGrupoReg		:= SeqCat42(@Self:aNumeracao,Self:cRelac, '1200')
aAdd (Self:aReg1200, {})
nPos	:=	Len (Self:aReg1200)
aAdd (Self:aReg1200[nPos], Self:cGrupoReg)
aAdd (Self:aReg1200[nPos], cReg)
aAdd (Self:aReg1200[nPos], Self:cCodPar)
aAdd (Self:aReg1200[nPos], Self:cEspecie)
aAdd (Self:aReg1200[nPos], Self:cNumSerEcf)
aAdd (Self:aReg1200[nPos], Self:cNumSerie)
aAdd (Self:aReg1200[nPos], Self:cNumDoc)
aAdd (Self:aReg1200[nPos], Self:nItem)
aAdd (Self:aReg1200[nPos], Self:nOperacao)
aAdd (Self:aReg1200[nPos], Self:dDataDigit)
aAdd (Self:aReg1200[nPos], Self:nCFOP)
aAdd (Self:aReg1200[nPos], Self:cCodItem)
aAdd (Self:aReg1200[nPos], Self:nQtde)
aAdd (Self:aReg1200[nPos], Self:nICMSSup)
aAdd (Self:aReg1200[nPos], Self:nVlrConf)
aAdd (Self:aReg1200[nPos], Self:nCodEnquad)

aReg := Self:aReg1200   
    
RETURN (aReg)


/**/
//-------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Métodos que Limpa o array dos registros
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
METHOD Clear(nReg) CLASS BLOCOREG
    Local aReg:= {}
    
    IF nReg == "0150"
        aReg:= Self:aReg0150:= {}
    ELSEIF nReg == "0200"
        aReg:= Self:aReg0200:= {}
    ELSEIF nReg == "0205"
        aReg:= Self:aReg0205:= {}
    ELSEIF nReg == "1050"
        aReg:= Self:aReg1050:= {}
    ELSEIF nReg == "1100"
        aReg:= Self:aReg1100:= {}
    ELSEIF nReg == "1200"
        aReg:= Self:aReg1200:= {}
    ENDIF
RETURN aReg


//-------------------------------------------------------------------
/*/{Protheus.doc} NumSignif
 
Função que trata os numeros significativos no arquivo
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------

Static Function NumSignif(nValor, nDecimal)
Local cNum	  := ''
Local nVal	  := Val(cValtochar(nValor))
Local nX      := 0
Local nTam    := 0  // Tamanho
Local cCont   := "" // Conteudo
Local lNumSig := .F.
Local cPosV   := 0
Local cPos    := 0
Local nDif    := 0

//Caso a quantidade de decimais venha igua a zero, será adotado default que é 2
If nDecimal == 0
    nDecimal	:= 2
EndiF    

cNum	:= AllTrim (StrTran (Str (nValor,,nDecimal), ".", ","))   
//Antes de passar nas funções, preciso saber se já não possui 5 números significativos
//Se for menor do que 1, preciso analisar depois da virgula
IF nVal < 1
    //Verifica quantas casas decimais
    nTam := Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum)))
    //Verifica o conteudo depois da virgula
    cCont:= SUBSTR(cNum,AT(",", cNum)+1, len(cNum))
    //Verificando os números depois da virgula
    For nX:=1 To nTam
        //Se for diferente de zero/negativo pego qual é a posição
        IF SUBSTR(cCont, nX, 1 ) <> "0" .And. SUBSTR(cCont, nX, 1 ) <> "-"
            //Pego a posicao
            cPos:=  AT(SUBSTR(cCont, nX, 1 ), cCont)
            //Verifico se daquela posicao até o final possui 5 caracteres
            IF Len(SUBSTR(cCont, cPos, Len(cCont) )) >= 5
                lNumSig := .T.
                Exit
            //Se não possui precisa completar com zeros a direita
            Else
                nDif := 5-Len(SUBSTR(cCont, cPos, Len(cCont) )) 
                cNum += ZerosSig(nDif)
                Exit    
            EndIf
        EndIf
    Next
//Se for maior que 1 preciso verificar desde o começo
ElseIf nVal > 0
    nTam:= Len(cNum)
    cCont := cNum
    For nX:=1 To nTam
        //Se for diferente de zero, virgula e negativo pego qual é a posição
        IF SUBSTR(cCont, nX, 1 ) <> "0" .And. SUBSTR(cCont, nX, 1 ) <> "," .And. SUBSTR(cCont, nX, 1 ) <> "-"
            //Pego a posicao
            cPos:=  AT(SUBSTR(cCont, nX, 1 ), cCont)
            //Verifico qual a posição da Virgula
            cPosV := AT(",", cCont)
            //Se a posição da virgula for maior que a posição do número encontrado, siginifica que a virgula vem depois, logo considero uma posição a mais, somando 1
            IF cPosV > cPos
                //Verifico se daquela posicao até o final possui 5 caracteres
                IF (Len(SUBSTR(cCont, cPos, Len(cCont) )) + 1) >= 5
                    lNumSig := .T.
                    Exit
                    //Se não possui precisa completar com zeros a direita
                Else
                    nDif := 5-Len(SUBSTR(cCont, cPos, Len(cCont) )) 
                    cNum += ZerosSig(nDif)
                    Exit 
                EndIf
                //Se a posição da virgula for menor que a posição do número encontrado, siginifica que a virgula veio antes, logo não preciso somar 1
            Else
                IF (Len(SUBSTR(cCont, cPos, Len(cCont) )) ) >= 5
                    lNumSig := .T.
                    Exit
                    //Se não possui precisa completar com zeros a direita
                Else
                    nDif := 5-Len(SUBSTR(cCont, cPos, Len(cCont) )) 
                    cNum += ZerosSig(nDif)
                    Exit     
                EndIf
            EndIf
        EndIf
    Next
EndIf
    
//Verificação de quantidade de casas decimais no cNum, pois não pode ultrapassar 12 casas decimais
If Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) > 12
    //Valor sem estrapolar as 12 casas decimais
    cNum:= Left(cNum, Len(cNum) - (Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) - 12))
EndIf
    
Return cNum


/*/{Protheus.doc} ZerosSig
 
Esta função retorna a quantidade de zeros que será necessário inserir nos números que não forem significativos
            
@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
Static Function ZerosSig(nTam)

Local nX   := 0
Local cNum := ""

For nX:=1 To nTam
    cNum += "0"
Next

Return cNum

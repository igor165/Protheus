#Include 'Protheus.ch'
#Include 'totvs.ch'

Function FISA104(); RETURN
    
    /*Classe da Tabela temporaria*/  
    


//-------------------------------------------------------------------
/*/{Protheus.doc} TEMPORARIA
 
Classe da tabela Temporaria
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------    
CLASS TEMPORARIA
    
    Data cAliasTmp		as String		READONLY		//Alias da tabela temporária que deverá ser criada
    Data cArqTmp			as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
    Data cAliasCAd		as String		READONLY		//Alias da tabela temporária que deverá ser criada
    Data cArqCad			as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
    Data cIndice			as String		READONLY		//Indíce que deverá ser utilizado na criação da tabela
    Data cDelimit			as String		READONLY		//Delimitador para separação entre os campos do registro
    Data aCampos			as Array		READONLY		//Array com estrutura da tabela a ser criada.
    Data aRegistro		as Array		READONLY		//Array com informação do registro a ser processado
    Data nPosRelac		as Integer		READONLY		//Posição do array que representa
    Data cLinhaTxt		as String 		READONLY		//Linha que deverá ser gravada na tabela
    Data cGrupo			as String 		READONLY		//Conteúdo do grupo que deverá ser gravado na tabela.
    Data cBloco			as String 		READONLY		//Número do bloco que deverá ser gravado na tabela.
    Data cRegistro		as String 		READONLY		
    Data cDiretorio		as String 		READONLY		
    Data cPathArq			as String 		READONLY		
    Data cNomeArq			as String 		READONLY		
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
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD New() CLASS TEMPORARIA
    
    Self:aRegistro	:={}
    
RETURN
METHOD SetcAliasTmp( cAliasTmp) CLASS TEMPORARIA
    Self:cAliasTmp := cAliasTmp
RETURN

METHOD SetcArqTmp( cArqTmp) CLASS TEMPORARIA
    Self:cArqTmp := cArqTmp
RETURN

METHOD SetcAliasCAd( cAliasCAd) CLASS TEMPORARIA
    Self:cAliasCAd := cAliasCAd
RETURN

METHOD SetcArqCad( cArqCad) CLASS TEMPORARIA
    Self:cArqCad := cArqCad
RETURN

METHOD SetcIndice( cIndice) CLASS TEMPORARIA
    Self:cIndice := cIndice
RETURN

METHOD SetcDelimit( cDelimit)   CLASS TEMPORARIA
    Self:cDelimit := cDelimit
RETURN

METHOD SetaCampos( aCampos) CLASS TEMPORARIA
    Self:aCampos := aCampos
RETURN

METHOD SetaRegistro( aRegistro) CLASS TEMPORARIA
    Self:aRegistro := aRegistro
RETURN

METHOD SetnPosRelac( nPosRelac) CLASS TEMPORARIA
    Self:nPosRelac := nPosRelac
RETURN

METHOD SetcLinhaTxt( cLinhaTxt) CLASS TEMPORARIA
    Self:cLinhaTxt := cLinhaTxt
RETURN

METHOD SetcGrupo( cGrupo)    CLASS TEMPORARIA
    Self:cGrupo := cGrupo
RETURN

METHOD SetcBloco( cBloco)   CLASS TEMPORARIA
    Self:cBloco := cBloco
RETURN

METHOD SetcRegist( cRegistro)   CLASS TEMPORARIA
    Self:cRegistro := cRegistro
RETURN

METHOD SetcDireto( cDiretorio)  CLASS TEMPORARIA
    Self:cDiretorio := cDiretorio
RETURN

METHOD SetcPathArq( cPathArq)   CLASS TEMPORARIA
    Self:cPathArq := cPathArq
RETURN

METHOD SetcNomeArq( cNomeArq)   CLASS TEMPORARIA
    Self:cNomeArq := cNomeArq
RETURN

METHOD SetcRecno( cRecno)   CLASS TEMPORARIA
    Self:cRecno := cRecno
RETURN

METHOD GetAlias()   CLASS TEMPORARIA
RETURN Self:cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela
 
Método que irá criar a tabela temporária para gravação dos registros
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD CriaTabela() CLASS TEMPORARIA
    Local aCmp		:= {}
    Local cArquivo      := "CAT83"+GetDBExtension() /*Recupera o nome fisico gerado*/
    Local cAliasTRB     := "CAT83"
    
    aAdd (aCmp, {'NROBLOCO',	'C', 	002,	0})	/*Número do bloco*/
    aAdd (aCmp, {'REGISTRO',	'C', 	004,	0})	/*Registro que deverá ser gravado*/
    aAdd (aCmp, {'GRUPO',	'C', 	052,	0})	/*Código do grupo utilizado para ordenação da tabela, no momento da gravação do arquivo texto*/
    aAdd (aCmp, {'CONTEUDO',	'C', 	500,	0})	/*Conteúdo da linha a ser gravada no arquivo texto*/
    
    Self:cAliasTmp		:= cAliasTRB
    Self:cArqTmp			:= cArquivo
    
    
    Self:cArqTmp	:= CriaTrab (aCmp)
    DbUseArea (.T., __LocalDriver, Self:cArqTmp, Self:cAliasTmp)
    IndRegua (Self:cAliasTmp, Self:cArqTmp, 'NROBLOCO+GRUPO+REGISTRO')
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela
 
Método que apaga a tabela temporária criada para geração do arquivo texto
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD DelTabela() CLASS TEMPORARIA
    
    /*Está função fecha a tabela temporária*/
    FWCLOSETEMP(Self:cAliasTmp)
    
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvReg
 
Método de Gravação
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD GrvReg(aRegistro) CLASS TEMPORARIA
    
    /*Passa array para CLASSe*/
    Self:aRegistro	:= aRegistro
    
    /*Grava o registro*/
    Self:GeraLinha()
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvReg
 
Método que monta a linha a ser denonstrada no arquivo
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD GeraLinha() CLASS TEMPORARIA
    Local nContR		:= 0
    Local nContC		:= 0
    Local nDecimal	:= 2
    Local cLinha		:= ''
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
            
          /*   IF Self:aRegistro[1][2] == '5365' .And.  Self:aRegistro[1][3] == "1079"
                ALERT('ESSE')
            ENDIF*/
            
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
                cConteudo	:= AllTrim (StrTran (Str (Self:aRegistro[nContR][nContC],,nDecimal), ".", ","))
            ElseIF cType == 'C'
                cConteudo	:= AllTrim (Self:aRegistro[nContR][nContC])
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
    
   
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} GravaLinha
 
Método que efetua a gravação da linha na tabela temporaria
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD GravaLinha() CLASS TEMPORARIA
    
    RecLock(Self:cAliasTmp,.T.)
    Replace NROBLOCO 			With Self:cBloco
    Replace REGISTRO    		With Self:cRegistro
    Replace GRUPO     		With Self:cGrupo
    Replace CONTEUDO     	With Self:cLinhaTxt
    (Self:cAliasTmp)->(MsUnLock())
    
RETURN


 //-------------------------------------------------------------------
/*/{Protheus.doc} GravaTXT
 
Método que efetua a gravação do arquivo texto
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD GravaTXT() CLASS TEMPORARIA
    
    Local cNomeTmp	:= Self:cDiretorio+'CAT83 - '+cFilAnt+'.Txt'
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
        Alert('Erro ao gravar arquivo texto')
    EndIF
    
Return Iif(lErro,cNomeTmp,'')

//-------------------------------------------------------------------
/*/{Protheus.doc} CAT83
 
Classe que gera os registro do Bloco Zero e abertura e fechamento
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------    

CLASS CAT83
    
    /*ATRIBUTOS DA CLASSE*/
    
    /*Genéricos*/
    Data cReg			as String		READONLY
    Data aReg			as Array		READONLY
    Data cGrupoReg	As String		READONLY		//Grupo do registro
    Data cRelac		as String		READONLY		//Esta variável terá o conteúdo de relacionamento para gravação na tabela.
    Data aNumeracao	as Array		READONLY
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
    METHOD ClearCat83()
    METHOD SetcReg( cReg)
    METHOD setaNumer()
    METHOD setRelac(cRelac)
    METHOD AbreBloco(cReg,aReg,cIndMov)
    METHOD FechaBloco(cReg,aReg, nQtde)
    METHOD get9900()
    METHOD Add0001()
    METHOD Add0990()
    METHOD Add5001()
    METHOD Add5990(nQtde)
    METHOD Add9900(cReg,nQtde)
    METHOD Add9001()
    METHOD Add9990()
    METHOD Add9999()
    METHOD getGrupo()
    
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
 
Método que inicializa/limpa todos os atributos da CLASSe
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD New() CLASS CAT83
    Self:ClearCat83()
RETURN

METHOD ClearCat83() CLASS CAT83
    Self:cReg			:= ''
    Self:cGrupoReg	:= ''
    Self:cRelac		:= ''
    Self:aNumeracao	:= {}
    Self:aReg			:= {}
    Self:aReg0000		:= {}
    Self:aReg0001		:= {}
    Self:aReg0990		:= {}
    Self:aReg5001		:= {}
    Self:aReg5990		:= {}
    Self:aReg9001		:= {}
    Self:aReg9900		:= {}
    Self:aReg9990		:= {}
    Self:aReg9999		:= {}
RETURN

METHOD SetcReg( cReg) CLASS CAT83
    Self:cReg := cReg
RETURN

METHOD setaNumer( aNumeracao) CLASS CAT83
    Self:aNumeracao := aNumeracao
RETURN

METHOD setRelac( cRelac) CLASS CAT83
    Self:cRelac := cRelac
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreBloco
 
Método que faz a abertura de Blocos
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------    
METHOD AbreBloco(cReg,aReg,cIndMov) CLASS CAT83
    
    Local nPos	:= 0
    
    Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,'', cReg)
    aAdd(aReg, {})
    nPos := Len(aReg)
    aAdd (aReg[nPos], Self:cGrupoReg)       /*Relacionamento com registro pai*/
    aAdd (aReg[nPos], cReg)                 /*Registro*/
    aAdd (aReg[nPos], cIndMov)              /*Indica se tem ou não movimento*/
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaBloco
 
Método que faz o fechamento de Blocos
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD FechaBloco(cReg,aReg, nQtde) CLASS CAT83
    
    Local nPos	:= 0
    
    Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,'', cReg)
    aAdd(aReg, {})
    nPos := Len(aReg)
    aAdd (aReg[nPos], Self:cGrupoReg)       /*Relacionamento com registro pai*/
    aAdd (aReg[nPos], cReg)                 /*Registro*/
    aAdd (aReg[nPos], nQtde)                /*Indica se tem ou não movimento*/
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0001
 
Método para geração de Abertura do Bloco 0
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 

METHOD Add0001(cIndMovto) CLASS CAT83
    
    Self:AbreBloco('0001',@Self:aReg0001,cIndMovto)
    
RETURN Self:aReg0001

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0990
 
Método para geração do registro de Encerramento do bloco 0
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD Add0990(nQtde) CLASS CAT83
    
    Self:FechaBloco('0990',@Self:aReg0990, nQtde)
    
RETURN Self:aReg0990

//-------------------------------------------------------------------
/*/{Protheus.doc} Add5001
 
Método para geração de Abertura do Bloco 5
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD Add5001(cIndMovto) CLASS CAT83
    
    Self:AbreBloco('5001',@Self:aReg5001,cIndMovto)
    
RETURN Self:aReg5001


//-------------------------------------------------------------------
/*/{Protheus.doc} Add5990
 
Método para geração do registro de Encerramento do bloco 5
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD Add5990(nQtde) CLASS CAT83
    
    Self:FechaBloco('5990',@Self:aReg5990, nQtde)
    
RETURN Self:aReg5990

//-------------------------------------------------------------------
/*/{Protheus.doc} Add9001
 
Método para Abertura Bloco 9 - Reg9001
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 
METHOD Add9001(cIndMovto) CLASS CAT83
    
    Self:AbreBloco('9001',@Self:aReg9001,cIndMovto)
    
RETURN Self:aReg9001

/*Métodos para os registros do Bloco 9 - Reg 9900*/
//-------------------------------------------------------------------
/*/{Protheus.doc} Add9900
 
Método para definir o grupo para saber de qual registro o 9900 pertence
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add9900(cReg,nQtde) CLASS CAT83
    Local nPos	:= 0
    
    nPos := aScan (Self:aReg9900, {|aX| aX[3]==cReg})
    IF nPos == 0
        Self:cGrupoReg		:= (@Self:aNumeracao,'', '9900')
        aAdd(Self:aReg9900,{})
        nPos :=	Len (Self:aReg9900)
        aAdd (Self:aReg9900[nPos], Self:cGrupoReg)
        aAdd (Self:aReg9900[nPos], '9900')          /*Regsistro 9900*/
        aAdd (Self:aReg9900[nPos], cReg)            /*Registro que esta sendo calculado*/
        aAdd (Self:aReg9900[nPos], nQtde)           /*Quantidade de Registros*/
    Else
        Self:aReg9900[nPos][4] +=	nQtde            /*Quantidade de Registros*/
    ENDIF
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} ADD9990
 
Fechamento Bloco 9 - Reg 9990
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD ADD9990(nQtde) CLASS CAT83
    Self:FechaBloco('9990',@Self:aReg9990, nQtde)
RETURN Self:aReg9990


//-------------------------------------------------------------------
/*/{Protheus.doc} ADD9999
 
Método de Encerramento do Arquivo Digital
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD ADD9999(nQtde) CLASS CAT83
    Self:FechaBloco('9999',@Self:aReg9999, nQtde)
RETURN Self:aReg9999

METHOD getGrupo() CLASS CAT83
RETURN Self:cGrupoReg

METHOD get9900() CLASS CAT83
RETURN Self:aReg9900


//-------------------------------------------------------------------
/*/{Protheus.doc} BLOCO0
 
Classe de geração do Bloco Zero
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------- 

CLASS BLOCO0 FROM CAT83
    
    /*Bloco 0000*/
    Data cReg			as String		READONLY
    Data cLadca		as String		READONLY
    Data cVersao		as String		READONLY
    Data cFinalid		as String		READONLY
    Data cPeriodo		as String		READONLY
    Data cNome		as String		READONLY
    Data cIE			as String		READONLY
    Data cCnae		as String		READONLY
    Data cCodMun		as String		READONLY
    Data cCredOut		as String		READONLY
    Data cIEIntim		as String		READONLY
    
    /*Registro 0150*/
    Data cCodPar	   as String	READONLY
    Data nPais      as Integer	READONLY
    Data nCNPJ      as Integer	READONLY
    Data cUF        as String	READONLY
    Data nCep       as Integer	READONLY
    Data cEnd       as String	READONLY
    Data cNum       as String	READONLY
    Data cComp      as String	READONLY
    Data cBairro    as String	READONLY
    Data nCodMun    as Integer	READONLY
    Data nFone      as Integer	READONLY
    Data aReg0150   as Array	READONLY
    
    /*Registro 0200*/
    Data cCodItem   as  String	READONLY
    Data cDescItem  as String	READONLY
    Data cUn        as String	READONLY
    Data cCodGen    as String	READONLY
    
    /*Registro 0205*/
    Data cCodAnt    as String	READONLY
    Data cDescAnt   as String	READONLY
    Data cPEIni     as Integer	READONLY
    Data cPEFim     as Integer	READONLY
    
    /*Registro 0300*/
    Data nCodLeg    as Integer	READONLY
    Data nDesc      as Integer	READONLY
    Data cAnex      as String	READONLY
    Data cArt       as String	READONLY
    Data cInc       as String	READONLY
    Data cAlin      as String	READONLY
    Data cPrg       as String	READONLY
    Data cItm       as String	READONLY
    Data cLtr       as String	READONLY
    Data cObs       as String	READONLY
    
    /*Registro 0400*/
    Data cChave     as Integer  READONLY
    Data cDescr     as String   READONLY
    Data cCodDoc    as String   READONLY
    
    /*Arrays dos registros*/
    Data aReg0200   as Array    READONLY
    Data aReg0205   as Array    READONLY
    Data aReg0300   as Array    READONLY
    Data aReg0400   as Array    READONLY
    
    /*Métodos Registro 0000*/
    METHOD SetcLadca(cLadca)
    METHOD SetcVersao(cNome)
    METHOD SetcFinalid(cFinalid)
    METHOD SetcPeriodo(cPeriodo)
    METHOD SetcNome(cNome)
    METHOD SetcIE(cIE)
    METHOD SetcCnae(cCnae)
    METHOD SetsetUF(cCodMun)
    METHOD SetcCredOut(cCredOut)
    METHOD SetcIEIntim(cIEIntim)
    
    
    /*Métodos Registro 0150*/
    METHOD SetcCodPar(cCodPar)
    METHOD SetnPais(nPais)
    METHOD SetnCNPJ(nCNPJ)
    METHOD SetcUF(cUF)
    METHOD SetnCep(nCep)
    METHOD SetcEnd(cEnd)
    METHOD SetcNum(cNum)
    METHOD SetcComp(cComp)
    METHOD SetcBairro(cBairro)
    METHOD SetnCodMun(nCodMun)
    METHOD SetnFone(nFone)
    
    /*Métodos Registro 0200*/
    METHOD SetcCodItem(cCodItem)
    METHOD SetcDescItem(cDescItem)
    METHOD SetcUn(cUn)
    METHOD SetcCodGen(cCodGen)
    
    /*Métodos Registro 0205*/
    METHOD SetcCodAnt(cCodAnt)
    METHOD SetcDescAnt(cDescAnt)
    METHOD SetcPEIni(cPEIni)
    METHOD SetcPEFim(cPEFim)
    
    /*Métodos Registro 0300*/
    METHOD SetnCodLeg(nCodLeg)
    METHOD SetnDesc(nDesc)
    METHOD SetcAnex(cAnex)
    METHOD SetcArt(cArt)
    METHOD SetcInc(cInc)
    METHOD SetcAlin(cAlin)
    METHOD SetcPrg(cPrg)
    METHOD SetcItm(cItm)
    METHOD SetcLtr(cLtr)
    METHOD SetcObs(cObs)
    
    /*Métodos registro 0400*/
    METHOD SetcChave(cChave)
    METHOD SetcDescr(cDescr)
    METHOD SetcCodDoc(cCodDoc)
    
    METHOD  Add0000(cReg)
    METHOD  Add0150(cReg)
    METHOD  Add0200(cReg)
    METHOD  Add0205(cReg)
    METHOD  Add0300(cReg)
    METHOD  Add0400(cReg)
    
    METHOD New()
    
    /*Limpa os Arrays dos Registros*/
    METHOD Clear(nReg)
    
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS BLOCO0
    /*0000*/
    Self:cLadca         := ''
    Self:cVersao        := ''
    Self:cFinalid       := ''
    Self:cPeriodo       := ''
    Self:cNome          := ''
    Self:cIE            := ''
    Self:cCnae          := ''
    Self:cCodMun        := ''
    Self:cCredOut       := ''
    Self:cIEIntim       := ''
    
    /*0150*/
    Self:cCodPar        := ''
    Self:cNome          := ''
    Self:nPais          := 0
    Self:nCNPJ          := 0
    Self:cIE            := ''
    Self:cUF            := ''
    Self:nCep           := 0
    Self:cEnd           := ''
    Self:cNum           := ''
    Self:cComp          := ''
    Self:cBairro        := ''
    Self:nCodMun        := 0
    Self:nFone          := 0
    
    /*0200*/
    Self:cCodItem       := ''
    Self:cDescItem      :=  ''
    Self:cUn            := ''
    Self:cCodGen        := ''
    
    /*0205*/
    Self:cCodAnt        := ''
    Self:cDescAnt       := ''
    Self:cPEIni         := 0
    Self:cPEFim         := 0
    
    /*0300*/
    Self:nCodLeg        := 0
    Self:nDesc          := 0
    Self:cAnex          := ''
    Self:cArt           := ''
    Self:cInc           := ''
    Self:cAlin          := ''
    Self:cPrg           := ''
    Self:cItm           := ''
    Self:cLtr           := ''
    Self:cObs           := ''
    
    /*0400*/
    Self:cChave         := 0
    Self:cDescr         := ''
    Self:cCodDoc        := ''

    /*Arrays*/
    Self:aReg0000       := {}
    Self:aReg0150       := {}
    Self:aReg0200       := {}
    Self:aReg0205       := {}
    Self:aReg0300       := {}
    Self:aReg0400       := {}
    
    Self:ClearCat83()
RETURN


/*Métodos Reg 0000*/
METHOD SetcLadca( cLadca) CLASS BLOCO0
    Self:cLadca := cLadca
RETURN
METHOD SetcVersao( cVersao) CLASS BLOCO0
    Self:cVersao := cVersao
RETURN
METHOD SetcFinalid( cFinalid) CLASS BLOCO0
    Self:cFinalid := cFinalid
RETURN
METHOD SetcPeriodo( cPeriodo) CLASS BLOCO0
    Self:cPeriodo := cPeriodo
RETURN
METHOD SetcNome( cNome) CLASS BLOCO0
    Self:cNome := cNome
RETURN
METHOD SetnCNPJ( nCNPJ) CLASS BLOCO0
    Self:nCNPJ := nCNPJ
RETURN
METHOD SetcIE( cIE) CLASS BLOCO0
    Self:cIE := cIE
RETURN
METHOD SetcCnae( cCnae) CLASS BLOCO0
    Self:cCnae := cCnae
RETURN
METHOD SetsetUF( cCodMun) CLASS BLOCO0
    Self:cCodMun := cCodMun
RETURN
METHOD SetcCredOut( cCredOut) CLASS BLOCO0
    Self:cCredOut := cCredOut
RETURN
METHOD SetcIEIntim( cIEIntim) CLASS BLOCO0
    Self:cIEIntim := cIEIntim
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0000
 
Método para geração do registro de Abertura do Arquivo
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0000(cReg) CLASS BLOCO0
    Local nPos		:= 0
    
    Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,'', '0000')
    
    aAdd(Self:aReg0000, {})
    nPos:=	Len (Self:aReg0000)
    aAdd (Self:aReg0000[nPos], Self:cGrupoReg)  /*Grupo do Registro*/
    aAdd (Self:aReg0000[nPos], cReg)            /*01-Texto Fixo Contendo "0000"*/
    aAdd (Self:aReg0000[nPos], Self:cLadca)     /*02-Texto Fixo Contendo "LADCA"*/
    aAdd (Self:aReg0000[nPos], Self:cVersao)    /*03-Código da Versão do Layout conforme tabela 3.1*/
    aAdd (Self:aReg0000[nPos], Self:cFinalid)   /*04-Código da Finalidade do arquivo*/
    aAdd (Self:aReg0000[nPos], Self:cPeriodo)   /*05-Período das Informações contidas no arquivo*/
    aAdd (Self:aReg0000[nPos], Self:cNome)      /*06-Nome empresarial do estabelecimento informante*/
    aAdd (Self:aReg0000[nPos], Self:nCNPJ)      /*07-CNPJ do Estabelecimento Informante*/
    aAdd (Self:aReg0000[nPos], Self:cIE)        /*08-Inscrição Estadual do Estabelecimento Informante*/
    aAdd (Self:aReg0000[nPos], Self:cCnae)      /*09-CNAE do Estabelecimento Informante*/
    aAdd (Self:aReg0000[nPos], Self:cCodMun)    /*10-Código do Municipio do Estabelecimento Informante*/
    aAdd (Self:aReg0000[nPos], Self:cCredOut)   /*11-Opção de Crédito Outorgado*/
    aAdd (Self:aReg0000[nPos], Self:cIEIntim)   /*12-IE em caso de Intimação*/
    aReg := Self:aReg0000
    
RETURN (aReg)


/*Métodos Reg 0150*/
METHOD SetcCodPar(cCodPar)	 CLASS BLOCO0
    Self:cCodPar := cCodPar
RETURN
METHOD SetnPais(nPais) CLASS BLOCO0
    Self:nPais := nPais
RETURN
METHOD SetcUF(cUF) CLASS BLOCO0
    Self:cUF := cUF
RETURN
METHOD SetnCep(nCep) CLASS BLOCO0
    Self:nCep := nCep
RETURN
METHOD SetcEnd(cEnd) CLASS BLOCO0
    Self:cEnd := cEnd
RETURN
METHOD SetcNum(cNum) CLASS BLOCO0
    Self:cNum := cNum
RETURN
METHOD SetcComp(cComp) CLASS BLOCO0
    Self:cComp := cComp
RETURN
METHOD SetcBairro(cBairro) CLASS BLOCO0
    Self:cBairro := cBairro
RETURN
METHOD SetnCodMun(nCodMun) CLASS BLOCO0
    Self:nCodMun := nCodMun
RETURN
METHOD SetnFone(nFone)	 CLASS BLOCO0
    Self:nFone := nFone
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0150
 
Método para geração do registro 0150
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0150(cReg) CLASS BLOCO0
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '0150')
        aAdd (Self:aReg0150, {})
        nPos	:=	Len (Self:aReg0150)
        aAdd (Self:aReg0150[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0150[nPos], cReg)
        aAdd (Self:aReg0150[nPos], Self:cCodPar)
        aAdd (Self:aReg0150[nPos], Self:cNome)
        aAdd (Self:aReg0150[nPos], Self:nPais)
        aAdd (Self:aReg0150[nPos], Self:nCNPJ)
        aAdd (Self:aReg0150[nPos], Self:cIE)
        aAdd (Self:aReg0150[nPos], Self:cUF)
        aAdd (Self:aReg0150[nPos], Self:nCep)
        aAdd (Self:aReg0150[nPos], Self:cEnd)
        aAdd (Self:aReg0150[nPos], Self:cNum)
        aAdd (Self:aReg0150[nPos], Self:cComp)
        aAdd (Self:aReg0150[nPos], Self:cBairro)
        aAdd (Self:aReg0150[nPos], Self:nCodMun)
        aAdd (Self:aReg0150[nPos], Self:nFone)
        aReg := Self:aReg0150
RETURN (aReg)

/*Métodos Registro 0200*/
METHOD SetcCodItem(cCodItem)    CLASS BLOCO0
    Self:cCodItem := cCodItem
RETURN
METHOD SetcDescItem(cDescItem)  CLASS BLOCO0
    Self:cDescItem := cDescItem
RETURN
METHOD SetcUn(cUn)  CLASS BLOCO0
    Self:cUn := cUn
RETURN
METHOD SetcCodGen(cCodGen)  CLASS BLOCO0
    Self:cCodGen := cCodGen
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0200
 
Método para geração do registro 0200
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0200(cReg)    CLASS BLOCO0
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '0200')
        aAdd (Self:aReg0200, {})
        nPos	:=	Len (Self:aReg0200)
        aAdd (Self:aReg0200[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0200[nPos], cReg)
        aAdd (Self:aReg0200[nPos], Self:cCodItem)
        aAdd (Self:aReg0200[nPos], Self:cDescItem)
        aAdd (Self:aReg0200[nPos], Self:cUn)
        aAdd (Self:aReg0200[nPos], Self:cCodGen)
        aReg := Self:aReg0200
RETURN (aReg)

/*Métodos Reg 0205*/
METHOD SetcCodAnt(cCodAnt) 	 CLASS BLOCO0
    Self:cCodAnt := cCodAnt
RETURN
METHOD SetcDescAnt(cDescAnt) 	 CLASS BLOCO0
    Self:cDescAnt := cDescAnt
RETURN
METHOD SetcPEIni(cPEIni) 	 CLASS BLOCO0
    Self:cPEIni := cPEIni
RETURN
METHOD SetcPEFim(cPEFim) 	 CLASS BLOCO0
    Self:cPEFim := cPEFim
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0205
 
Método para geração do registro 0205
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0205(cReg) CLASS BLOCO0
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '0205')
        aAdd (Self:aReg0205, {})
        nPos	:=	Len (Self:aReg0205)
        aAdd (Self:aReg0205[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0205[nPos], cReg)
        aAdd (Self:aReg0205[nPos], Self:cCodAnt)
        aAdd (Self:aReg0205[nPos], Self:cDescAnt)
        aAdd (Self:aReg0205[nPos], Self:cPEIni)
        aAdd (Self:aReg0205[nPos], Self:cPEFim)
        aReg := Self:aReg0205
RETURN (aReg)

/*Métodos Reg 0300*/
METHOD SetnCodLeg(nCodLeg) CLASS BLOCO0
    Self:nCodLeg := nCodLeg
RETURN
METHOD SetnDesc(nDesc) CLASS BLOCO0
    Self:nDesc := nDesc
RETURN
METHOD SetcAnex(cAnex)CLASS BLOCO0
    Self:cAnex := cAnex
RETURN
METHOD SetcArt(cArt)CLASS BLOCO0
    Self:cArt := cArt
RETURN
METHOD SetcInc(cInc)CLASS BLOCO0
    Self:cInc := cInc
RETURN
METHOD SetcAlin(cAlin)CLASS BLOCO0
    Self:cAlin := cAlin
RETURN
METHOD SetcPrg(cPrg)CLASS BLOCO0
    Self:cPrg := cPrg
RETURN
METHOD SetcItm(cItm)CLASS BLOCO0
    Self:cItm := cItm
RETURN
METHOD SetcLtr(cLtr)CLASS BLOCO0
    Self:cLtr := cLtr
RETURN
METHOD SetcObs(cObs)CLASS BLOCO0
    Self:cObs := cObs
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0300
 
Método para geração do registro 0300
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0300(cReg) CLASS BLOCO0
    Local aReg       := {}

        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '0300')
        aAdd (Self:aReg0300, {})
        nPos	:=	Len (Self:aReg0300)
        aAdd (Self:aReg0300[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0300[nPos], cReg)
        aAdd (Self:aReg0300[nPos], Self:nCodLeg)
        aAdd (Self:aReg0300[nPos], Self:nDesc)
        aAdd (Self:aReg0300[nPos], Self:cAnex)
        aAdd (Self:aReg0300[nPos], Self:cArt)
        aAdd (Self:aReg0300[nPos], Self:cInc)
        aAdd (Self:aReg0300[nPos], Self:cAlin)
        aAdd (Self:aReg0300[nPos], Self:cPrg)
        aAdd (Self:aReg0300[nPos], Self:cItm)
        aAdd (Self:aReg0300[nPos], Self:cLtr)
        aAdd (Self:aReg0300[nPos], Self:cObs)
        aReg := Self:aReg0300

RETURN (aReg)

/*Métodos registro 0400*/
METHOD SetcChave(cChave)CLASS BLOCO0
    Self:cChave := cChave
RETURN

METHOD SetcDescr(cDescr)CLASS BLOCO0
    Self:cDescr := cDescr
RETURN
METHOD SetcCodDoc(cCodDoc)CLASS BLOCO0
    Self:cCodDoc := cCodDoc
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0400
 
Método para geração do registro 0400
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Add0400(cReg) CLASS BLOCO0
    Local nPos		:= 0
    Local aReg       := {}
    
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '0400')
        aAdd (Self:aReg0400, {})
        nPos	:=	Len (Self:aReg0400)
        aAdd (Self:aReg0400[nPos], Self:cGrupoReg)
        aAdd (Self:aReg0400[nPos], cReg)
        aAdd (Self:aReg0400[nPos], Self:cChave)
        aAdd (Self:aReg0400[nPos], Self:cDescr)
        aAdd (Self:aReg0400[nPos], Self:cCodDoc)
        aReg := Self:aReg0400   
    
RETURN (aReg)

/**/
//-------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Métodos que Limpa o array dos registros
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD Clear(nReg) CLASS BLOCO0
    Local aReg:= {}
    
    IF nReg == "0150"
        aReg:= Self:aReg0150:= {}
    ELSEIF nReg == "0200"
        aReg:= Self:aReg0200:= {}
    ELSEIF nReg == "0205"
        aReg:= Self:aReg0205:= {}
    ELSEIF nReg == "0300"
        aReg:= Self:aReg0300:= {}
    ELSEIF nReg == "0400"
        aReg:= Self:aReg0400:= {}
    ENDIF
RETURN aReg


//-------------------------------------------------------------------
/*/{Protheus.doc} NumSignif
 
Função que trata os numeros significativos no arquivo
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function NumSignif(nValor, nDecimal)
    Local cNum		:= ''
    Local nVal		:= Val(cValtochar(nValor))
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
    
    
    //If nValor <> 0  .And. !lNumSig
    /*If nValor <> 0    
        Do Case
        Case nVal >= 100 //
            //Não será necessário fazer controle de número significativo
        Case nVal >=10 .AND. nVal< 100 //
            //Significa que deverá ter que adicionar mais um zero
            cNum += '0'
        Case nVal >=1 .AND. nVal < 10 //
            //Significa que deverá ter que adicionar mais dois zeros
            cNum += '00'
        Case nVal >=0.10 .AND. nVal < 1
            //Significa que deverá ter que adicionar mais três zeros
            cNum += '000'
        Case nVal >=0.01 .AND. nVal < 0.10
            //Significa que deverá ter que adicionar mais quatro zeros
            cNum += '0000'
        Case nVal >=0.001 .AND. nVal < 0.01
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        Case nVal <=0.001 .And. nVal > 0
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        Case 	nVal < 0 .And. nVal <= (-10) .And. nVal > (-100)
            cNum += '0'
        Case nVal < 0 .And. nVal <= (-1) .AND. nVal > (-10)
            //Significa que deverá ter que adicionar mais dois zeros
            cNum += '00'
        Case nVal < 0 .And. nVal <= (-0.10) .AND. nVal > (-1)
            //Significa que deverá ter que adicionar mais três zeros
            cNum += '000'
        Case nVal < 0 .And. nVal <= (-0.01) .AND. nVal > (-0.10)
            //Significa que deverá ter que adicionar mais quatro zeros
            cNum += '0000'
        Case nVal < 0 .And. nVal <= (-0.001) .AND. nVal > (-0.01)
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        EndCase
    EndIF*/
    
    //Verificação de quantidade de casas decimais no cNum, pois não pode ultrapassar 12 casas decimais
    IF Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) > 12
        //Valor sem estrapolar as 12 casas decimais
        cNum:= Left(cNum, Len(cNum) - (Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) - 12))
    EndIf
    
Return cNum


/*/{Protheus.doc} ZerosSig
 
Esta função retorna a quantidade de zeros que será necessário inserir nos números que não forem significativos
            
@author Graziele Paro
@since 11/01/2017

/*/
Static Function ZerosSig(nTam)

Local nX   := 0
Local cNum := ""

    For nX:=1 To nTam
        cNum += "0"
    Next

Return cNum

#INCLUDE "PROTHEUS.CH"

//Dummy Function
Function FINDTCRECORD()
Return

/*/{Protheus.doc} FINDTCRECORD
    Classe responsavel por realizar gravações nas tabelas
    para os fontes que não são em MVC, substituindo assim o RecLock()
    @author Vitor Duca
    @since 06/08/2021
    @version 1.0
/*/
Class FINDTCRECORD From LongClassName
    
    //Propriedades
    DATA aRecord   as Numeric
    DATA lInsert   as Array
    DATA oBulk     As Object 
    DATA cMessage  As Character
    DATA lUseBulk  As Logical
    DATA cTable    As Character

    //Setters e Getters
    METHOD SetValue(cField,xValue)
    METHOD SetInsert(lInsert)
    METHOD GetError()

    METHOD New(cTable) CONSTRUCTOR
    METHOD Commit()
    METHOD ExecFlush()
    METHOD Clean()
    METHOD Destroy()
    METHOD AddBulk()
    METHOD Reset()

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe, realiza a inicialização
    das propriedades
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
    @param cTable, Character, Tabela onde sera realizado o insert das informações
    @return NIL
    /*/
Method New(cTable) Class FINDTCRECORD
    ::aRecord := {}
    ::lInsert := .T.
    ::cTable  := cTable
    If ::oBulk == NIL
        ::oBulk := FwBulk():New(::cTable)
    Endif    
    ::cMessage := ""
    ::lUseBulk := FwBulk():CanBulk()
Return 

/*/{Protheus.doc} SetValue
    Metodo que ira setar os valores nos campos
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
    @param cField, Character, Campos da tabela que ira receber a atualização
    @param xValue, Undefined, Valor que sera inserido no campo
    @return NIL
    /*/
Method SetValue(cField,xValue) Class FINDTCRECORD
    Aadd(::aRecord, {cField,xValue})
Return 

/*/{Protheus.doc} SetInsert
    Define se sera realizado INSERT ou UPDATE na tabela
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
    @param lInsert, Logical, Define se sera realizado insert na tabela
    @return NIL
    /*/
Method SetInsert(lInsert) Class FINDTCRECORD
    ::lInsert := lInsert
Return 

/*/{Protheus.doc} AddBulk
    Adiciona os campos na classe FwBulk, para realizar o insert 
    posteriormente
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
    @return NIL
/*/
Method AddBulk() Class FINDTCRECORD
    Local aBulk As Array
    Local nX As Numeric

    nX := 0
    aBulk := {}

    For nX := 1 to Len(::aRecord)
        Aadd(aBulk,::aRecord[nX][2])
    Next nX 

    If ::lUseBulk
        If Empty(::oBulk:cFields)
            ::oBulk:SetFields(::aRecord)
        Endif    
		::oBulk:AddData(aBulk)
    
        FwFreeArray(::aRecord)
        ::aRecord := {}
    Endif
Return 

/*/{Protheus.doc} Commit
    Realiza o commit das informações na tabela responsavel pelo processo
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
/*/
Method Commit() Class FINDTCRECORD
    Local nX As Numeric
    Local aBulk As Array
    Local cField As Character

    nX := 0
    aBulk := {}

    If !::lUseBulk
        RecLock(::cTable,::lInsert)
        For nX := 1 to Len(::aRecord)
            cField := ::aRecord[nX][1]
            SE2->&cField := ::aRecord[nX][2]
        Next nX 
        SE2->(MsUnLock())

        FwFreeArray(::aRecord)
        ::aRecord := {}   
    Endif
    		
	If ::lUseBulk
		If !::oBulk:Close()
            ::cMessage := ::oBulk:GetError()
        Endif
 
	Endif
Return 


/*/{Protheus.doc} Reset
    Reseta a propriedad oBulk (FwBulk)
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
/*/
Method Reset() Class FINDTCRECORD
    ::oBulk:Reset() 
Return 

/*/{Protheus.doc} ExecFlush
    Executa flush dos dados, caso haja a necessidade de realizar o commit
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
/*/
Method ExecFlush() Class FINDTCRECORD
    If !::oBulk:Flush()
        ::cMessage := ::oBulk:GetError()
    Endif    
Return 

/*/{Protheus.doc} Clean
    Inicializa as propriedades da classe
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
/*/
Method Clean() Class FINDTCRECORD
    FwFreeArray(::aRecord)
    ::aRecord := {}
    ::lInsert := .T.
    ::cMessage := ""

    If ::oBulk <> NIL 
        ::oBulk:Destroy()
        ::oBulk := nil
    Endif

Return 

/*/{Protheus.doc} Destroy
    Destroi e libera a memoria alocada pela classe
    @author Vitor Duca
    @since 09/08/2021
    @version 1.0
/*/
Method Destroy() Class FINDTCRECORD
    
    If ::oBulk <> NIL 
        ::oBulk:Destroy()
        ::oBulk := nil
    Endif

    FwFreeObj(Self)
Return NIL

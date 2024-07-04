#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc}Mt110Grv
    ponto de entrada executado no laco de gravação dos itens da SC na 
    função A110GRAVA, após gravar o item da SC, a cada item gravado 
    da SC.
    Usado para gravar o campo C1_XAPROV, replicado com o conteúdo do campo 
    C1_APROV.

@since 20170328
@author JRScatolon
@return Nil, Nenhum valor.  
/*/
user function Mt110Grv()

if Inclui .or. lCopia
    RecLock("SC1", .f.)
        SC1->C1_XAPROV := Replicate(SC1->C1_APROV, TamSX3("C1_XAPROV")[1])
    MsunLock()
endif	

return nil
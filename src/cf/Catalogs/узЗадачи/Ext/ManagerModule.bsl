﻿
// СтандартныеПодсистемы.В23ерсионированиеОбъектов
// Определяет настройки объекта для подсистемы ВерсионированиеОбъектов.
//
// Параметры:
// Настройки - Структура - настройки подсистемы.
Процедура ПриОпределенииНастроекВерсионированияОбъектов(Настройки) Экспорт
	Настройки.ПриПолученииСлужебныхРеквизитов = Истина;
КонецПроцедуры

// Ограничивает видимость реквизитов объекта в отчете по версии.
//
// Параметры:
// Реквизиты - Массив - список имен реквизитов объекта.
Процедура ПриПолученииСлужебныхРеквизитов(Реквизиты) Экспорт
    //Реквизиты.Добавить("ИмяРеквизита"); // реквизит объекта
    //Реквизиты.Добавить("ИмяТабличнойЧасти.*"); // табличная часть объекта
КонецПроцедуры
// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов

//+ #201 Иванов А.Б. 2020-05-23 Изменения от Дениса Урянского @d-hurricane
// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЗначениеРазрешено(Ссылка)";
	
КонецПроцедуры //- #201 Иванов А.Б. 2020-05-23 Изменения от Дениса Урянского @d-hurricane

Функция ПолучитьНомерЗадачи(ЗадачаСсылка) Экспорт 
	Возврат Формат(ЗадачаСсылка.Код,"ЧГ=0");
КонецФункции 

Функция ПолучитьКомментарииВКоде(ДопПараметры) Экспорт
	Перем КомментарииВКоде;
	
	пКод = ДопПараметры.Код;
	пИсполнитель = ДопПараметры.Исполнитель;
	пНомерВнешнейЗаявки = ДопПараметры.НомерВнешнейЗаявки;
	
	ФИОИсполнителя = Неопределено;
	Если ЗначениеЗаполнено(пИсполнитель) Тогда
		МассивПодстрок = СтрРазделить(пИсполнитель," ");
		КоличествоСлов = МассивПодстрок.Количество();
		Если КоличествоСлов > 0 Тогда
			ФИОИсполнителя = " "+ МассивПодстрок[0];
		Конецесли;
		Если КоличествоСлов > 1 Тогда
			ФИОИсполнителя = ФИОИсполнителя + " " + Лев(МассивПодстрок[1],1)+".";
		Конецесли;
		Если КоличествоСлов > 2 Тогда
			ФИОИсполнителя = ФИОИсполнителя + "" + Лев(МассивПодстрок[2],1)+".";
		Конецесли;	
	Конецесли;
	пКомментарииВКоде = "//+ #"+Формат(пКод,"ЧГ=0") 
		+ ?(ЗначениеЗаполнено(пНомерВнешнейЗаявки)," "+пНомерВнешнейЗаявки,"")
		+ ФИОИсполнителя
		+ " " + Формат(ТекущаяДата(),"ДФ=yyyy-MM-dd"); 	
		
	Возврат пКомментарииВКоде;	
КонецФункции 



// СтандартныеПодсистемы.Взаимодействие
////////////////////////////////////////////////////////////////////////////////
// Интерфейс для работы с подсистемой Взаимодействия.

// Возвращает партнера и контактных лиц сделки.
// 
Функция ПолучитьКонтакты(Ссылка) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапросаПоКонтактам();
	Запрос.УстановитьПараметр("Предмет",Ссылка);
	
	НачатьТранзакцию();
	Попытка
		РезультатЗапроса = Запрос.Выполнить();
		
		Если РезультатЗапроса.Пустой() Тогда
			Результат = Неопределено;
		Иначе
			Результат = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Контакт");
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Возвращает текст запроса по контактам взаимодействий, содержащимся в документе.
//
// Параметры:
//  ТекстВременнаяТаблица - Строка - Имя временной таблицы, в которую помещаются полученные данные.
//  Объединить  - Булево  - признак, указывающий на необходимость добавления конструкции ОБЪЕДИНИТЬ в запрос.
//
// Возвращаемое значение:
//   Строка   - сформированный текст запроса для получения контактов взаимодействий объекта.
//
Функция ТекстЗапросаПоКонтактам(ТекстВременнаяТаблица = "", Объединить = Ложь) Экспорт
	
	ШаблонВыбрать = ?(Объединить,"ВЫБРАТЬ РАЗЛИЧНЫЕ","ВЫБРАТЬ РАЗЛИЧНЫЕ РАЗРЕШЕННЫЕ");
	
	ТекстЗапроса = "
	|%ШаблонВыбрать%
	|	узЗадачи.Контрагент КАК Контакт " + ТекстВременнаяТаблица + "
	|ИЗ
	|	Справочник.узЗадачи КАК узЗадачи
	|ГДЕ
	|	узЗадачи.Ссылка = &Предмет
	|	И (НЕ узЗадачи.Контрагент = ЗНАЧЕНИЕ(Справочник.узКонтрагенты.ПустаяСсылка))
	|
	|";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса,"%ШаблонВыбрать%",ШаблонВыбрать);
	
	Если Объединить Тогда
		
		ТекстЗапроса = "
		| ОБЪЕДИНИТЬ ВСЕ
		|" + ТекстЗапроса;
		
	КонецЕсли;
	
	Возврат ТекстЗапроса;
	
КонецФункции

// Конец СтандартныеПодсистемы.Взаимодействие

Функция ПолучитьНастройкиСобытий() Экспорт 
	РезультатФункции = Новый Структура();
	
	ВидыСобытий_ДобавленаЗадача = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ДобавленаЗадача");
	ВидыСобытий_НовыйИсполнитель = ПредопределенноеЗначение("Перечисление.узВидыСобытий.НовыйИсполнитель");
	ВидыСобытий_ДобавленКомментарий = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ДобавленКомментарий");
	ВидыСобытий_ИзмененКомментарий = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ИзмененКомментарий");
	ВидыСобытий_ИзмененоОписаниеЗадачи = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ИзмененоОписаниеЗадачи");
	ВидыСобытий_ИзменениеСтатуса = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ИзменениеСтатуса");
	ВидыСобытий_ВходящееПисьмо = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ВходящееПисьмо");
	ВидыСобытий_ВыполненаЗадача = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ВыполненаЗадача");
	
	РезультатФункции.Вставить("ВидыСобытий_ДобавленаЗадача",ВидыСобытий_ДобавленаЗадача);
	РезультатФункции.Вставить("ВидыСобытий_НовыйИсполнитель",ВидыСобытий_НовыйИсполнитель);
	РезультатФункции.Вставить("ВидыСобытий_ДобавленКомментарий",ВидыСобытий_ДобавленКомментарий);
	РезультатФункции.Вставить("ВидыСобытий_ИзмененКомментарий",ВидыСобытий_ИзмененКомментарий);
	РезультатФункции.Вставить("ВидыСобытий_ИзмененоОписаниеЗадачи",ВидыСобытий_ИзмененоОписаниеЗадачи);
	РезультатФункции.Вставить("ВидыСобытий_ИзменениеСтатуса",ВидыСобытий_ИзменениеСтатуса);
	РезультатФункции.Вставить("ВидыСобытий_ВходящееПисьмо",ВидыСобытий_ВходящееПисьмо);
	РезультатФункции.Вставить("ВидыСобытий_ВыполненаЗадача",ВидыСобытий_ВыполненаЗадача);
	
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки = Новый Массив();
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ИзменениеСтатуса);
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_НовыйИсполнитель);
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ДобавленКомментарий);
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ИзмененКомментарий);
	МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ВходящееПисьмо);
	
	РезультатФункции.Вставить("МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки",МассивСобытийДляНаблюдателяКоторыеПодлежатОтправки);
	
	МассивСобытийКоторыеПодлежатОтправки = Новый Массив();
	МассивСобытийКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ДобавленаЗадача);
	МассивСобытийКоторыеПодлежатОтправки.Добавить(ВидыСобытий_НовыйИсполнитель);
	МассивСобытийКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ДобавленКомментарий);
	МассивСобытийКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ИзмененКомментарий);
	МассивСобытийКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ВходящееПисьмо);
	
	РезультатФункции.Вставить("МассивСобытийКоторыеПодлежатОтправки",МассивСобытийКоторыеПодлежатОтправки);
	
	МассивСобытийДляСтарогоИсполнителяКоторыеПодлежатОтправки = Новый Массив();
	МассивСобытийДляСтарогоИсполнителяКоторыеПодлежатОтправки.Добавить(ВидыСобытий_НовыйИсполнитель);
	РезультатФункции.Вставить("МассивСобытийДляСтарогоИсполнителяКоторыеПодлежатОтправки",МассивСобытийДляСтарогоИсполнителяКоторыеПодлежатОтправки);
	
	МассивСобытийДляКонтрагентовКоторыеПодлежатОтправки = Новый Массив();
	МассивСобытийДляКонтрагентовКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ДобавленаЗадача);	
	МассивСобытийДляКонтрагентовКоторыеПодлежатОтправки.Добавить(ВидыСобытий_ВыполненаЗадача);	
	
	РезультатФункции.Вставить("МассивСобытийДляКонтрагентовКоторыеПодлежатОтправки",МассивСобытийДляКонтрагентовКоторыеПодлежатОтправки);
	
	
	Возврат РезультатФункции;	
КонецФункции 

Функция ЕстьЗаписиВРССвязанныеЗадачи(пЗадача, ОтбиратьЗаписиИПоСвязаннойЗадачи = Ложь) Экспорт
 
	пЕстьЗаписиВРССвязанныеЗадачи = Ложь;
	
	Если НЕ ЗначениеЗаполнено(пЗадача) Тогда
		Возврат пЕстьЗаписиВРССвязанныеЗадачи;
	Конецесли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	узСвязанныеЗадачи.Задача,
	               |	узСвязанныеЗадачи.СвязаннаяЗадача
	               |ИЗ
	               |	РегистрСведений.узСвязанныеЗадачи КАК узСвязанныеЗадачи
	               |ГДЕ
	               |	ВЫБОР
	               |			КОГДА &ОтбиратьЗаписиИПоСвязаннойЗадачи
	               |				ТОГДА узСвязанныеЗадачи.Задача = &Задача
	               |						ИЛИ узСвязанныеЗадачи.СвязаннаяЗадача = &Задача
	               |			ИНАЧЕ узСвязанныеЗадачи.Задача = &Задача
	               |		КОНЕЦ";
	
	Запрос.УстановитьПараметр("Задача",пЗадача);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		пЕстьЗаписиВРССвязанныеЗадачи = Истина;
	Конецесли;
	
	Возврат пЕстьЗаписиВРССвязанныеЗадачи;
КонецФункции 

Функция ПолучитьМассивНомеровСвязанныхЗадач(пЗадача) Экспорт	
	
	МассивНомеровСвязанныхЗадач = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	узСвязанныеЗадачи.СвязаннаяЗадача
	|ПОМЕСТИТЬ ВТРезультат
	|ИЗ
	|	РегистрСведений.узСвязанныеЗадачи КАК узСвязанныеЗадачи
	|ГДЕ
	|	узСвязанныеЗадачи.Задача = &Задача
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	узСвязанныеЗадачи.Задача
	|ИЗ
	|	РегистрСведений.узСвязанныеЗадачи КАК узСвязанныеЗадачи
	|ГДЕ
	|	узСвязанныеЗадачи.СвязаннаяЗадача = &Задача
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТРезультат.СвязаннаяЗадача.Код КАК НомерЗадачи
	|ИЗ
	|	ВТРезультат КАК ВТРезультат
	|ГДЕ
	|	ВТРезультат.СвязаннаяЗадача <> &Задача";
	
	Запрос.УстановитьПараметр("Задача",пЗадача);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат МассивНомеровСвязанныхЗадач;
	Конецесли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		МассивНомеровСвязанныхЗадач.Добавить(Формат(Выборка.НомерЗадачи,"ЧГ=0"));
	КонецЦикла;
	
	Возврат МассивНомеровСвязанныхЗадач;
КонецФункции

//+ #104 Дзеса Ігор (capitoshko) 08.10.2018
Функция ЗадачаБезПодчененнойИерархии(Ссылка) Экспорт 

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ узЗадачи.Ссылка) КАК КоличествоДокументов
	|ИЗ
	|	Справочник.узЗадачи КАК узЗадачи
	|ГДЕ
	|	узЗадачи.ОсновнаяЗадача В ИЕРАРХИИ(&Ссылка)";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	ВыборкаДокументов = Запрос.Выполнить().Выбрать();
	
	ВыборкаДокументов.Следующий();
	
	Если ВыборкаДокументов.КоличествоДокументов = 0 Тогда 
		Возврат Ложь;
	Иначе 
		Возврат Истина;
	КонецЕсли;
	
КонецФункции 
//- #104 Дзеса Ігор (capitoshko) 08.10.2018 

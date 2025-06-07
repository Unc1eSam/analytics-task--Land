-- CTE: Подсчет количества сданных ДЗ на курсе
WITH homework_counts AS (
    SELECT
        cu.user_id,
        cu.course_id,
        COUNT(hd.id) AS homework_done_count
    FROM course_users cu
    INNER JOIN homework_done hd ON cu.user_id = hd.user_id -- присоединяем таблицу с выполненными ДЗ
    INNER JOIN homework_lessons hl ON hd.homework_id = hl.homework_id -- присоединяем таблицу для того чтобы по ДЗ определить к какому уроку оно относится
    INNER JOIN lessons l ON hl.lesson_id = l.id AND l.course_id = cu.course_id -- по уроку определяем к какому курсу относится дз
    GROUP BY cu.user_id, cu.course_id -- группируем для подсчета количества
)

-- Основной запрос
SELECT
    cu.course_id AS "ID курса",                          
    c.name AS "Название курса",                       
    s.name AS "Предмет",                                
    s.project AS "Тип предмета",                        
    ct.name AS "Тип курса",                             
    c.starts_at AS "Дата старта курса",                 
    u.id AS "ID ученика",                              
    u.last_name AS "Фамилия ученика",                   
    ci.name AS "Город ученика",                        
    cu.active AS "Ученик не отчислен с курса",          
    cu.created_at AS "Дата открытия курса ученику",     
    FLOOR(cu.available_lessons / c.lessons_in_month) 
        AS "Количество открытых месяцев курса у ученика",  -- По логике количество доступных ученику занятий по курсу / количество занятий в месяц по курсу, с округлением вниз
    COALESCE(hc.homework_done_count, 0) 
        AS "Число сданных ДЗ ученика на курсе"          -- Количество выполненных ДЗ (с проверкой на NULL)
FROM course_users cu
JOIN users u ON cu.user_id = u.id
JOIN courses c ON cu.course_id = c.id
JOIN subjects s ON c.subject_id = s.id
JOIN course_types ct ON c.course_type_id = ct.id
JOIN cities ci ON u.city_id = ci.id
LEFT JOIN homework_counts hc -- Присоединяем слева для того, чтобы не отсечь учеников без выполненных ДЗ 
    ON cu.user_id = hc.user_id AND cu.course_id = hc.course_id
WHERE ct.name = 'Годовой' -- Фильтр по типу курса
  -- AND cu.active = 1  -- Фильтр: только активные ученики
GROUP BY 
    cu.course_id, c.name, s.name, s.project, ct.name, c.starts_at, 
    u.id, u.last_name, ci.name, cu.active, cu.created_at, 
    cu.available_lessons, c.lessons_in_month, hc.homework_done_count;
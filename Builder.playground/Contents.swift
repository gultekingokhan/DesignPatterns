// Design Patterns: Builder

import Foundation

// Models

enum DishCategory: Int {
    case firstCourses, mainCourses, garnishes, drinks
}

struct Dish {
    var name: String
    var price: Float
}

struct OrderItem {
    var dish: Dish
    var count: Int
}

struct Order {
    var firstCourses: [OrderItem] = []
    var mainCourses: [OrderItem] = []
    var garnishes: [OrderItem] = []
    var drinks: [OrderItem] = []
    
    var price: Float {
        let items = firstCourses + mainCourses + garnishes + drinks
        return items.reduce(Float(0), { $0 + $1.dish.price * Float($1.count) })
    }
}

// Builder

class OrderBuilder {
    private var order: Order?
    
    func reset() {
        order = Order()
    }
    
    func setFirstCourse(_ dish: Dish) {
        set(dish, at: order?.firstCourses, withCategory: .firstCourses)
    }
    
    func setMainCourse(_ dish: Dish) {
        set(dish, at: order?.mainCourses, withCategory: .mainCourses)
    }
    
    func setGarnish(_ dish: Dish) {
        set(dish, at: order?.garnishes, withCategory: .garnishes)
    }
    
    func setDrink(_ dish: Dish) {
        set(dish, at: order?.drinks, withCategory: .drinks)
    }
    
    func getResult() -> Order? {
        return order ?? nil
    }
    
    private func set(_ dish: Dish, at orderCategory: [OrderItem]?, withCategory dishCategory: DishCategory) {
        guard let orderCategory = orderCategory else {
            return
        }
        
        var item: OrderItem! = orderCategory.filter( { $0.dish.name == dish.name } ).first
        
        guard item == nil else {
            item.count += 1
            return
        }
        
        item = OrderItem(dish: dish, count: 1)
        
        switch dishCategory {
        case .firstCourses:
            order?.firstCourses.append(item)
        case .mainCourses:
            order?.mainCourses.append(item)
        case .garnishes:
            order?.garnishes.append(item)
        case .drinks:
            order?.drinks.append(item)
        }
    }
}

// Usage

let steak = Dish(name: "Steak", price: 2.30)
let chips = Dish(name: "Chips", price: 1.20)
let coffee = Dish(name: "Coffee", price: 0.80)

let builder = OrderBuilder()
builder.reset()
builder.setMainCourse(steak)
builder.setGarnish(chips)
builder.setDrink(coffee)

let order = builder.getResult()
order?.price

// Result:
// 4.30
